# Delete NAT config
delete nat
delete nat66

# NAT
set nat source rule 100 outbound-interface name 'eth0'
set nat source rule 100 source address '10.0.0.0/8'
set nat source rule 100 translation address 'masquerade'

# Port forward: WAN 80/443 -> Envoy Ingress VIP (10.45.10.100, see ENVOY_INGRESS_VIP group)
set nat destination rule 100 description 'WAN HTTP/HTTPS to Envoy Ingress VIP'
set nat destination rule 100 inbound-interface name 'eth0'
set nat destination rule 100 protocol 'tcp'
set nat destination rule 100 destination port '80,443'
set nat destination rule 100 translation address '10.45.10.100'

# NAT66
set nat66 source rule 100 outbound-interface name 'eth0'
set nat66 source rule 100 source prefix 'fdab:d9c3:fb50::/48'
set nat66 source rule 100 translation address 'masquerade'

# Port forward (v6): WAN 80/443 -> Envoy Ingress VIP (fdab:d9c3:fb50:45:10::100, see ENVOY_INGRESS_VIP_V6 group)
set nat66 destination rule 100 description 'WAN HTTP/HTTPS to Envoy Ingress VIP'
set nat66 destination rule 100 inbound-interface name 'eth0'
set nat66 destination rule 100 protocol 'tcp'
set nat66 destination rule 100 destination port '80,443'
set nat66 destination rule 100 translation address 'fdab:d9c3:fb50:45:10::100'
