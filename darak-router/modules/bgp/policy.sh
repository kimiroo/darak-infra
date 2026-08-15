# Delete Policy config
delete policy

# Define allowed IPv4 prefixes for K3s Services
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 action 'permit'
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 prefix '10.45.10.0/24'
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 ge 24
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 le 32

# Define allowed IPv6 prefixes for K3s Services (ULA Range)
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 action 'permit'
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 prefix 'fdab:d9c3:fb50:45:10::/80'
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 ge 80
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 le 128

# Bind Prefix-Lists to a Route-Map for inbound BGP filtering
set policy route-map K3S_INBOUND_FILTER rule 10 action 'permit'
set policy route-map K3S_INBOUND_FILTER rule 10 match ip address prefix-list 'K3S_VIP_ALLOWED_V4'

set policy route-map K3S_INBOUND_FILTER rule 20 action 'permit'
set policy route-map K3S_INBOUND_FILTER rule 20 match ipv6 address prefix-list 'K3S_VIP_ALLOWED_V6'