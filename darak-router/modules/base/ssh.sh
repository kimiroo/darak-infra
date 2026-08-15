# Clear SSH server config#
delete service ssh
delete system login user vyos authentication public-keys

# Configure SSH#
set service ssh port 22

# Add SSH public key#
for key_str in "${PUBLIC_KEYS[@]}"; do
    read -r type key name <<< "${key_str}"

    set system login user vyos authentication public-keys "${name}" type "${type}"
    set system login user vyos authentication public-keys "${name}" key "${key}"
done

# Authentication & Security Policies#
set service ssh disable-password-authentication
set service ssh disable-host-validation
set service ssh client-keepalive-interval '30'

# Encryption Ciphers#
set service ssh cipher 'chacha20-poly1305@openssh.com'
set service ssh cipher 'aes256-gcm@openssh.com'
set service ssh cipher 'aes128-gcm@openssh.com'
set service ssh cipher 'aes256-ctr'
set service ssh cipher 'aes192-ctr'
set service ssh cipher 'aes128-ctr'

# Key Exchange Algorithms (Kex)#
set service ssh key-exchange 'curve25519-sha256'
set service ssh key-exchange 'curve25519-sha256@libssh.org'
set service ssh key-exchange 'diffie-hellman-group16-sha512'
set service ssh key-exchange 'diffie-hellman-group18-sha512'
set service ssh key-exchange 'diffie-hellman-group14-sha256'

# Message Authentication Codes (MACs)#
set service ssh mac 'umac-128-etm@openssh.com'
set service ssh mac 'hmac-sha2-256-etm@openssh.com'
set service ssh mac 'hmac-sha2-512-etm@openssh.com'

# Dynamic Brute-Force Protection#
set service ssh dynamic-protection
set service ssh dynamic-protection block-time '300'
set service ssh dynamic-protection detect-time '60'
set service ssh dynamic-protection threshold '3'