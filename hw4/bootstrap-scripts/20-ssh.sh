###  vm1/vm2/vm3 allowed SSHing only from 10.10.0.100.

#!/usr/bin/env bash
set -euo pipefail

ROLE="${1:-}"
if [[ -z "$ROLE" ]]; then
  echo "Usage: $0 <role>"
  exit 1
fi

if [[ "$ROLE" == "jumphost" ]]; then
  echo "ℹ️ jumphost: no inbound restriction (it is the entry point)."
  exit 0
fi

sudo mkdir -p /etc/ssh/sshd_config.d

# Restrict SSH by source IP (jumphost internal IP)
sudo tee /etc/ssh/sshd_config.d/99-jumphost-only.conf >/dev/null <<'EOF'
# Allow SSH only from jumphost (internal network)
Match Address 10.10.0.100
  PasswordAuthentication yes

Match all
  PasswordAuthentication no
EOF

# Ensure ssh is running
sudo systemctl restart ssh
sudo systemctl status ssh --no-pager
echo "✅ SSH restricted: only 10.10.0.100 can auth by password"