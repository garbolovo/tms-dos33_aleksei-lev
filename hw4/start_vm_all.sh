#!/bin/bash
# Скрипт “поднять лабу”:
for vm in jumphost vm1 vm2 vm3; do
  VBoxManage startvm "$vm" --type headless
done