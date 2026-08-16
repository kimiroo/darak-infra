# Updater script
mkdir -p /config/scripts/updater

tee /config/scripts/updater/haproxy.sh << EOF
#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

run update container image k3s-api-haproxy
run restart container k3s-api-haproxy
EOF

chmod +x /config/scripts/updater/haproxy.sh

# Cronjob
set system task-scheduler task haproxy-updater crontab-spec '0 4 * * 0'
set system task-scheduler task haproxy-updater executable path '/config/scripts/updater/haproxy.sh'