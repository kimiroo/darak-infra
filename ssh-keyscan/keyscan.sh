#!/bin/bash

HOST_FILE="host_list.txt"
KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"

mkdir -p "$HOME/.ssh"

echo "Starting ssh-keyscan process..."

while IFS= read -r host || [ -n "$host" ]; do
    # Skip empty lines or comments
    [[ -z "$host" || "$host" =~ ^# ]] && continue

    # Trim whitespaces
    host=$(echo "$host" | tr -d '[:space:]')

    echo "Scanning keys for $host..."

    # Remove old keys for this host to prevent duplicates
    ssh-keygen -R "$host" 2>/dev/null

    # Scan and append the new keys directly to known_hosts
    ssh-keyscan -H "$host" >> "$KNOWN_HOSTS_FILE" 2>/dev/null

done < "$HOST_FILE"

echo "ssh-keyscan process completed."