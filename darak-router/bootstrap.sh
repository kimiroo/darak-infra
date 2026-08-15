#!/bin/vbash

# Get script's absolute directory path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default variables
COMMENT="Configured via bootstrap script"
INTERACTIVE=true
COMMIT_CONFIRM=false
COMMIT_CONFIRM_MINUTES=0

# Argument Parsing (Must run BEFORE script-template)
while [[ $# -gt 0 ]]; do
  case "$1" in
    -m|--comment)
      COMMENT="$2"
      shift 2
      ;;
    -c|--confirm)
      COMMIT_CONFIRM_MINUTES="$2"
      COMMIT_CONFIRM=true
      shift 2
      ;;
    -y|--yes|-d|--non-interactive)
      INTERACTIVE=false
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-m 'commit comment'] [-c MINUTES] [-y|-d|--non-interactive]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "Loading configuration..."
source "$SCRIPT_DIR/config.env"

source /opt/vyatta/etc/functions/script-template

echo "Starting configuration..."
configure

# ==========================================
# Load Modules (Stage Configurations)
# ==========================================

# Base
echo '[1/7] Configuring "Base"...'
echo '  - [1/2] Configuring "Base"...'
source "$SCRIPT_DIR/modules/base/base.sh"
echo '  - [2/2] Configuring "SSH"...'
source "$SCRIPT_DIR/modules/base/ssh.sh"

# System
echo '[2/7] Configuring "System"...'
echo '  - [1/1] Configuring "Static Host Mapping"...'
source "$SCRIPT_DIR/modules/system/static_host_mapping.sh"

# Interface
echo '[3/7] Configuring "Interface"...'
echo '  - [1/4] Configuring "WAN"...'
source "$SCRIPT_DIR/modules/interface/wan.sh"
echo '  - [2/4] Configuring "Bridge"...'
source "$SCRIPT_DIR/modules/interface/bridge.sh"
echo '  - [3/4] Configuring "Dummy"...'
source "$SCRIPT_DIR/modules/interface/dummy.sh"
echo '  - [4/4] Configuring "WireGuard"...'
source "$SCRIPT_DIR/modules/interface/wireguard.sh"

# Firewall
echo '[4/7] Configuring "Firewall"...'
echo '  - [1/4] Configuring "Global Rules"...'
source "$SCRIPT_DIR/modules/firewall/global.sh"
echo '  - [2/4] Configuring "Groups"...'
source "$SCRIPT_DIR/modules/firewall/groups.sh"
echo '  - [3/4] Configuring "Input Filter"...'
source "$SCRIPT_DIR/modules/firewall/input.sh"
echo '  - [4/4] Configuring "Forward Filter"...'
source "$SCRIPT_DIR/modules/firewall/forward.sh"

# Service
echo '[5/7] Configuring "Service"...'
echo '  - [1/5] Configuring "DNS"...'
source "$SCRIPT_DIR/modules/service/dns.sh"
echo '  - [2/5] Configuring "Static IP"...'
source "$SCRIPT_DIR/modules/service/static_ip.sh"
echo '  - [3/5] Configuring "DHCP Server"...'
source "$SCRIPT_DIR/modules/service/dhcp.sh"
echo '  - [4/5] Configuring "Router Advert (RA)"...'
source "$SCRIPT_DIR/modules/service/ra.sh"
echo '  - [5/5] Configuring "mDNS"...'
source "$SCRIPT_DIR/modules/service/mdns.sh"

# NAT
echo '[6/7] Configuring "NAT"...'
echo '  - [1/1] Configuring "NAT"...'
source "$SCRIPT_DIR/modules/nat/nat.sh"

# BGP
echo '[7/7] Configuring "BGP"...'
echo '  - [1/2] Configuring "Policy"...'
source "$SCRIPT_DIR/modules/bgp/policy.sh"
echo '  - [2/2] Configuring "BGP Protocol"...'
source "$SCRIPT_DIR/modules/bgp/protocol.sh"

# ==========================================
# Pre-commit Validation (Interactive / Non-interactive)
# ==========================================

if [ "$INTERACTIVE" = true ]; then
  echo ""
  echo "=========================================="
  echo " Configuration Changes (Compare):"
  echo "=========================================="
  PAGER=cat compare
  echo "=========================================="
  echo " Comment: $COMMENT"
  echo "=========================================="

  read -p "Do you want to commit these changes? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Discarding changes and exiting..."
    discard
    exit 0
  fi
fi

# Commit and save configurations
if [ "$COMMIT_CONFIRM" = true ]; then
  echo "Committing changes with confirm timer of ${COMMIT_CONFIRM_MINUTES} minute(s): '$COMMENT'..."
  commit-confirm "$COMMIT_CONFIRM_MINUTES" comment "$COMMENT (bootstrap script)"
  save
else
  echo "Committing changes with comment: '$COMMENT'..."
  commit comment "$COMMENT (bootstrap script)"
  save
fi

exit