# Clear DNS config
delete service dns

# Listen on router internal gateway IPs (VLAN 5 & VLAN 10)
set service dns forwarding listen-address '10.5.0.1'
set service dns forwarding listen-address '10.10.0.1'
set service dns forwarding listen-address '127.0.0.1'

# Allow queries from Infrastructure subnet (where PVE LXCs reside)
set service dns forwarding allow-from '10.10.0.0/16'
set service dns forwarding allow-from '10.5.0.0/16'
set service dns forwarding allow-from '127.0.0.1/32'