# Clear WireGuard  config
delete interfaces wireguard

# WireGuard Base config
set interfaces wireguard wg0 port '51820'
set interfaces wireguard wg0 address '10.7.0.1/16'
set interfaces wireguard wg0 address 'fdab:d9c3:fb50:7::1/64'
set interfaces wireguard wg0 private-key "${WG_PRIVATE_KEY}"

# Peers
for peer in "${WG_PEERS[@]}"; do
    IFS=',' read -r name desc ipv6 ipv4 pk psk <<< "${peer}"

    set interfaces wireguard wg0 peer "${name}" allowed-ips "${ipv6}"
    set interfaces wireguard wg0 peer "${name}" allowed-ips "${ipv4}"
    set interfaces wireguard wg0 peer "${name}" description "${desc}"
    set interfaces wireguard wg0 peer "${name}" preshared-key "${psk}"
    set interfaces wireguard wg0 peer "${name}" public-key "${pk}"
done
