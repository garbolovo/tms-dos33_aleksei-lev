## The NAT interface supports DHCP (for internet access).
## We only set static IP addresses on the internal network (lab network).

#!/usr/bin/env bash
set -euo pipefail

ROLE="${1:-}"
if [[ -z "$ROLE" ]]; then
  echo "Usage: $0 <role: jumphost|vm1|vm2|vm3>"
  exit 1
fi

# IP mapping (Internal Network)
case "$ROLE" in
  jumphost) IP="10.10.0.100/24" ;;
  vm1)      IP="10.10.0.10/24"  ;;
  vm2)      IP="10.10.0.11/24"  ;;
  vm3)      IP="10.10.0.20/24"  ;;
  *) echo "Unknown role: $ROLE"; exit 1 ;;
esac

sudo hostnamectl set-hostname "$ROLE"

# Detect interfaces: one is NAT (10.0.2.x DHCP), one is Internal (no DHCP yet)
# We'll pick the interface that currently has NO IPv4 as the Internal one.
INTERNAL_IF="$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^en|^eth' | while read -r i; do
  if ! ip -4 addr show "$i" | grep -q 'inet '; then echo "$i"; break; fi
done)"

if [[ -z "$INTERNAL_IF" ]]; then
  echo "❌ Could not detect Internal interface (expected one NIC without IPv4)."
  echo "Run: ip a  (and tell me output)"
  exit 1
fi

echo "✅ Internal IF detected: $INTERNAL_IF → $IP"

sudo tee /etc/netplan/10-lab-internal.yaml >/dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ${INTERNAL_IF}:
      dhcp4: false
      addresses: [${IP}]
EOF

sudo netplan apply
echo "✅ netplan applied"
