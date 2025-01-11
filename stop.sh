#!/bin/bash
set -x

modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
  
# Re-Bind GPU to Nvidia Driver
virsh nodedev-reattach pci_0000_05_00_1
virsh nodedev-reattach pci_0000_05_00_0

# Re-Bind sata and ethernet
virsh nodedev-reattach pci_0000_04_00_0
virsh nodedev-reattach pci_0000_03_09_0
virsh nodedev-reattach pci_0000_02_00_2
virsh nodedev-reattach pci_0000_02_00_1
virsh nodedev-reattach pci_0000_00_01_2
virsh nodedev-reattach pci_0000_02_00_0

# Reload nvidia modules
modprobe nvidia
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia_drm

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
# Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
#echo 1 > /sys/class/vtconsole/vtcon1/bind

nvidia-xconfig --query-gpu-info > /dev/null 2>&1
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

modprobe nvidia_drm
modprobe nvidia_modeset

modprobe nvidia_uvm
modprobe nvidia

systemctl start display-manager.service
systemctl start sddm
