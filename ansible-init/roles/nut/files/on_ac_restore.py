import sys
import time
import json
import subprocess
import logging
import urllib.request
import urllib.error
from wakeonlan import send_magic_packet

from config import *

# Configure logging to write to a file for persistent logs
logging.basicConfig(
    filename='/var/log/nut_script/nut_script.log',  # Log file path
    format='%(asctime)s [%(levelname)s] %(name)s - %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S',
)

log = logging.getLogger('on_ac_restore')

# --- End Configuration Section ---

def notify(channels, ntfy_title, ntfy_message, sms_message):
    """Sends a notification using the custom API."""
    headers = {
        'X-DARAK-API-Access-Key': NOTIFY_API_KEY,
        'Content-Type': 'application/json'
    }
    data = {
        'channels': channels,
        'ntfy': {
            'title': ntfy_title,
            'message': ntfy_message
        },
        'sms': {
            'message': sms_message
        }
    }

    try:
        json_string = json.dumps(data, ensure_ascii=False)
        json_data_bytes = json_string.encode('utf-8')
        req = urllib.request.Request(NOTIFY_URL, data=json_data_bytes, headers=headers, method='POST')
        with urllib.request.urlopen(req) as response:
            response_data = response.read()
            response_text = response_data.decode('utf-8')
            api_response = json.loads(response_text)
            if api_response.get('result') == 'success':
                log.info("Notification sent successfully.")
                return True
            else:
                log.error(f"Failed to send notification. API response: {api_response}")
                return False
    except urllib.error.URLError as e:
        log.error(f"URLError occurred: {e.reason}")
    except Exception as e:
        log.error(f"An unexpected error occurred while notifying: {e}")
    return False

def get_ups_info(item_name):
    command = ['/usr/bin/upsc', 'VX-600VA@localhost', item_name]

    try:
        result = subprocess.run(command, capture_output=True, text=True, check=True, timeout=10)
        output_value_string = result.stdout.strip()

        if not output_value_string:
            log.error('Battery level command returned empty result')
            return None

        return output_value_string

    except subprocess.TimeoutExpired:
        log.error('Battery level command timed out')
        return None
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        log.error(f'Failed to get battery level. Check NUT server and upsc command. Error: {e}')
        if hasattr(e, 'stderr') and e.stderr:
            log.error(f'Command stderr: {e.stderr}')
        return None
    except Exception as e:
        log.error(f'An unexpected error occurred while getting battery info: {e}')
        return None

def get_battery_status():
    try:
        output_value_string = get_ups_info('ups.status')

        if not output_value_string:
            log.error('Battery status command returned empty result')
            return None

        return output_value_string

    except Exception as e:
        log.error(f'An unexpected error occurred while getting battery status: {e}')
        return None

def get_battery_level():
    """
    Gets the current battery charge level from the UPS.
    Returns the charge level as an integer or None on failure.
    """
    try:
        output_value_string = get_ups_info('battery.charge')

        if not output_value_string:
            log.error('Battery level command returned empty result')
            return None

        battery_level = int(float(output_value_string))

        if not 0 <= battery_level <= 100:
            log.warning(f'Battery level out of expected range (0-100): {battery_level}')

        return battery_level

    except (ValueError, TypeError) as e:
        log.error(f'Failed to parse battery level as number: \'{output_value_string}\'. Error: {e}')
        return None
    except Exception as e:
        log.error(f'An unexpected error occurred while getting battery level: {e}')
        return None

def main():
    """Main function to run the logic."""
    log.info("--- Script started ---")
    current_battery_level = get_battery_level()

    if current_battery_level is None:
        log.warning("Could not retrieve battery level. Exiting...")
        # Do not cancel the timer so it can try again
        sys.exit(1)

    log.info('UPS on AC power. Monitoring battery level manually...')

    error_count = 0
    while True:
        current_battery_level = get_battery_level()
        current_battery_status = get_battery_status()

        if current_battery_level is None:
            error_count += 1

            if error_count >= 60:
                notify(
                    channels=['self'],
                    ntfy_title='UPS 상태 이상',
                    ntfy_message='UPS에 이상이 생겼습니다. EDM 서버를 안전하게 재구동할 수 없습니다.',
                    sms_message='UPS에 이상이 생겼습니다. EDM 서버를 안전하게 재구동할 수 없습니다.'
                )
                sys.exit(1)

            continue

        if current_battery_level > TARGET_BATTERY_LEVEL and current_battery_status == 'OL':
            log.info(f"Battery level ({current_battery_level}%) is above target ({TARGET_BATTERY_LEVEL}%). Proceeding with WOL.")
            break

        if current_battery_status == 'OB':
            log.info(f"Power lost. Exitting script.")
            exit()

        time.sleep(1)

    # Send a notification before sending WOL packets
    notify(
        channels=['self', 'family', 'friend'],
        ntfy_title='전원공급 복구',
        ntfy_message='EDM 서버로의 전원이 복구되었습니다. EDM 서버를 재구동합니다.',
        sms_message='EDM 서버로의 전원이 복구되었습니다. EDM 서버를 재구동합니다.'
    )

    # Send WOL packets to all hosts
    log.info("Sending WOL packets...")
    for _ in range(3): # Send packets 3 times for reliability
        for host in HOSTS:
            try:
                send_magic_packet(host)
                log.info(f"Magic packet sent to {host}")
            except Exception as e:
                log.error(f"Failed to send magic packet to {host}: {e}")
        time.sleep(2) # Short delay between each round of packets
    log.info("WOL packet transmission complete.")

    log.info("--- Script finished ---")

if __name__ == '__main__':
    main()