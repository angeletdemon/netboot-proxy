#!/bin/sh
set -e

# Default values
DHCP_RANGE="${DHCP_RANGE:-192.168.0.0}"
NETMASK="${NETMASK:-255.255.255.0}"

# Generate dnsmasq.conf
cat > /etc/dnsmasq.conf <<EOF
# DHCP proxy mode - works alongside existing DHCP server
port=0
log-dhcp
dhcp-range=${DHCP_RANGE},proxy,${NETMASK}

# Enable TFTP server
enable-tftp
tftp-root=/var/lib/tftpboot

# Architecture detection via DHCP option 93 (RFC 4578)
dhcp-match=set:bios,option:client-arch,0
dhcp-match=set:uefi64,option:client-arch,7
dhcp-match=set:uefi64,option:client-arch,9
dhcp-match=set:uefi-arm64,option:client-arch,11

# Boot files by architecture
pxe-service=tag:bios,x86PC,"netboot.xyz (BIOS)",netboot.xyz.kpxe
dhcp-boot=tag:bios,netboot.xyz.kpxe

pxe-service=tag:uefi64,X86-64_EFI,"netboot.xyz (UEFI)",netboot.xyz.efi
dhcp-boot=tag:uefi64,netboot.xyz.efi

pxe-service=tag:uefi-arm64,ARM64_EFI,"netboot.xyz (ARM64)",netboot.xyz-arm64.efi
dhcp-boot=tag:uefi-arm64,netboot.xyz-arm64.efi

# Compatibility with limited routers
dhcp-no-override
EOF

echo "Starting dnsmasq with DHCP_RANGE=${DHCP_RANGE}, NETMASK=${NETMASK}"

exec dnsmasq -k --log-facility=-
