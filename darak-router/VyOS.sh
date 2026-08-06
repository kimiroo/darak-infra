#!/bin/vbash

source /opt/vyatta/etc/functions/script-template

configure

#############
### Basic ###
#############

echo "Configuring: Basic..."

# Hostname
set system host-name darak-router

# DNS
set system name-server 2a07:a8c0::ef:3c69
set system name-server 2a07:a8c1::ef:3c69
set system name-server 45.90.28.99
set system name-server 45.90.30.99

# NTP/Timezone
set system time-zone Asia/Seoul
delete service ntp server
set service ntp server ntp.kriss.re.kr
set service ntp server pool.ntp.org

# SSH
set service ssh port 22

commit comment 'system: Configure basic system'
save



###########
### SSH ###
###########

echo "Configuring: SSH..."

# ==================================================
# 1. Add SSH public key
# ==================================================
set system login user vyos authentication public-keys yongj-pc type 'ssh-ed25519'
set system login user vyos authentication public-keys yongj-pc key 'AAAAC3NzaC1lZDI1NTE5AAAAIEkDsky1VRVbbuUguHaKaOXQTAwg50MT75wCH5QCk/o5'

# ==================================================
# 2. Authentication & Security Policies
# ==================================================
set service ssh disable-password-authentication
set service ssh disable-host-validation

# ==================================================
# 3. Session KeepAlive
# ==================================================
set service ssh client-keepalive-interval '300'

# ==================================================
# 4. Encryption Ciphers
# ==================================================
set service ssh cipher 'chacha20-poly1305@openssh.com'
set service ssh cipher 'aes256-gcm@openssh.com'
set service ssh cipher 'aes128-gcm@openssh.com'
set service ssh cipher 'aes256-ctr'
set service ssh cipher 'aes192-ctr'
set service ssh cipher 'aes128-ctr'

# ==================================================
# 5. Key Exchange Algorithms (Kex)
# ==================================================
set service ssh key-exchange 'curve25519-sha256'
set service ssh key-exchange 'curve25519-sha256@libssh.org'
set service ssh key-exchange 'diffie-hellman-group16-sha512'
set service ssh key-exchange 'diffie-hellman-group18-sha512'
set service ssh key-exchange 'diffie-hellman-group14-sha256'

# ==================================================
# 6. Message Authentication Codes (MACs)
# ==================================================
set service ssh mac 'umac-128-etm@openssh.com'
set service ssh mac 'hmac-sha2-256-etm@openssh.com'
set service ssh mac 'hmac-sha2-512-etm@openssh.com'

# ==================================================
# 7. Dynamic Brute-Force Protection
# ==================================================
# Block IP for 300s if 3 auth failures occur within 60s
set service ssh dynamic-protection block-time '300'
set service ssh dynamic-protection detect-time '60'
set service ssh dynamic-protection threshold '3'

commit comment 'ssh: Apply SSH hardening options'
save



###########
### WAN ###
###########

echo "Configuring: WAN..."

# Description
set interface ethernet eth0 description WAN

# Custom MAC
set interface ethernet eth0 mac 'cc:ef:48:6e:ed:bb'

# IPv4
set interface ethernet eth0 address dhcp

# IPv6
set interface ethernet eth0 address dhcpv6
set interface ethernet eth0 ipv6 address autoconf
set interface ethernet eth0 dhcpv6-options duid '00:03:00:01:cc:ef:48:6e:ed:bb'

commit comment 'interface: Configure WAN interface'
save



########################
### NAT (Masquerade) ###
########################

echo "Configuring: NAT..."

# NAT
set nat source rule 100 outbound-interface name 'eth0'
set nat source rule 100 source address '10.0.0.0/8'
set nat source rule 100 translation address 'masquerade'

# NAT66
set nat66 source rule 100 outbound-interface name 'eth0'
set nat66 source rule 100 source prefix 'fdab:d9c3:fb50::/48'
set nat66 source rule 100 translation address 'masquerade'

commit comment 'nat: Configure NAT and NAT66'
save



#########################
### VLAN-aware bridge ###
#########################

echo "Configuring: VLAN-aware bridge..."

# Enable VLAN
set interface bridge br0 enable-vlan

# eth1 (Infra)
set interface bridge br0 member interface eth1 native-vlan 10

# eth2 (Yongj-PC)
set interface bridge br0 member interface eth2 native-vlan 20

# eth3 (AP)
set interface bridge br0 member interface eth3 native-vlan 5   # Set default VLAN ID
set interface bridge br0 member interface eth3 allowed-vlan 20 # Set allowed VLAN ID
set interface bridge br0 member interface eth3 allowed-vlan 30
set interface bridge br0 member interface eth3 allowed-vlan 70
set interface bridge br0 member interface eth3 allowed-vlan 80
set interface bridge br0 member interface eth3 allowed-vlan 90
set interface bridge br0 member interface eth3 allowed-vlan 99

# eth4 (Agnes-PC)
set interface bridge br0 member interface eth4 native-vlan 30

# eth5 (Printer)
set interface bridge br0 member interface eth5 native-vlan 80

# Set subnet for VLANs
set interface bridge br0 vif 5 address '10.5.0.1/16'   # Network
set interface bridge br0 vif 5 address 'fdab:d9c3:fb50:5::1/64'

set interface bridge br0 vif 10 address '10.10.0.1/16' # Infra
set interface bridge br0 vif 10 address 'fdab:d9c3:fb50:10::1/64'

set interface bridge br0 vif 20 address '10.20.0.1/16' # Admin
set interface bridge br0 vif 20 address 'fdab:d9c3:fb50:20::1/64'

set interface bridge br0 vif 30 address '10.30.0.1/16' # Family
set interface bridge br0 vif 30 address 'fdab:d9c3:fb50:30::1/64'

set interface bridge br0 vif 70 address '10.70.0.1/16' # Trusted
set interface bridge br0 vif 70 address 'fdab:d9c3:fb50:70::1/64'

set interface bridge br0 vif 80 address '10.80.0.1/16' # IoT
set interface bridge br0 vif 80 address 'fdab:d9c3:fb50:80::1/64'

set interface bridge br0 vif 90 address '10.90.0.1/16' # Guest
set interface bridge br0 vif 90 address 'fdab:d9c3:fb50:90::1/64'

set interface bridge br0 vif 99 address '10.99.0.1/16' # Limbo
set interface bridge br0 vif 99 address 'fdab:d9c3:fb50:99::1/64'

commit comment 'interface: Configure VLAN-aware bridge and bridge subnets'
save



###############################
### IPv6 Router Advert (RA) ###
###############################

echo "Configuring: IPv6 Router Advert (RA)..."

# VLAN 5 (Network)
set service router-advert interface br0.5 prefix fdab:d9c3:fb50:5::/64
set service router-advert interface br0.5 name-server 2a07:a8c0::ef:3c69
set service router-advert interface br0.5 name-server 2a07:a8c1::ef:3c69
set service router-advert interface br0.5 dnssl 'internal.darak.dev'

# VLAN 10 (Infra)
set service router-advert interface br0.10 prefix fdab:d9c3:fb50:10::/64
set service router-advert interface br0.10 name-server 2a07:a8c0::ef:3c69
set service router-advert interface br0.10 name-server 2a07:a8c1::ef:3c69
set service router-advert interface br0.10 dnssl 'internal.darak.dev'

# VLAN 20 (Admin)
set service router-advert interface br0.20 prefix fdab:d9c3:fb50:20::/64
set service router-advert interface br0.20 name-server 2a07:a8c0::12:2774
set service router-advert interface br0.20 name-server 2a07:a8c1::12:2774
set service router-advert interface br0.20 dnssl 'internal.darak.dev'

# VLAN 30 (Family)
set service router-advert interface br0.30 prefix fdab:d9c3:fb50:30::/64
set service router-advert interface br0.30 name-server 2a07:a8c0::59:cb3b
set service router-advert interface br0.30 name-server 2a07:a8c1::59:cb3b
set service router-advert interface br0.30 dnssl 'internal.darak.dev'

# VLAN 70 (Trusted)
set service router-advert interface br0.70 prefix fdab:d9c3:fb50:70::/64
set service router-advert interface br0.70 name-server 2a07:a8c0::4d:fa1f
set service router-advert interface br0.70 name-server 2a07:a8c1::4d:fa1f
set service router-advert interface br0.70 dnssl 'internal.darak.dev'

# VLAN 80 (IoT)
set service router-advert interface br0.80 prefix fdab:d9c3:fb50:80::/64
set service router-advert interface br0.80 name-server 2a07:a8c0::5a:4515
set service router-advert interface br0.80 name-server 2a07:a8c1::5a:4515
set service router-advert interface br0.80 dnssl 'internal.darak.dev'

# VLAN 90 (Guest)
set service router-advert interface br0.90 prefix fdab:d9c3:fb50:90::/64
set service router-advert interface br0.90 name-server 2a07:a8c0::4d:fa1f
set service router-advert interface br0.90 name-server 2a07:a8c1::4d:fa1f
set service router-advert interface br0.90 dnssl 'internal.darak.dev'

# VLAN 99 (Limbo)
set service router-advert interface br0.99 prefix fdab:d9c3:fb50:99::/64
set service router-advert interface br0.99 name-server fdab:d9c3:fb50:99::1

commit comment 'router-advert: Configure IPv6 RA (prefix, nameserver)'
save



########################
### DHCP (IPv4 Only) ###
########################

echo "Configuring: DHCP (IPv4 Only)..."

# VLAN 10 (Infra)
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 subnet-id 10

set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option default-router 10.10.0.1
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option name-server 45.90.28.99
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option name-server 45.90.30.99
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 range 0 start 10.10.50.100
set service dhcp-server shared-network-name VLAN10 subnet 10.10.0.0/16 range 0 stop 10.10.50.250

# VLAN 20 (Admin)
set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 subnet-id 20

set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 option default-router 10.20.0.1
set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 option name-server 45.90.28.18
set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 option name-server 45.90.30.18
set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 range 0 start 10.20.20.100
set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 range 0 stop 10.20.20.250

# VLAN 30 (Family)
set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 subnet-id 30

set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 option default-router 10.30.0.1
set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 option name-server 45.90.28.25
set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 option name-server 45.90.30.25
set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 range 0 start 10.30.20.100
set service dhcp-server shared-network-name VLAN30 subnet 10.30.0.0/16 range 0 stop 10.30.20.250

# VLAN 70 (Trusted)
set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 subnet-id 70

set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 option default-router 10.70.0.1
set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 option name-server 45.90.28.227
set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 option name-server 45.90.30.227
set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 range 0 start 10.70.20.100
set service dhcp-server shared-network-name VLAN70 subnet 10.70.0.0/16 range 0 stop 10.70.20.250

# VLAN 80 (IoT)
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 subnet-id 80

set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 option default-router 10.80.0.1
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 option name-server 45.90.28.222
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 option name-server 45.90.30.222
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 range 0 start 10.80.20.100
set service dhcp-server shared-network-name VLAN80 subnet 10.80.0.0/16 range 0 stop 10.80.20.250

# VLAN 90 (Guest)
set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 subnet-id 90

set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 option default-router 10.90.0.1
set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 option name-server 45.90.28.227
set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 option name-server 45.90.30.227
set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 option domain-name 'internal.darak.dev'

set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 range 0 start 10.90.20.100
set service dhcp-server shared-network-name VLAN90 subnet 10.90.0.0/16 range 0 stop 10.90.20.250

# VLAN 99 (Limbo)
set service dhcp-server shared-network-name VLAN99 subnet 10.99.0.0/16 subnet-id 99

set service dhcp-server shared-network-name VLAN99 subnet 10.99.0.0/16 option default-router 10.99.0.1
set service dhcp-server shared-network-name VLAN99 subnet 10.99.0.0/16 option name-server 10.99.0.1

set service dhcp-server shared-network-name VLAN99 subnet 10.99.0.0/16 range 0 start 10.99.20.100
set service dhcp-server shared-network-name VLAN99 subnet 10.99.0.0/16 range 0 stop 10.99.20.250

# Automatically update the system hosts file with DHCP client leases
set service dhcp-server hostfile-update

commit comment 'dhcp-server: Configure DHCP server'
save



################
### Firewall ###
################

echo "Configuring: Firewall..."

# ==================================================
# 0. Global State Policy (Stateful Inspection)
# ==================================================

# Automatically allows return traffic for established connections.
set firewall global-options state-policy established action 'accept'
set firewall global-options state-policy related action 'accept'

# ==================================================
# 1. Common Network / Port Groups
# ==================================================

# VLANs
set firewall group network-group VLAN5 network '10.5.0.0/16'   # Network
set firewall group network-group VLAN7 network '10.7.0.0/16'   # VPN
set firewall group network-group VLAN10 network '10.10.0.0/16' # Infra
set firewall group network-group VLAN20 network '10.20.0.0/16' # Admin
set firewall group network-group VLAN30 network '10.30.0.0/16' # Family
set firewall group network-group VLAN70 network '10.70.0.0/16' # Trusted Guest
set firewall group network-group VLAN80 network '10.80.0.0/16' # IoT
set firewall group network-group VLAN90 network '10.90.0.0/16' # Guest
set firewall group network-group VLAN99 network '10.99.0.0/16' # Limbo

set firewall group ipv6-network-group VLAN5_V6 network 'fdab:d9c3:fb50:5::/64'   # Network
set firewall group ipv6-network-group VLAN7_V6 network 'fdab:d9c3:fb50:7::/64'   # VPN
set firewall group ipv6-network-group VLAN10_V6 network 'fdab:d9c3:fb50:10::/64' # Infra
set firewall group ipv6-network-group VLAN20_V6 network 'fdab:d9c3:fb50:20::/64' # Admin
set firewall group ipv6-network-group VLAN30_V6 network 'fdab:d9c3:fb50:30::/64' # Family
set firewall group ipv6-network-group VLAN70_V6 network 'fdab:d9c3:fb50:70::/64' # Trusted Guest
set firewall group ipv6-network-group VLAN80_V6 network 'fdab:d9c3:fb50:80::/64' # IoT
set firewall group ipv6-network-group VLAN90_V6 network 'fdab:d9c3:fb50:90::/64' # Guest
set firewall group ipv6-network-group VLAN99_V6 network 'fdab:d9c3:fb50:99::/64' # Limbo

# Internal interface
set firewall group interface-group LOCAL_INTERFACES interface 'br0.5'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.7'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.10'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.20'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.30'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.70'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.80'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.90'
set firewall group interface-group LOCAL_INTERFACES interface 'br0.99'

# Bare-Metal Nodes
set firewall group address-group PVE_NODE_01 address '10.10.10.10'
set firewall group address-group PVE_NODE_02 address '10.10.10.20'
set firewall group address-group PVE_NODE_03 address '10.10.10.30'
set firewall group address-group PVE_NODE_04 address '10.10.10.40'
set firewall group address-group FILE_NODE_01 address '10.10.10.50'
set firewall group address-group PI_NODE_01 address '10.10.10.60'

set firewall group ipv6-address-group PVE_NODE_01_V6 address 'fdab:d9c3:fb50:10::10:10'
set firewall group ipv6-address-group PVE_NODE_02_V6 address 'fdab:d9c3:fb50:10::10:20'
set firewall group ipv6-address-group PVE_NODE_03_V6 address 'fdab:d9c3:fb50:10::10:30'
set firewall group ipv6-address-group PVE_NODE_04_V6 address 'fdab:d9c3:fb50:10::10:40'
set firewall group ipv6-address-group FILE_NODE_01_V6 address 'fdab:d9c3:fb50:10::10:50'
set firewall group ipv6-address-group PI_NODE_01_V6 address 'fdab:d9c3:fb50:10::10:60'

# VM Nodes
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.11'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.12'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.21'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.22'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.31'
set firewall group address-group ROCKY_K3S_NODES address '10.10.20.32'
set firewall group address-group ROCKY_DOCKER_01 address '10.10.20.41'

set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10::20:11'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10::20:12'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10::20:21'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10::20:22'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10::20:31'
set firewall group ipv6-address-group ROCKY_K3S_NODES_V6 address 'fdab:d9c3:fb50:10::20:32'
set firewall group ipv6-address-group ROCKY_DOCKER_01_V6 address 'fdab:d9c3:fb50:10::20:41'

# VPN Definition
set firewall group network-group ADMIN_VPN_RANGE network '10.7.10.0/24'
set firewall group ipv6-network-group ADMIN_VPN_RANGE_V6 network 'fdab:d9c3:fb50:7:10::/80'

# Target internal networks accessible from Admin VPN (VLAN 7)
set firewall group network-group ADMIN_DESTINATIONS network '10.5.0.0/16'
set firewall group network-group ADMIN_DESTINATIONS network '10.10.0.0/16'
set firewall group network-group ADMIN_DESTINATIONS network '10.20.0.0/16'
set firewall group network-group ADMIN_DESTINATIONS network '10.30.0.0/16'
set firewall group network-group ADMIN_DESTINATIONS network '10.80.0.0/16'

set firewall group ipv6-network-group ADMIN_DESTINATIONS_V6 network 'fdab:d9c3:fb50:5::/64'
set firewall group ipv6-network-group ADMIN_DESTINATIONS_V6 network 'fdab:d9c3:fb50:10::/64'
set firewall group ipv6-network-group ADMIN_DESTINATIONS_V6 network 'fdab:d9c3:fb50:20::/64'
set firewall group ipv6-network-group ADMIN_DESTINATIONS_V6 network 'fdab:d9c3:fb50:30::/64'
set firewall group ipv6-network-group ADMIN_DESTINATIONS_V6 network 'fdab:d9c3:fb50:80::/64'

# Total private address space used for default-drop Inter-VLAN isolation
set firewall group network-group INTERNAL_NETWORKS network '10.0.0.0/8'
set firewall group ipv6-network-group INTERNAL_NETWORKS_V6 network 'fdab:d9c3:fb50::/48'

# Printer Assets
set firewall group address-group PRINTER_IP address '10.80.0.100'
set firewall group ipv6-address-group PRINTER_IP_V6 address 'fdab:d9c3:fb50:80::100'

set firewall group port-group PRINTER_PORTS port '9100'
set firewall group port-group PRINTER_PORTS port '631'

set firewall group network-group TRUSTED_PRINT_SOURCES network '10.10.0.0/16'
set firewall group network-group TRUSTED_PRINT_SOURCES network '10.30.0.0/16'
set firewall group ipv6-network-group TRUSTED_PRINT_SOURCES_V6 network 'fdab:d9c3:fb50:10::/64'
set firewall group ipv6-network-group TRUSTED_PRINT_SOURCES_V6 network 'fdab:d9c3:fb50:30::/64'

# RADIUS Configuration
set firewall group port-group RADIUS_PORTS port '1812'
set firewall group port-group RADIUS_PORTS port '1813'

# ==================================================
# 2. Input Filter (Traffic destination: Router)
# ==================================================

# Rule 10: IPv4 WAN DHCP Client Response (UDP 68)
set firewall ipv4 input filter rule 10 action 'accept'
set firewall ipv4 input filter rule 10 description 'Allow WAN IPv4 DHCP Client Inbound'
set firewall ipv4 input filter rule 10 inbound-interface name 'eth0'
set firewall ipv4 input filter rule 10 destination port '68'
set firewall ipv4 input filter rule 10 protocol 'udp'

# Rule 10: IPv6 WAN DHCPv6 Client Response (UDP 546)
set firewall ipv6 input filter rule 10 action 'accept'
set firewall ipv6 input filter rule 10 description 'Allow WAN IPv6 DHCPv6 Client Inbound'
set firewall ipv6 input filter rule 10 inbound-interface name 'eth0'
set firewall ipv6 input filter rule 10 destination port '546'
set firewall ipv6 input filter rule 10 protocol 'udp'

# Rule 20: Allow WireGuard VPN ingress from WAN
set firewall ipv4 input filter rule 20 action 'accept'
set firewall ipv4 input filter rule 20 description 'Allow WireGuard VPN from WAN'
set firewall ipv4 input filter rule 20 protocol 'udp'
set firewall ipv4 input filter rule 20 destination port '51820'

set firewall ipv6 input filter rule 20 action 'accept'
set firewall ipv6 input filter rule 20 description 'Allow WireGuard VPN from WAN'
set firewall ipv6 input filter rule 20 protocol 'udp'
set firewall ipv6 input filter rule 20 destination port '51820'

# Rule 30: Allow DNS and NTP from internal subnets
set firewall ipv4 input filter rule 30 action 'accept'
set firewall ipv4 input filter rule 30 description 'Allow Local Infrastructure Services'
set firewall ipv4 input filter rule 30 source group network-group 'INTERNAL_NETWORKS'
set firewall ipv4 input filter rule 30 destination port '53,123'
set firewall ipv4 input filter rule 30 protocol 'udp'

set firewall ipv6 input filter rule 30 action 'accept'
set firewall ipv6 input filter rule 30 description 'Allow Local IPv6 Infrastructure Services'
set firewall ipv6 input filter rule 30 source group network-group 'INTERNAL_NETWORKS_V6'
set firewall ipv6 input filter rule 30 destination port '53,123'
set firewall ipv6 input filter rule 30 protocol 'udp'

# Rule 31: Allow ICMP (Ping)
set firewall ipv4 input filter rule 31 action 'accept'
set firewall ipv4 input filter rule 31 description 'Allow ICMP Ping'
set firewall ipv4 input filter rule 31 protocol 'icmp'

set firewall ipv6 input filter rule 31 action 'accept'
set firewall ipv6 input filter rule 31 description 'Allow ICMP Ping'
set firewall ipv6 input filter rule 31 protocol 'icmpv6'

# Rule 32: Allow DHCP requests from internal interfaces
set firewall ipv4 input filter rule 32 action 'accept'
set firewall ipv4 input filter rule 32 description 'Allow DHCP Server Ingress from LAN'
set firewall ipv4 input filter rule 32 inbound-interface group 'LOCAL_INTERFACES'
set firewall ipv4 input filter rule 32 destination port '67'
set firewall ipv4 input filter rule 32 protocol 'udp'

set firewall ipv6 input filter rule 32 action 'accept'
set firewall ipv6 input filter rule 32 description 'Allow DHCPv6 Server Ingress from LAN'
set firewall ipv6 input filter rule 32 inbound-interface group 'LOCAL_INTERFACES'
set firewall ipv6 input filter rule 32 destination port '546,547'
set firewall ipv6 input filter rule 32 protocol 'udp'

# Rule 40: Allow Router SSH Management ONLY from Admin VLAN 20
set firewall ipv4 input filter rule 40 action 'accept'
set firewall ipv4 input filter rule 40 description 'Allow SSH Management from Admin VLAN'
set firewall ipv4 input filter rule 40 source group network-group 'VLAN20'
set firewall ipv4 input filter rule 40 destination port '22'
set firewall ipv4 input filter rule 40 protocol 'tcp'

set firewall ipv6 input filter rule 40 action 'accept'
set firewall ipv6 input filter rule 40 description 'Allow SSH Management from Admin VLAN'
set firewall ipv6 input filter rule 40 source group network-group 'VLAN20_V6'
set firewall ipv6 input filter rule 40 destination port '22'
set firewall ipv6 input filter rule 40 protocol 'tcp'

# Rule 41: Allow Router SSH Management ONLY from Admin VPN (VLAN 7)
set firewall ipv4 input filter rule 41 action 'accept'
set firewall ipv4 input filter rule 41 description 'Allow SSH Management from VPN'
set firewall ipv4 input filter rule 41 source group network-group 'ADMIN_VPN_RANGE'
set firewall ipv4 input filter rule 41 destination port '22'
set firewall ipv4 input filter rule 41 protocol 'tcp'

set firewall ipv6 input filter rule 41 action 'accept'
set firewall ipv6 input filter rule 41 description 'Allow SSH Management from VPN IPv6'
set firewall ipv6 input filter rule 41 source group network-group 'ADMIN_VPN_RANGE_V6'
set firewall ipv6 input filter rule 41 destination port '22'
set firewall ipv6 input filter rule 41 protocol 'tcp'

# Rule 999: Baseline drop for all unauthorized WAN traffic to the router
set firewall ipv4 input filter rule 999 action 'drop'
set firewall ipv4 input filter rule 999 description 'Drop all other unallowed WAN traffic to Router'

set firewall ipv6 input filter rule 999 action 'drop'
set firewall ipv6 input filter rule 999 description 'Drop all other unallowed WAN traffic to Router'


# ==================================================
# 3. Forward Filter (Traffic destination: Internal Networks)
# ==================================================

# Rule 100: [Admin] VLAN 20 -> Trusted Internal VLANs
set firewall ipv4 forward filter rule 100 action 'accept'
set firewall ipv4 forward filter rule 100 description 'Admin to Trusted VLANs'
set firewall ipv4 forward filter rule 100 source group network-group 'VLAN20'
set firewall ipv4 forward filter rule 100 destination group network-group 'ADMIN_DESTINATIONS'

set firewall ipv6 forward filter rule 100 action 'accept'
set firewall ipv6 forward filter rule 100 description 'Admin to Trusted VLANs'
set firewall ipv6 forward filter rule 100 source group network-group 'VLAN20_V6'
set firewall ipv6 forward filter rule 100 destination group network-group 'ADMIN_DESTINATIONS_V6'

# Rule 110: [Admin VPN] VLAN 7 -> Trusted Internal VLANs
set firewall ipv4 forward filter rule 110 action 'accept'
set firewall ipv4 forward filter rule 110 description 'VPN Specific to Internal VLANs'
set firewall ipv4 forward filter rule 110 source group network-group 'ADMIN_VPN_RANGE'
set firewall ipv4 forward filter rule 110 destination group network-group 'ADMIN_DESTINATIONS'

set firewall ipv6 forward filter rule 110 action 'accept'
set firewall ipv6 forward filter rule 110 description 'VPN Specific to Internal VLANs'
set firewall ipv6 forward filter rule 110 source group network-group 'ADMIN_VPN_RANGE_V6'
set firewall ipv6 forward filter rule 110 destination group network-group 'ADMIN_DESTINATIONS_V6'

# Rule 120: [Printer] Trusted VLANs (10, 30) -> Printer Secure Ports
set firewall ipv4 forward filter rule 120 action 'accept'
set firewall ipv4 forward filter rule 120 description 'Trusted Networks to Printer Secure Ports'
set firewall ipv4 forward filter rule 120 source group network-group 'TRUSTED_PRINT_SOURCES'
set firewall ipv4 forward filter rule 120 destination group address-group 'PRINTER_IP'
set firewall ipv4 forward filter rule 120 protocol 'tcp'
set firewall ipv4 forward filter rule 120 destination group port-group 'PRINTER_PORTS'

set firewall ipv6 forward filter rule 120 action 'accept'
set firewall ipv6 forward filter rule 120 description 'Trusted Networks to Printer Secure Ports'
set firewall ipv6 forward filter rule 120 source group network-group 'TRUSTED_PRINT_SOURCES_V6'
set firewall ipv6 forward filter rule 120 destination group address-group 'PRINTER_IP_V6'
set firewall ipv6 forward filter rule 120 protocol 'tcp'
set firewall ipv6 forward filter rule 120 destination group port-group 'PRINTER_PORTS'

# Rule 121: [Printer] Admin VPN (VLAN 7) -> Printer Secure Ports
set firewall ipv4 forward filter rule 121 action 'accept'
set firewall ipv4 forward filter rule 121 description 'VPN to Printer Secure Ports'
set firewall ipv4 forward filter rule 121 source group network-group 'ADMIN_VPN_RANGE'
set firewall ipv4 forward filter rule 121 destination group address-group 'PRINTER_IP'
set firewall ipv4 forward filter rule 121 protocol 'tcp'
set firewall ipv4 forward filter rule 121 destination group port-group 'PRINTER_PORTS'

set firewall ipv6 forward filter rule 121 action 'accept'
set firewall ipv6 forward filter rule 121 description 'VPN to Printer Secure Ports'
set firewall ipv6 forward filter rule 121 source group network-group 'ADMIN_VPN_RANGE_V6'
set firewall ipv6 forward filter rule 121 destination group address-group 'PRINTER_IP_V6'
set firewall ipv6 forward filter rule 121 protocol 'tcp'
set firewall ipv6 forward filter rule 121 destination group port-group 'PRINTER_PORTS'

# Rule 130: [Ansible] pi-node-01 -> VLAN 5 SSH Management
set firewall ipv4 forward filter rule 130 action 'accept'
set firewall ipv4 forward filter rule 130 description 'Ansible to VLAN5 SSH'
set firewall ipv4 forward filter rule 130 source group address-group 'PI_NODE_01'
set firewall ipv4 forward filter rule 130 destination group network-group 'VLAN5'
set firewall ipv4 forward filter rule 130 protocol 'tcp'
set firewall ipv4 forward filter rule 130 destination port '22'

set firewall ipv6 forward filter rule 130 action 'accept'
set firewall ipv6 forward filter rule 130 description 'Ansible to VLAN5 SSH'
set firewall ipv6 forward filter rule 130 source group address-group 'PI_NODE_01_V6'
set firewall ipv6 forward filter rule 130 destination group network-group 'VLAN5_V6'
set firewall ipv6 forward filter rule 130 protocol 'tcp'
set firewall ipv6 forward filter rule 130 destination port '22'

# Rule 140: [RADIUS] VLAN 5 -> FreeRADIUS Server (Disabled)
#set firewall ipv4 forward filter rule 140 action 'accept'
#set firewall ipv4 forward filter rule 140 description 'VLAN5 to FreeRADIUS'
#set firewall ipv4 forward filter rule 140 source group network-group 'VLAN5'
#set firewall ipv4 forward filter rule 140 destination address '10.20.10.50'# <-- Change to actual FreeRADIUS IP
#set firewall ipv4 forward filter rule 140 protocol 'udp'
#set firewall ipv4 forward filter rule 140 destination group port-group 'RADIUS_PORTS'

#set firewall ipv6 forward filter rule 140 action 'accept'
#set firewall ipv6 forward filter rule 140 description 'VLAN5 to FreeRADIUS'
#set firewall ipv6 forward filter rule 140 source group network-group 'VLAN5_V6'
#set firewall ipv6 forward filter rule 140 destination address 'fdab:d9c3:fb50:10::10:50'# <-- Change to actual FreeRADIUS IP
#set firewall ipv6 forward filter rule 140 protocol 'udp'
#set firewall ipv6 forward filter rule 140 destination group port-group 'RADIUS_PORTS'

# Rule 150: [Matter] IoT (VLAN 80) -> Matter Server (VLAN 10) Ingress
set firewall ipv4 forward filter rule 150 action 'accept'
set firewall ipv4 forward filter rule 150 description 'IoT to Matter Server'
set firewall ipv4 forward filter rule 150 source group network-group 'VLAN80'
set firewall ipv4 forward filter rule 150 destination group address-group 'ROCKY_DOCKER_01'
set firewall ipv4 forward filter rule 150 protocol 'udp'
set firewall ipv4 forward filter rule 150 destination port '5540'

set firewall ipv6 forward filter rule 150 action 'accept'
set firewall ipv6 forward filter rule 150 description 'IoT to Matter Server'
set firewall ipv6 forward filter rule 150 source group network-group 'VLAN80_V6'
set firewall ipv6 forward filter rule 150 destination group address-group 'ROCKY_DOCKER_01_V6'
set firewall ipv6 forward filter rule 150 protocol 'udp'
set firewall ipv6 forward filter rule 150 destination port '5540'

# Rule 160: [Matter] Matter Server (VLAN 10) -> IoT (VLAN 80) Egress
set firewall ipv4 forward filter rule 160 action 'accept'
set firewall ipv4 forward filter rule 160 description 'Matter Server to IoT'
set firewall ipv4 forward filter rule 160 source group address-group 'ROCKY_DOCKER_01'
set firewall ipv4 forward filter rule 160 destination group network-group 'VLAN80'
set firewall ipv4 forward filter rule 160 protocol 'udp'
set firewall ipv4 forward filter rule 160 destination port '5540'

set firewall ipv6 forward filter rule 160 action 'accept'
set firewall ipv6 forward filter rule 160 description 'Matter Server to IoT'
set firewall ipv6 forward filter rule 160 source group address-group 'ROCKY_DOCKER_01_V6'
set firewall ipv6 forward filter rule 160 destination group network-group 'VLAN80_V6'
set firewall ipv6 forward filter rule 160 protocol 'udp'
set firewall ipv6 forward filter rule 160 destination port '5540'

# Rule 160: Drop IoT to Internet
set firewall ipv4 forward filter rule 200 action 'drop'
set firewall ipv4 forward filter rule 200 description 'Drop IoT to Internet'
set firewall ipv4 forward filter rule 200 source group network-group 'VLAN80'
set firewall ipv4 forward filter rule 200 outbound-interface name 'eth0'

set firewall ipv6 forward filter rule 200 action 'drop'
set firewall ipv6 forward filter rule 200 description 'Drop IoT to Internet'
set firewall ipv6 forward filter rule 200 source group network-group 'VLAN80_V6'
set firewall ipv6 forward filter rule 200 outbound-interface name 'eth0'

# Rule 1000: Allow all forwarding traffic from wg0
set firewall ipv4 forward filter rule 1000 action 'accept'
set firewall ipv4 forward filter rule 1000 inbound-interface name 'wg0'

set firewall ipv6 forward filter rule 1000 action 'accept'
set firewall ipv6 forward filter rule 1000 inbound-interface name 'wg0'

# ==================================================
# 4. Final Drop Baseline (Inter-VLAN Isolation Blackhole)
# ==================================================

# Blocks all cross-talk between local subnets within 10.0.0.0/8 unless explicitly permitted above.
set firewall ipv4 forward filter rule 9000 action 'drop'
set firewall ipv4 forward filter rule 9000 description 'Drop Untracked Inter-VLAN Traffic'
set firewall ipv4 forward filter rule 9000 destination group network-group 'INTERNAL_NETWORKS'

set firewall ipv6 forward filter rule 9000 action 'drop'
set firewall ipv6 forward filter rule 9000 description 'Drop Untracked Inter-VLAN Traffic'
set firewall ipv6 forward filter rule 9000 destination group network-group 'INTERNAL_NETWORKS_V6'

commit comment 'firewall: Configure firewall'
save



##################
### DNS Server ###
##################

echo "Configuring: DNS Server..."

# 1. Listen on router internal gateway IPs (VLAN 5 & VLAN 10)
set service dns forwarding listen-address '10.5.0.1'
set service dns forwarding listen-address '10.10.0.1'
set service dns forwarding listen-address '127.0.0.1'

# 2. Allow queries from Infrastructure subnet (where PVE LXCs reside)
set service dns forwarding allow-from '10.10.0.0/16'
set service dns forwarding allow-from '10.5.0.0/16'
set service dns forwarding allow-from '127.0.0.1/32'

commit comment 'dns: Configure internal DNS for PTR requests'
save



########################
### Static IP (IPv4) ###
########################

#echo "Configuring: Static IP (IPv4)..."

#set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 static-mapping Yongj-PC ip-address '10.20.10.100'
#set service dhcp-server shared-network-name VLAN20 subnet 10.20.0.0/16 static-mapping Yongj-PC mac-address '00:11:22:33:44:55'

#commit comment 'dhcp-server: Configure IPv4 static IPs'
#save



###########################
### Static Host Mapping ###
###########################

echo "Configuring: Static Host Mapping..."

# darak-router
set system static-host-mapping host-name 'darak-router.internal.darak.dev' inet '10.5.0.1'
set system static-host-mapping host-name 'darak-router.internal.darak.dev' inet 'fdab:d9c3:fb50:5::1'

# darak-ap-01
set system static-host-mapping host-name 'darak-ap-01.internal.darak.dev' inet '10.5.0.10'
set system static-host-mapping host-name 'darak-ap-01.internal.darak.dev' inet 'fdab:d9c3:fb50:5::10'

# darak-ap-02
set system static-host-mapping host-name 'darak-ap-02.internal.darak.dev' inet '10.5.0.20'
set system static-host-mapping host-name 'darak-ap-02.internal.darak.dev' inet 'fdab:d9c3:fb50:5::20'



# pve-node-01
set system static-host-mapping host-name 'pve-node-01.internal.darak.dev' inet '10.10.10.10'
set system static-host-mapping host-name 'pve-node-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10::10:10'

# pve-node-02
set system static-host-mapping host-name 'pve-node-02.internal.darak.dev' inet '10.10.10.20'
set system static-host-mapping host-name 'pve-node-02.internal.darak.dev' inet 'fdab:d9c3:fb50:10::10:20'

# pve-node-03
set system static-host-mapping host-name 'pve-node-03.internal.darak.dev' inet '10.10.10.30'
set system static-host-mapping host-name 'pve-node-03.internal.darak.dev' inet 'fdab:d9c3:fb50:10::10:30'

# pve-node-04
set system static-host-mapping host-name 'pve-node-04.internal.darak.dev' inet '10.10.10.40'
set system static-host-mapping host-name 'pve-node-04.internal.darak.dev' inet 'fdab:d9c3:fb50:10::10:40'

# file-node-01
set system static-host-mapping host-name 'file-node-01.internal.darak.dev' inet '10.10.10.50'
set system static-host-mapping host-name 'file-node-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10::10:50'

# pi-node-01
set system static-host-mapping host-name 'pi-node-01.internal.darak.dev' inet '10.10.10.60'
set system static-host-mapping host-name 'pi-node-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10::10:60'



# rocky-master-01
set system static-host-mapping host-name 'rocky-master-01.internal.darak.dev' inet '10.10.20.11'
set system static-host-mapping host-name 'rocky-master-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10::20:11'

# rocky-worker-01
set system static-host-mapping host-name 'rocky-worker-01.internal.darak.dev' inet '10.10.20.12'
set system static-host-mapping host-name 'rocky-worker-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10::20:12'

# rocky-master-02
set system static-host-mapping host-name 'rocky-master-02.internal.darak.dev' inet '10.10.20.21'
set system static-host-mapping host-name 'rocky-master-02.internal.darak.dev' inet 'fdab:d9c3:fb50:10::20:21'

# rocky-worker-02
set system static-host-mapping host-name 'rocky-worker-02.internal.darak.dev' inet '10.10.20.22'
set system static-host-mapping host-name 'rocky-worker-02.internal.darak.dev' inet 'fdab:d9c3:fb50:10::20:22'

# rocky-master-03
set system static-host-mapping host-name 'rocky-master-03.internal.darak.dev' inet '10.10.20.31'
set system static-host-mapping host-name 'rocky-master-03.internal.darak.dev' inet 'fdab:d9c3:fb50:10::20:31'

# rocky-worker-03
set system static-host-mapping host-name 'rocky-worker-03.internal.darak.dev' inet '10.10.20.32'
set system static-host-mapping host-name 'rocky-worker-03.internal.darak.dev' inet 'fdab:d9c3:fb50:10::20:32'

# rocky-docker-01
set system static-host-mapping host-name 'rocky-docker-01.internal.darak.dev' inet '10.10.20.41'
set system static-host-mapping host-name 'rocky-docker-01.internal.darak.dev' inet 'fdab:d9c3:fb50:10::20:41'

commit comment 'static-host-mapping: Configure static host mapping'
save



#####################
### mDNS Repeater ###
#####################

echo "Configuring: mDNS Repeater..."

set service mdns repeater interface br0.5
set service mdns repeater interface br0.10
set service mdns repeater interface br0.20
set service mdns repeater interface br0.30
set service mdns repeater interface br0.70
set service mdns repeater interface br0.80
set service mdns repeater interface br0.90

commit comment 'mdns: Enable mDNS repeater on VLANs'
save



###########
### BGP ###
###########

echo "Configuring: BGP..."

# ==================================================
# 1. BGP Security Policies (Prefix-Lists & Route-Maps)
# ==================================================

# Define allowed IPv4 prefixes for K3s Services and Control Plane
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 action 'permit'
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 prefix '10.10.100.0/24'
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 ge 24
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 10 le 32

set policy prefix-list K3S_VIP_ALLOWED_V4 rule 20 action 'permit'
set policy prefix-list K3S_VIP_ALLOWED_V4 rule 20 prefix '10.10.200.1/32'

# Define allowed IPv6 prefixes for K3s Services and Control Plane (ULA Range)
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 action 'permit'
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 prefix 'fdab:d9c3:fb50:10:100::/80'
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 ge 80
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 10 le 128

set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 20 action 'permit'
set policy prefix-list6 K3S_VIP_ALLOWED_V6 rule 20 prefix 'fdab:d9c3:fb50:10:200::1/128'

# Bind Prefix-Lists to a Route-Map for inbound BGP filtering
set policy route-map K3S_INBOUND_FILTER rule 10 action 'permit'
set policy route-map K3S_INBOUND_FILTER rule 10 match ip address prefix-list 'K3S_VIP_ALLOWED_V4'
set policy route-map K3S_INBOUND_FILTER rule 10 match ipv6 address prefix-list 'K3S_VIP_ALLOWED_V6'

# ==================================================
# 2. Global BGP Settings & Dual-Stack ECMP
# ==================================================

# Configure Router's Autonomous System Number
set protocols bgp system-as '64512'

# Enable ECMP (Equal-Cost Multi-Path) up to 64 paths for both address families
set protocols bgp address-family ipv4-unicast maximum-paths ebgp '64'
set protocols bgp address-family ipv6-unicast maximum-paths ebgp '64'
set protocols bgp parameters bestpath as-path multipath-relax

# ==================================================
# 3. K3s Peer-Group Definition (MP-BGP over IPv4 Transport)
# ==================================================

# Create a common BGP Peer-Group for Calico nodes
set protocols bgp peer-group K3S_NODES remote-as '64513'

# Activate IPv4 payload exchange and apply inbound filters
set protocols bgp peer-group K3S_NODES address-family ipv4-unicast route-map import 'K3S_INBOUND_FILTER'
set protocols bgp peer-group K3S_NODES address-family ipv4-unicast soft-reconfiguration inbound

# Activate IPv6 payload exchange (via MP-BGP) and apply inbound filters
set protocols bgp peer-group K3S_NODES address-family ipv6-unicast route-map import 'K3S_INBOUND_FILTER'
set protocols bgp peer-group K3S_NODES address-family ipv6-unicast soft-reconfiguration inbound

# ==================================================
# 4. K3s Node Neighbors Assignment (ROCKY_K3S_NODES)
# ==================================================

# Bind physical node IPv4 addresses to establish the TCP/179 BGP sessions
set protocols bgp neighbor 10.10.20.11 peer-group 'K3S_NODES'
set protocols bgp neighbor 10.10.20.12 peer-group 'K3S_NODES'
set protocols bgp neighbor 10.10.20.21 peer-group 'K3S_NODES'
set protocols bgp neighbor 10.10.20.22 peer-group 'K3S_NODES'
set protocols bgp neighbor 10.10.20.31 peer-group 'K3S_NODES'
set protocols bgp neighbor 10.10.20.32 peer-group 'K3S_NODES'

commit comment 'bgp: Deploy Dual-Stack BGP config with ECMP and K3s prefix limits'
save
