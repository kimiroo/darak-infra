# Clear WAN config
delete interface bridge

# VLAN for each ethernet interfaces
set interface bridge br0 enable-vlan

# eth1 (Infra)
set interface bridge br0 member interface eth1 native-vlan 10

# eth2 (Yongj-PC)
set interface bridge br0 member interface eth2 native-vlan 20

# eth3 (AP)
set interface bridge br0 member interface eth3 native-vlan 5
set interface bridge br0 member interface eth3 allowed-vlan 20
set interface bridge br0 member interface eth3 allowed-vlan 30
set interface bridge br0 member interface eth3 allowed-vlan 70
set interface bridge br0 member interface eth3 allowed-vlan 80
set interface bridge br0 member interface eth3 allowed-vlan 90
set interface bridge br0 member interface eth3 allowed-vlan 99

# eth4 (Agnes-PC)
set interface bridge br0 member interface eth4 native-vlan 30

# eth5 (Printer)
set interface bridge br0 member interface eth5 native-vlan 81

# Subnet config for each VLANs
for vid in 5 10 20 30 70 80 90 99; do
set interface bridge br0 vif "${vid}" address "10.${vid}.0.1/16"
set interface bridge br0 vif "${vid}" address "fdab:d9c3:fb50:${vid}::1/64"
done

# Printer
set interface bridge br0 vif 81 address '10.81.0.1/16'