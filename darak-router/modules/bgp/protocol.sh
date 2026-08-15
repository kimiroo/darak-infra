# Delete BGP protocol config
delete protocols bgp

# Configure Router's Autonomous System Number
set protocols bgp system-as '64512'

# Enable ECMP (Equal-Cost Multi-Path) up to 64 paths for both address families
set protocols bgp address-family ipv4-unicast maximum-paths ebgp '64'
set protocols bgp address-family ipv6-unicast maximum-paths ebgp '64'
set protocols bgp parameters bestpath as-path multipath-relax

# IPv4 & IPv6 Peer-Group
set protocols bgp peer-group K3S_NODES_V4 remote-as '64513'
set protocols bgp peer-group K3S_NODES_V4 address-family ipv4-unicast route-map import 'K3S_INBOUND_FILTER'
set protocols bgp peer-group K3S_NODES_V4 address-family ipv4-unicast soft-reconfiguration inbound

set protocols bgp peer-group K3S_NODES_V6 remote-as '64513'
set protocols bgp peer-group K3S_NODES_V6 address-family ipv4-unicast disable
set protocols bgp peer-group K3S_NODES_V6 address-family ipv6-unicast route-map import 'K3S_INBOUND_FILTER'
set protocols bgp peer-group K3S_NODES_V6 address-family ipv6-unicast soft-reconfiguration inbound

# IPv4 & IPv6 Neighbors
for id in 11 12 21 22 31 32; do
set protocols bgp neighbor "10.10.20.${id}" peer-group 'K3S_NODES_V4'
set protocols bgp neighbor "fdab:d9c3:fb50:10:20::${id}" peer-group 'K3S_NODES_V6'
done