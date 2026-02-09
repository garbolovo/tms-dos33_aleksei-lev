#!/usr/bin/env bash
set -euo pipefail

# Adjust as you like
GROUP="devops"
GID="2000"
USER="devops"
UID="2000"

# Create group with fixed GID
if ! getent group "$GROUP" >/dev/null; then
  sudo groupadd -g "$GID" "$GROUP"
fi

# Create user with fixed UID/GID
if ! id "$USER" >/dev/null 2>&1; then
  sudo useradd -m -u "$UID" -g "$GROUP" -s /bin/bash "$USER"
  sudo usermod -aG sudo "$USER"
fi

echo "✅ Ensured user/group: $USER($UID) : $GROUP($GID)"