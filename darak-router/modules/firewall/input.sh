# Drop firewall input filter configs
for ver in 'ipv4' 'ipv6'; do
delete firewall "${ver}" input filter
done

# Rule 10 - Allow WAN DHCP, DHCPv6 Client Inbound (UDP 68)
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 10 action 'accept'
set firewall "${ver}" input filter rule 10 description 'Allow WAN DHCP Client Inbound'
set firewall "${ver}" input filter rule 10 inbound-interface name 'eth0'
set firewall "${ver}" input filter rule 10 protocol 'udp'
done
set firewall ipv4 input filter rule 10 destination port '68'
set firewall ipv6 input filter rule 10 destination port '546'

# Rule 20 - Allow WireGuard VPN ingress from WAN
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 20 action 'accept'
set firewall "${ver}" input filter rule 20 description 'Allow WireGuard VPN from WAN'
set firewall "${ver}" input filter rule 20 protocol 'udp'
set firewall "${ver}" input filter rule 20 destination port '51820'
done

# Rule 30 - Allow DNS and NTP from LAN
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 30 action 'accept'
set firewall "${ver}" input filter rule 30 description 'Allow DNS and NTP from LAN'
set firewall "${ver}" input filter rule 30 destination port '53,123'
set firewall "${ver}" input filter rule 30 protocol 'udp'
done
set firewall ipv4 input filter rule 30 source group network-group 'INTERNAL_NETWORKS'
set firewall ipv6 input filter rule 30 source group network-group 'INTERNAL_NETWORKS_V6'

# Rule 31 - Allow ICMP (Ping)
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 31 action 'accept'
set firewall "${ver}" input filter rule 31 description 'Allow ICMP Ping'
done
set firewall ipv4 input filter rule 31 protocol 'icmp'
set firewall ipv6 input filter rule 31 protocol 'icmpv6'

# Rule 32 - Allow DHCP requests from LAN
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 32 action 'accept'
set firewall "${ver}" input filter rule 32 description 'Allow DHCP requests from LAN'
set firewall "${ver}" input filter rule 32 inbound-interface group 'LOCAL_INTERFACES'
set firewall "${ver}" input filter rule 32 protocol 'udp'
done
set firewall ipv4 input filter rule 32 destination port '67'
set firewall ipv6 input filter rule 32 destination port '546,547'

# Rule 40 - Allow Router SSH from VLAN20 (Admin)
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 40 action 'accept'
set firewall "${ver}" input filter rule 40 description 'Allow Router SSH from VLAN20 (Admin)'
set firewall "${ver}" input filter rule 40 destination port '22'
set firewall "${ver}" input filter rule 40 protocol 'tcp'
done
set firewall ipv4 input filter rule 40 source group network-group 'VLAN20'
set firewall ipv6 input filter rule 40 source group network-group 'VLAN20_V6'

# Rule 41 - Allow Router SSH from VLAN7 (VPN)
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 41 action 'accept'
set firewall "${ver}" input filter rule 41 description 'Allow Router SSH from VLAN7 (VPN)'
set firewall "${ver}" input filter rule 41 destination port '22'
set firewall "${ver}" input filter rule 41 protocol 'tcp'
done
set firewall ipv4 input filter rule 41 source group network-group 'ADMIN_VPN_RANGE'
set firewall ipv6 input filter rule 41 source group network-group 'ADMIN_VPN_RANGE_V6'

# Rule 50: Allow BGP (VLAN10)
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 50 action 'accept'
set firewall "${ver}" input filter rule 50 description 'Allow BGP (VLAN10)'
set firewall "${ver}" input filter rule 50 destination port '179'
set firewall "${ver}" input filter rule 50 protocol 'tcp'
done
set firewall ipv4 input filter rule 50 source group network-group 'VLAN10'
set firewall ipv6 input filter rule 50 source group network-group 'VLAN10_V6'

# Rule 60: Allow Kubernetes API from K3s nodes
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 60 action 'accept'
set firewall "${ver}" input filter rule 60 description 'Allow Kubernetes API from K3s nodes'
set firewall "${ver}" input filter rule 60 destination port '6443'
set firewall "${ver}" input filter rule 60 protocol 'tcp'
done
set firewall ipv4 input filter rule 60 source group address-group 'ROCKY_K3S_NODES'
set firewall ipv6 input filter rule 60 source group address-group 'ROCKY_K3S_NODES_V6'

# Rule 61: Allow Kubernetes API from VLAN20 (Admin)
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 61 action 'accept'
set firewall "${ver}" input filter rule 61 description 'Allow Kubernetes API from VLAN20 (Admin)'
set firewall "${ver}" input filter rule 61 destination port '6443'
set firewall "${ver}" input filter rule 61 protocol 'tcp'
done
set firewall ipv4 input filter rule 61 source group network-group 'VLAN20'
set firewall ipv6 input filter rule 61 source group network-group 'VLAN20_V6'

# Rule 62: Allow Kubernetes API from Admin VPN range
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 62 action 'accept'
set firewall "${ver}" input filter rule 62 description 'Allow Kubernetes API from Admin VPN range'
set firewall "${ver}" input filter rule 62 destination port '6443'
set firewall "${ver}" input filter rule 62 protocol 'tcp'
done
set firewall ipv4 input filter rule 62 source group network-group 'ADMIN_VPN_RANGE'
set firewall ipv6 input filter rule 62 source group network-group 'ADMIN_VPN_RANGE_V6'

# Rule 999: Drop for all other unallowed WAN ingress to the router
for ver in 'ipv4' 'ipv6'; do
set firewall "${ver}" input filter rule 999 action 'drop'
set firewall "${ver}" input filter rule 999 description 'Drop all other unallowed WAN traffic to Router'
done