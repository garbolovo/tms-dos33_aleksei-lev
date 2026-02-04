#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./create-vm.sh bastion
#   ./create-vm.sh vm1
#
# Optional env vars:
#   ISO=/path/to/ubuntu.iso
#   CPUS=2 RAM_MB=4096 DISK_MB=30720
#   INTNET=lab-net HOSTONLY=vboxnet0
#   VM_BASE="$HOME/VirtualBox VMs"

VM_NAME="${1:-}"
if [[ -z "$VM_NAME" ]]; then
  echo "Usage: $0 <vm-name>"
  exit 1
fi

CPUS="${CPUS:-2}"
RAM_MB="${RAM_MB:-4096}"
DISK_MB="${DISK_MB:-30720}"   # 30GB
INTNET="${INTNET:-lab-net}"
HOSTONLY="${HOSTONLY:-vboxnet0}"
ISO="${ISO:-$HOME/Downloads/ubuntu-22.04.5-live-server-amd64.iso}"
VM_BASE="${VM_BASE:-$HOME/VirtualBox VMs}"

need() { command -v "$1" >/dev/null 2>&1 || { echo "❌ Need: $1"; exit 1; }; }
need VBoxManage

if [[ ! -f "$ISO" ]]; then
  echo "❌ ISO not found: $ISO"
  exit 1
fi

# Ensure Host-only interface exists (vboxnet0).
# If it doesn't exist, create one.
if ! VBoxManage list hostonlyifs | grep -q "^Name: *${HOSTONLY}$"; then
  echo "ℹ️ Host-only interface ${HOSTONLY} not found. Creating..."
  VBoxManage hostonlyif create >/dev/null
  # Pick the last created host-only interface name (usually vboxnet0 if first)
  HOSTONLY_CREATED="$(VBoxManage list hostonlyifs | awk '/^Name:/{n=$2} END{print n}')"
  echo "ℹ️ Created: ${HOSTONLY_CREATED}"

  # If the created name is not vboxnet0, we'll just use the created one.
  HOSTONLY="${HOSTONLY_CREATED}"

  # Set host-only IP (for Mac side). You can change if you want.
  # This sets the host-only adapter on macOS host to 192.168.100.1/24
  VBoxManage hostonlyif ipconfig "$HOSTONLY" --ip 192.168.100.1 --netmask 255.255.255.0
fi

# If VM exists, stop
if VBoxManage showvminfo "$VM_NAME" >/dev/null 2>&1; then
  echo "❌ VM already exists: $VM_NAME"
  exit 1
fi

echo "✅ Creating VM: $VM_NAME"
echo "   CPU=$CPUS RAM=${RAM_MB}MB DISK=${DISK_MB}MB"
echo "   Adapter1: Internal Network = $INTNET"
echo "   Adapter2: Host-only = $HOSTONLY"
echo "   ISO: $ISO"
echo

VM_DIR="${VM_BASE}/${VM_NAME}"
VDI_PATH="${VM_DIR}/${VM_NAME}.vdi"
mkdir -p "$VM_DIR"

VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register --basefolder "$VM_BASE"

VBoxManage modifyvm "$VM_NAME" \
  --cpus "$CPUS" \
  --memory "$RAM_MB" \
  --vram 16 \
  --rtcuseutc on \
  --boot1 dvd --boot2 disk --boot3 none --boot4 none \
  --audio none --usb off

# Adapter 1: Internal Network (VM<->VM)
VBoxManage modifyvm "$VM_NAME" \
  --nic1 intnet \
  --intnet1 "$INTNET" \
  --cableconnected1 on

# Adapter 2: Host-only (Mac<->VM, admin network)
VBoxManage modifyvm "$VM_NAME" \
  --nic2 hostonly \
  --hostonlyadapter2 "$HOSTONLY" \
  --cableconnected2 on

# Storage + disk + ISO
VBoxManage createhd --filename "$VDI_PATH" --size "$DISK_MB" --format VDI
VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VDI_PATH"
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$ISO"

# Start GUI installer
VBoxManage startvm "$VM_NAME" --type gui

echo "🚀 Started: $VM_NAME"
echo "Next: install Ubuntu Server and ENABLE OpenSSH server."
