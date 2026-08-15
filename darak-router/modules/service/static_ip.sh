# Clear Static IP config
for vid in 5 10 20 30 70 80 81 90 99; do
delete service dhcp-server shared-network-name "VLAN${vid}" subnet "10.${vid}.0.0/16" static-mapping
done

# SL-T2270DW (printer)
set service dhcp-server shared-network-name VLAN81 subnet 10.81.0.0/16 static-mapping printer ip-address '10.81.0.100'
set service dhcp-server shared-network-name VLAN81 subnet 10.81.0.0/16 static-mapping printer mac 'd0:ad:08:f9:87:83'

# Samsung AC (home-ac)
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 static-mapping home-ac ip-address '10.80.100.1'
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 static-mapping home-ac mac '50:fd:d5:c8:81:a8'

# Tapo C100 (cam-01)
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 static-mapping cam-01 ip-address '10.80.200.10'
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 static-mapping cam-01 mac '98:03:8e:a4:42:a4'