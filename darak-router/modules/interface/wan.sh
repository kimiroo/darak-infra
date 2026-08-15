# Clear WAN config
delete interface ethernet eth0

set interface ethernet eth0 description WAN
set interface ethernet eth0 mac "${WAN_MAC}"

# IPv4
set interface ethernet eth0 address dhcp

# IPv6
set interface ethernet eth0 address dhcpv6
set interface ethernet eth0 ipv6 address autoconf
set interface ethernet eth0 dhcpv6-options duid "00:03:00:01:${WAN_MAC}"