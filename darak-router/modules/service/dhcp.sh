# Clear DHCP config
for vid in 10 20 30 70 80 81 90 99; do
delete service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" subnet-id
delete service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" option
delete service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" range
done
delete service dhcp-server hostfile-update

# VLAN10 (Infra)
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 subnet-id 10

set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option default-router 10.10.0.1
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 range 0 start 10.10.50.100
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 range 0 stop 10.10.50.250

# VLAN20 - VLAN99
for vid in 20 30 70 80 81 90 99; do
set service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" subnet-id "${vid}"

set service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" option default-router "10.${vid}.0.1"
set service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" range 0 start "10.${vid}.20.100"
set service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" range 0 stop "10.${vid}.20.250"
done

# Nameservers
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option name-server 45.90.28.99
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option name-server 45.90.30.99

set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 option name-server 45.90.28.18
set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 option name-server 45.90.30.18

set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 option name-server 45.90.28.25
set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 option name-server 45.90.30.25

set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 option name-server 45.90.28.227
set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 option name-server 45.90.30.227

set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 option name-server 45.90.28.222
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 option name-server 45.90.30.222

set service dhcp-server shared-network-name VLAN81 subnet 10.81.0.0/16 option name-server 45.90.28.222
set service dhcp-server shared-network-name VLAN81 subnet 10.81.0.0/16 option name-server 45.90.30.222

set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 option name-server 45.90.28.227
set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 option name-server 45.90.30.227

set service dhcp-server shared-network-name VLAN99 subnet 10.99.0.0/16 option name-server 10.99.0.1

# Automatically update the system hosts file with DHCP client leases
set service dhcp-server hostfile-update