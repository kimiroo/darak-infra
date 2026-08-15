# Delete NAT config
delete nat
delete nat66

# NAT
set nat source rule 100 outbound-interface name 'eth0'
set nat source rule 100 source address '10.0.0.0/8'
set nat source rule 100 translation address 'masquerade'

# NAT66
set nat66 source rule 100 outbound-interface name 'eth0'
set nat66 source rule 100 source prefix 'fdab:d9c3:fb50::/48'
set nat66 source rule 100 translation address 'masquerade'