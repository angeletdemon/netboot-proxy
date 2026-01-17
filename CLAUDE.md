# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A lightweight PXE boot server using dnsmasq and netboot.xyz bootloaders. Runs as a DHCP proxy alongside existing DHCP infrastructure.

## Architecture

- **Base:** `debian:bookworm-slim` with dnsmasq
- **Config generation:** `entrypoint.sh` generates `/etc/dnsmasq.conf` at runtime from environment variables
- **Bootloaders:** Downloaded from `boot.netboot.xyz` at build time into `/var/lib/tftpboot`

**Multi-arch support via DHCP option 93:**
- BIOS (arch 0): `netboot.xyz.kpxe`
- UEFI x86_64 (arch 7, 9): `netboot.xyz.efi`
- ARM64 (arch 11): `netboot.xyz-arm64.efi`

## Key Files

- `Dockerfile` - Container build
- `entrypoint.sh` - Generates dnsmasq.conf from env vars and starts dnsmasq
- `README.md` - User documentation

## Build and Test

```bash
# Build
docker build -t netboot-proxy .

# Run (requires --net=host for DHCP/TFTP)
docker run -d --net=host -e DHCP_RANGE=192.168.1.0 --name netboot netboot-proxy

# View logs
docker logs -f netboot
```

## Environment Variables

- `DHCP_RANGE` - Network address (default: `192.168.0.0`)
- `NETMASK` - Network mask (default: `255.255.255.0`)

## Publishing

```bash
# Docker Hub
docker build -t angeletdemon/netboot-proxy .
docker push angeletdemon/netboot-proxy

# GitHub
git push origin main
```
