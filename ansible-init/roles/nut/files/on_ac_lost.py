import time
import json
import logging
import subprocess
import urllib.request
import urllib.error

from config import *

# Configure logging to write to a file for persistent logs
logging.basicConfig(
    filename='/var/log/nut_script/nut_script.log',  # Log file path
    format='%(asctime)s [%(levelname)s] %(name)s - %(message)s',
    level=logging.INFO,
    datefmt='%Y-%m-%d %H:%M:%S',
)

log = logging.getLogger('on_ac_lost')

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
                log.info('Notification sent successfully.')
                return True
            else:
                log.error(f'Failed to send notification. API response: {api_response}')
                return False
    except urllib.error.URLError as e:
        log.error(f'URLError occurred: {e.reason}')
    except Exception as e:
        log.error(f'An unexpected error occurred while notifying: {e}')
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
    log.info('--- Script started ---')

    notify(
        channels=['self', 'family', 'friend'],
        ntfy_title='(긴급) 전원 공급 차단',
        ntfy_message='서버로의 전원 공급이 차단되었습니다. 현재 백업 배터리로 운용 중입니다. 원활한 EDM 구동을 위해 즉시 전원 상태를 확인하십시오.',
        sms_message='서버로의 전원 공급이 차단되었습니다. 원활한 EDM 구동을 위해 즉시 전원 상태를 확인하십시오.'
    )

    log.info('UPS on battery. Monitoring battery level manually...')
    while True:
        current_battery_level = get_battery_level()
        current_battery_status = get_battery_status()

        if current_battery_level is None or current_battery_status is None:
            pass

        if current_battery_level < 50 and current_battery_status == 'OB':
            log.info(f'Battery reached critical level: {current_battery_level}%. Sending notification...')
            notify(
                channels=['self', 'family', 'friend'],
                ntfy_title='(긴급) 전원 공급 차단',
                ntfy_message='백업 배터리가 얼마 남지 않았습니다. EDM 서버를 종료합니다. 전원 상태를 확인하십시오.',
                sms_message='백업 배터리가 얼마 남지 않았습니다. EDM 서버를 종료합니다. 전원 상태를 확인하십시오.'
            )
            break

        elif current_battery_status == 'OL':
            log.info(f'Power restored. Exiting...')
            break

        time.sleep(1)

    log.info('--- Script finished ---')

if __name__ == '__main__':
    main()