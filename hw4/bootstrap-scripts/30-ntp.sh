# vm3 = NTP server, other = client

#!/usr/bin/env bash
set -euo pipefail

ROLE="${1:-}"
if [[ -z "$ROLE" ]]; then
  echo "Usage: $0 <role>"
  exit 1
fi

sudo apt-get update -y
sudo apt-get install -y chrony

if [[ "$ROLE" == "vm3" ]]; then
  # NTP server
  sudo sed -i.bak 's/^pool /# pool /' /etc/chrony/chrony.conf
  # Allow internal subnet
  if ! grep -q '^allow 10.10.0.0/24' /etc/chrony/chrony.conf; then
    echo 'allow 10.10.0.0/24' | sudo tee -a /etc/chrony/chrony.conf >/dev/null
  fi
  sudo systemctl restart chrony
  echo "✅ vm3 configured as NTP server (chrony)"
else
  # NTP client
  sudo sed -i.bak 's/^pool /# pool /' /etc/chrony/chrony.conf
  # Use vm3
  if ! grep -q '^server 10.10.0.20 iburst' /etc/chrony/chrony.conf; then
    echo 'server 10.10.0.20 iburst' | sudo tee -a /etc/chrony/chrony.conf >/dev/null
  fi
  sudo systemctl restart chrony
  echo "✅ ${ROLE} configured as NTP client (server 10.10.0.20)"
fi

chronyc sources -v || true
timedatectl | sed -n '1,12p' || true
