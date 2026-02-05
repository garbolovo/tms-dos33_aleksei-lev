#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./create-vm.sh <vm_name> <role>
# Roles: jumphost | vm1 | vm2 | vm3
#
# Env overrides:
#   ISO=/path/to/ubuntu.iso
#   CPUS=2 RAM_MB=4096 DISK_MB=30720 INTNET=lab-net BASEFOLDER="$HOME/VirtualBox VMs"
#   SSH_FWD_PORT=2222   (only used for jumphost)

VM_NAME="${1:-}"
ROLE="${2:-}"

if [[ -z "$VM_NAME" || -z "$ROLE" ]]; then
  echo "Usage: $0 <vm_name> <role>"
  echo "Example: $0 jumphost jumphost"
  exit 1
fi

command -v VBoxManage >/dev/null 2>&1 || { echo "❌ VBoxManage not found"; exit 1; }

CPUS="${CPUS:-2}"
RAM_MB="${RAM_MB:-4096}"
DISK_MB="${DISK_MB:-30720}"            # 30GB
INTNET="${INTNET:-lab-net}"
BASEFOLDER="${BASEFOLDER:-$HOME/VirtualBox VMs}"
ISO="${ISO:-$HOME/Downloads/ubuntu-22.04.5-live-server-amd64.iso}"
SSH_FWD_PORT="${SSH_FWD_PORT:-2222}"

if [[ ! -f "$ISO" ]]; then
  echo "❌ ISO not found: $ISO"
  exit 1
fi

if VBoxManage showvminfo "$VM_NAME" >/dev/null 2>&1; then
  echo "❌ VM already exists: $VM_NAME"
  exit 1
fi

VM_DIR="${BASEFOLDER}/${VM_NAME}"
VDI_PATH="${VM_DIR}/${VM_NAME}.vdi"
mkdir -p "$VM_DIR"

echo "✅ Creating VM: $VM_NAME (role=$ROLE)"
echo "   CPU=$CPUS RAM=${RAM_MB}MB DISK=${DISK_MB}MB"
echo "   Adapter1: Internal Network = $INTNET"
echo "   Adapter2: NAT"
echo "   ISO: $ISO"
echo

VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register --basefolder "$BASEFOLDER"

VBoxManage modifyvm "$VM_NAME" \
  --cpus "$CPUS" \
  --memory "$RAM_MB" \
  --vram 16 \
  --audio none --usb off \
  --rtcuseutc on \
  --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Adapter 1: Internal Network (VM<->VM)
VBoxManage modifyvm "$VM_NAME" \
  --nic1 intnet \
  --intnet1 "$INTNET" \
  --cableconnected1 on

# Adapter 2: NAT (internet + port-forward only on jumphost)
VBoxManage modifyvm "$VM_NAME" \
  --nic2 nat \
  --cableconnected2 on

# Port forward to jumphost only: host 127.0.0.1:2222 -> guest :22
if [[ "$ROLE" == "jumphost" ]]; then
  VBoxManage modifyvm "$VM_NAME" --natpf2 "ssh,tcp,127.0.0.1,${SSH_FWD_PORT},,22"
  echo "   NAT PF: 127.0.0.1:${SSH_FWD_PORT} -> ${VM_NAME}:22"
fi

# Storage
VBoxManage createhd --filename "$VDI_PATH" --size "$DISK_MB" --format VDI
VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VDI_PATH"
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$ISO"

VBoxManage startvm "$VM_NAME" --type gui
echo "🚀 Started: $VM_NAME"
echo "Reminder: during Ubuntu install ENABLE 'Install OpenSSH server'"
