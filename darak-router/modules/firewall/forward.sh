# Drop firewall forward filter configs rules
for ver in 'ipv4' 'ipv6'; do
delete firewall "${ver}" forward filter
done

# Rule 100:[Admin]  VLAN20 (Admin) -> Trusted Internal VLANs
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 100 action 'accept'
set firewall "${ver}" forward filter rule 100 description 'Admin to Trusted VLANs'
done
set firewall ipv4 forward filter rule 100 source group network-group 'VLAN20'
set firewall ipv4 forward filter rule 100 destination group network-group 'ADMIN_DESTINATIONS'
set firewall ipv6 forward filter rule 100 source group network-group 'VLAN20_V6'
set firewall ipv6 forward filter rule 100 destination group network-group 'ADMIN_DESTINATIONS_V6'

# Rule 110: [Admin] Admin VPN range -> Trusted Internal VLANs
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 110 action 'accept'
set firewall "${ver}" forward filter rule 110 description 'Admin VPN range to Internal VLANs'
done
set firewall ipv4 forward filter rule 110 source group network-group 'ADMIN_VPN_RANGE'
set firewall ipv4 forward filter rule 110 destination group network-group 'ADMIN_DESTINATIONS'
set firewall ipv6 forward filter rule 110 source group network-group 'ADMIN_VPN_RANGE_V6'
set firewall ipv6 forward filter rule 110 destination group network-group 'ADMIN_DESTINATIONS_V6'

# Rule 120: [Printer] TRUSTED_PRINT_SOURCES -> VLAN81 (Printer)
set firewall ipv4 forward filter rule 120 action 'accept'
set firewall ipv4 forward filter rule 120 description 'Trusted Networks to Printer'
set firewall ipv4 forward filter rule 120 source group network-group 'TRUSTED_PRINT_SOURCES'
set firewall ipv4 forward filter rule 120 destination group network-group 'VLAN81'

# Rule 130: [Ansible] pi-node-01 -> VLAN5 SSH
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 130 action 'accept'
set firewall "${ver}" forward filter rule 130 description 'pi-node-01 to VLAN5 SSH'
set firewall "${ver}" forward filter rule 130 protocol 'tcp'
set firewall "${ver}" forward filter rule 130 destination port '22'
done
set firewall ipv4 forward filter rule 130 source group address-group 'PI_NODE_01'
set firewall ipv4 forward filter rule 130 destination group network-group 'VLAN5'
set firewall ipv6 forward filter rule 130 source group address-group 'PI_NODE_01_V6'
set firewall ipv6 forward filter rule 130 destination group network-group 'VLAN5_V6'

# Rule 140: [RADIUS] VLAN5 -> FreeRADIUS Server
#for ver in 'ipv4' 'ipv6'; do
#set firewall "${ver}" forward filter rule 140 action 'accept'
#set firewall "${ver}" forward filter rule 140 description 'VLAN5 to FreeRADIUS'
#set firewall "${ver}" forward filter rule 140 protocol 'udp'
#set firewall "${ver}" forward filter rule 140 destination group port-group 'RADIUS_PORTS'
#done
#set firewall ipv4 forward filter rule 140 source group network-group 'VLAN5'
#set firewall ipv4 forward filter rule 140 destination address '10.20.10.50'# <-- Change to actual FreeRADIUS IP
#set firewall ipv6 forward filter rule 140 source group network-group 'VLAN5_V6'
#set firewall ipv6 forward filter rule 140 destination address 'fdab:d9c3:fb50:10:10::50'# <-- Change to actual FreeRADIUS IP

# Rule 150: [Matter] VLAN80 (IoT) -> Matter Server
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 150 action 'accept'
set firewall "${ver}" forward filter rule 150 description 'VLAN80 (IoT) to Matter Server'
set firewall "${ver}" forward filter rule 150 protocol 'udp'
set firewall "${ver}" forward filter rule 150 destination port '5540'
done
set firewall ipv4 forward filter rule 150 source group network-group 'VLAN80'
set firewall ipv4 forward filter rule 150 destination group address-group 'ROCKY_DOCKER_01'
set firewall ipv6 forward filter rule 150 source group network-group 'VLAN80_V6'
set firewall ipv6 forward filter rule 150 destination group address-group 'ROCKY_DOCKER_01_V6'

# Rule 160: [Matter] Matter Server -> VLAN80 (IoT)
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 160 action 'accept'
set firewall "${ver}" forward filter rule 160 description 'Matter Server to VLAN80 (IoT)'
set firewall "${ver}" forward filter rule 160 protocol 'udp'
set firewall "${ver}" forward filter rule 160 destination port '5540'
done
set firewall ipv4 forward filter rule 160 source group address-group 'ROCKY_DOCKER_01'
set firewall ipv4 forward filter rule 160 destination group network-group 'VLAN80'
set firewall ipv6 forward filter rule 160 source group address-group 'ROCKY_DOCKER_01_V6'
set firewall ipv6 forward filter rule 160 destination group network-group 'VLAN80_V6'

# Rule 200: [IoT] Cloud IoT devices -> WAN
set firewall ipv4 forward filter rule 200 action 'accept'
set firewall ipv4 forward filter rule 200 description 'Cloud IoT devices to WAN'
set firewall ipv4 forward filter rule 200 source group network-group 'CLOUD_IOT'
set firewall ipv4 forward filter rule 200 outbound-interface name 'eth0'

# Rule 210: [IoT] Drop IoT to Internet
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 210 action 'drop'
set firewall "${ver}" forward filter rule 210 description 'Drop IoT to Internet'
set firewall "${ver}" forward filter rule 210 outbound-interface name 'eth0'
done
set firewall ipv4 forward filter rule 210 source group network-group 'VLAN80'
set firewall ipv6 forward filter rule 210 source group network-group 'VLAN80_V6'

# Rule 220: [Printer] Drop Printer to Internet
set firewall ipv4 forward filter rule 220 action 'drop'
set firewall ipv4 forward filter rule 220 description 'Drop IoT to Internet'
set firewall ipv4 forward filter rule 220 source group network-group 'VLAN81'
set firewall ipv4 forward filter rule 220 outbound-interface name 'eth0'

# Rule 1000: [WireGuard] Allow all forwarding traffic from wg0
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 1000 action 'accept'
set firewall "${ver}" forward filter rule 1000 description 'Allow all forwarding traffic from wg0'
set firewall "${ver}" forward filter rule 1000 inbound-interface name 'wg0'
done

# Rule 9000: [Blackhole] Drop Untracked Inter-VLAN Traffic
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" forward filter rule 9000 action 'drop'
set firewall "${ver}" forward filter rule 9000 description 'Drop Untracked Inter-VLAN Traffic'
done
set firewall ipv4 forward filter rule 9000 destination group network-group 'INTERNAL_NETWORKS'
set firewall ipv6 forward filter rule 9000 destination group network-group 'INTERNAL_NETWORKS_V6'