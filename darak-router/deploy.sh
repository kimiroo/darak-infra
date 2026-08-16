#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROUTER="darak-router"
REMOTE_DIR="/tmp/router-config"
KEY_FILE=""
BOOTSTRAP_ARGS=()

# Argument Parsing
while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--comment)
      BOOTSTRAP_ARGS+=("-m" "$2")
      shift 2
      ;;
    -c|--confirm)
      BOOTSTRAP_ARGS+=("-c" "$2") # 괄호 오타 수정
      shift 2
      ;;
    -y|--yes|-d|--non-interactive)
      BOOTSTRAP_ARGS+=("-y")
      shift
      ;;
    -i|--identity|--key)
      KEY_FILE="$2"
      shift 2
      ;;
    -r|--router)
      ROUTER="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [-r user@host] [-i identity_file] [-m 'commit comment'] [-c MINUTES] [-y|-d|--non-interactive]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Prepare SSH identity option if provided
SSH_KEY_ARG=()
if [[ -n "$KEY_FILE" ]]; then
  SSH_KEY_ARG=("-i" "$KEY_FILE")
fi

# Upload configuration directory
echo "Uploading configuration scripts from '$SCRIPT_DIR' to '$ROUTER:$REMOTE_DIR'..."
scp "${SSH_KEY_ARG[@]}" -r "$SCRIPT_DIR/." "$ROUTER:$REMOTE_DIR"

# Execute remote bootstrap script
echo "Executing bootstrap script on router..."

REMOTE_CMD="vbash $REMOTE_DIR/bootstrap.sh"

# Safely escape arguments to preserve spaces and quotes
if [ ${#BOOTSTRAP_ARGS[@]} -gt 0 ]; then
  REMOTE_CMD="$REMOTE_CMD $(printf '%q ' "${BOOTSTRAP_ARGS[@]}")"
fi

ssh "${SSH_KEY_ARG[@]}" -t "$ROUTER" "$REMOTE_CMD"

# Cleanup remote temporary directory
echo "Cleaning up temporary files on router..."
ssh "${SSH_KEY_ARG[@]}" "$ROUTER" "rm -rf $REMOTE_DIR"

echo "Deployment finished successfully!"