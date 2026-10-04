# Keep WAN_IP / WAN_IP_V6 address-groups in sync with eth0's (DHCP/SLAAC) global addresses.
# Used by the NAT rules so LAN/VPN clients reaching the public IP get the same DNAT as WAN.
mkdir -p /config/scripts/wan_ip

# Print eth0 global addresses (v4 | v6). IPv6 skips link-local, temporary, deprecated and tentative ones.
tee /config/scripts/wan_ip/get.sh << 'EOF'
#!/bin/bash

case "$1" in
  v4)
    ip -4 -o addr show dev eth0 scope global | awk '{print $4}' | cut -d/ -f1
    ;;
  v6)
    ip -6 -o addr show dev eth0 scope global \
      | grep -vE 'temporary|deprecated|tentative|dadfailed' \
      | awk '{print $4}' | cut -d/ -f1
    ;;
esac
EOF

# Apply: rewrite groups to the current addresses, commit and save. Called by watch.sh only on a mismatch.
tee /config/scripts/wan_ip/apply.sh << 'EOF'
#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

GET=/config/scripts/wan_ip/get.sh

configure
for spec in "address-group WAN_IP v4" "ipv6-address-group WAN_IP_V6 v6"; do
  read -r type group ver <<< "$spec"
  want="$($GET "$ver")"
  # Never wipe a group when eth0 has no address (e.g. mid-renewal)
  [[ -z "$want" ]] && continue
  delete firewall group "$type" "$group"
  for ip in $want; do
    set firewall group "$type" "$group" address "$ip"
  done
done
commit comment "wan-ip-updater"
save
exit
EOF

# Watch: runs every minute, does nothing unless eth0's addresses differ from the groups.
tee /config/scripts/wan_ip/watch.sh << 'EOF'
#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

GET=/config/scripts/wan_ip/get.sh

differs() {
  local type="$1" group="$2" ver="$3"
  local want have
  want="$($GET "$ver" | sort)"
  have="$(cli-shell-api returnActiveValues firewall group "$type" "$group" | tr -d "'" | tr ' ' '\n' | sort)"
  [[ -n "$want" && "$want" != "$have" ]]
}

if differs address-group WAN_IP v4 || differs ipv6-address-group WAN_IP_V6 v6; then
  /config/scripts/wan_ip/apply.sh
fi
EOF

chmod +x /config/scripts/wan_ip/get.sh /config/scripts/wan_ip/apply.sh /config/scripts/wan_ip/watch.sh

# Seed groups for this commit (NAT rules reference them)
for ip in $(/config/scripts/wan_ip/get.sh v4); do
set firewall group address-group WAN_IP address "$ip"
done
for ip in $(/config/scripts/wan_ip/get.sh v6); do
set firewall group ipv6-address-group WAN_IP_V6 address "$ip"
done

# Cronjob
set system task-scheduler task wan-ip-updater crontab-spec '* * * * *'
set system task-scheduler task wan-ip-updater executable path '/config/scripts/wan_ip/watch.sh'
