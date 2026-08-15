# Drop firewall group configs
delete firewall group

# IPv4 VLAN groups
for id in 5 7 10 20 30 70 80 81 90 99; do
set firewall group network-group "VLAN${id}" network "10.${id}.0.0/16"
done

# IPv6 VLAN groups
for id in 5 7 10 20 30 70 80 90 99; do
set firewall group ipv6-network-group "VLAN${id}_V6" network "fdab:d9c3:fb50:${id}::/64"
done

# Interface group
for id in 5 7 10 20 30 70 80 81 90 99; do
set firewall group interface-group LOCAL_INTERFACES interface "br0.${id}"
done

# Private address group
set firewall group network-group INTERNAL_NETWORKS network '10.0.0.0/8'
set firewall group ipv6-network-group INTERNAL_NETWORKS_V6 network 'fdab:d9c3:fb50::/48'

# Bare-metal node groups
set firewall group address-group PVE_NODE_01 address '10.10.10.10'
set firewall group address-group PVE_NODE_02 address '10.10.10.20'
set firewall group address-group PVE_NODE_03 address '10.10.10.30'
set firewall group address-group PVE_NODE_04 address '10.10.10.40'
set firewall group address-group FILE_NODE_01 address '10.10.10.50'
set firewall group address-group PI_NODE_01 address '10.10.10.60'

set firewall group ipv6-address-group PVE_NODE_01_V6 address 'fdab:d9c3:fb50:10:10::10'
set firewall group ipv6-address-group PVE_NODE_02_V6 address 'fdab:d9c3:fb50:10:10::20'
set firewall group ipv6-address-group PVE_NODE_03_V6 address 'fdab:d9c3:fb50:10:10::30'
set firewall group ipv6-address-group PVE_NODE_04_V6 address 'fdab:d9c3:fb50:10:10::40'
set firewall group ipv6-address-group FILE_NODE_01_V6 address 'fdab:d9c3:fb50:10:10::50'
set firewall group ipv6-address-group PI_NODE_01_V6 address 'fdab:d9c3:fb50:10:10::60'

# VM node groups
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.11'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.12'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.21'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.22'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.31'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.32'
set firewall group address-group ROCKY_DOCKER_01 address '10.10.20.41'

set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10:20::11'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10:20::12'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10:20::21'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10:20::22'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10:20::31'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10:20::32'
set firewall group ipv6-address-group ROCKY_DOCKER_01_V6 address 'fdab:d9c3:fb50:10:20::41'

# Admin Allowed Destinations group
for id in 5 10 20 30 80; do
set firewall group network-group ADMIN_DESTINATIONS network "10.${id}.0.0/16"
set firewall group ipv6-network-group ADMIN_DESTINATIONS_V6 network "fdab:d9c3:fb50:${id}::/64"
done

# Create Printer definition groups
for id in 7 10 20 30; do
set firewall group network-group TRUSTED_PRINT_SOURCES network "10.${id}.0.0/16"
#set firewall group ipv6-network-group TRUSTED_PRINT_SOURCES_V6 network "fdab:d9c3:fb50:${id}::/64"
done

# K3s VIP Definition
set firewall group network-group K3S_VIP network '10.45.0.0/16'
set firewall group ipv6-network-group K3S_VIP_V6 network 'fdab:d9c3:fb50:45::/64'

# VPN Definition
set firewall group network-group ADMIN_VPN_RANGE network '10.7.10.0/24'
set firewall group ipv6-network-group ADMIN_VPN_RANGE_V6 network 'fdab:d9c3:fb50:7:10::/80'

# Cloud IoT subnet
set firewall group network-group CLOUD_IOT network '10.80.100.0/24'
#set firewall group ipv6-network-group CLOUD_IOT_V6 network 'fdab:d9c3:fb50:80:100::/80'

# RADIUS
#set firewall group port-group RADIUS_PORTS port '1812'
#set firewall group port-group RADIUS_PORTS port '1813'