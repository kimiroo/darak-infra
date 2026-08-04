#!/bin/bash

# 1. Check if SSHPASS environment variable is set
if [ -z "${SSHPASS}" ]; then
    echo "Error: SSHPASS environment variable is not set."
    echo "Please run: export SSHPASS=\"YourActualPassword\""
    exit 1
fi

# 2. Read user and host simultaneously using comma as a separator
# (Read using file descriptor 3 to prevent stdin conflict)
while IFS=, read -r user host pubkeyfile <&3 || [ -n "$user" ]; do
    # Skip empty lines or comments
    [[ -z "$user" || "$user" =~ ^# ]] && continue

    # Trim whitespaces
    user=$(echo "$user" | tr -d '[:space:]')
    host=$(echo "$host" | tr -d '[:space:]')
    pubkeyfile=$(echo "$pubkeyfile" | tr -d '[:space:]')

    echo "Clearing keys on $user@$host..."
    sshpass -e ssh -o StrictHostKeyChecking=no -o PreferredAuthentications=password "$user@$host" "rm -f ~/.ssh/authorized_keys"

    echo "Copying $pubkeyfile to $user@$host..."

    sshpass -e ssh-copy-id -o StrictHostKeyChecking=no -o PreferredAuthentications=password -i "$pubkeyfile" "$user@$host"

done 3< host_user_list.txt

echo "SSH key copy process completed."