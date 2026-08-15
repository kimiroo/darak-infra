# Delete mDNS repeater config
delete service mdns

# Configure mDNS Repeater
for vid in 5 10 20 30 70 80 81; do
set service mdns repeater interface "br0.${vid}"
done