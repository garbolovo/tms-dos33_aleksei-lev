#!/bin/bash
VBoxManage list runningvms | awk '{print $2}' | tr -d '{}' | while read -r id; do
  VBoxManage controlvm "$id" acpipowerbutton
done
