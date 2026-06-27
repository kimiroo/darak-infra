#!/bin/bash

# 1. Check if SSHPASS environment variable is set
if [ -z "${SSHPASS}" ]; then
    echo "Error: SSHPASS environment variable is not set."
    echo "Please run: export SSHPASS=\"YourActualPassword\""
    exit 1
fi

# 2. Check if both public key files exist
if [ ! -f ~/.ssh/id_ed25519.pub ] || [ ! -f ~/.ssh/id_ed25519_ansible.pub ]; then
    echo "Error: Required public key files not found in ~/.ssh/"
    exit 1
fi

# 3. Read user and host simultaneously using comma as a separator
# (Read using file descriptor 3 to prevent stdin conflict)
while IFS=, read -r user host <&3 || [ -n "$user" ]; do
    # Skip empty lines or comments
    [[ -z "$user" || "$user" =~ ^# ]] && continue

    # Trim whitespaces
    user=$(echo "$user" | tr -d '[:space:]')
    host=$(echo "$host" | tr -d '[:space:]')

    echo "Clearing keys on $user@$host..."
    sshpass -e ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password "$user@$host" "rm -f ~/.ssh/authorized_keys"

    echo "Copying keys to $user@$host..."

    sshpass -e ssh-copy-id -o StrictHostKeyChecking=no -o PreferredAuthentications=password -i ~/.ssh/id_ed25519.pub "$user@$host"
    sshpass -e ssh-copy-id -o StrictHostKeyChecking=no -o PreferredAuthentications=password -i ~/.ssh/id_ed25519_ansible.pub "$user@$host"

done 3< host_user_list.txt

echo "SSH key copy process completed."