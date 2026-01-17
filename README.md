# netboot-proxy

A lightweight PXE boot server using dnsmasq and [netboot.xyz](https://netboot.xyz). Enables network booting for OS installations without modifying your existing DHCP server.

## Features

- **DHCP Proxy Mode** - Works alongside your existing DHCP server
- **Multi-architecture support** - BIOS, UEFI (x86_64), and ARM64
- **Minimal footprint** - Based on Debian slim with only dnsmasq

## Quick Start

```bash
docker run -d --net=host \
  -e DHCP_RANGE=192.168.1.0 \
  -e NETMASK=255.255.255.0 \
  --name netboot \
  angeletdemon/netboot-proxy
```

**Important:** `--net=host` is required for DHCP proxy and TFTP to work correctly.

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `DHCP_RANGE` | `192.168.0.0` | Network address for DHCP proxy |
| `NETMASK` | `255.255.255.0` | Network mask |

Set these to match your local network. For example, if your network is `10.0.0.0/24`:

```bash
docker run -d --net=host \
  -e DHCP_RANGE=10.0.0.0 \
  -e NETMASK=255.255.255.0 \
  --name netboot \
  angeletdemon/netboot-proxy
```

## How It Works

1. Your existing DHCP server handles IP assignment as normal
2. This container runs as a DHCP proxy, adding PXE boot information to DHCP responses
3. PXE clients receive the boot file location and fetch it via TFTP from this container
4. The netboot.xyz menu loads, allowing selection of various OS installers

## Architecture Detection

The server automatically detects client architecture and serves the appropriate bootloader:

| Architecture | DHCP Option 93 | Boot File |
|-------------|----------------|-----------|
| BIOS (legacy) | 0 | `netboot.xyz.kpxe` |
| UEFI x86_64 | 7, 9 | `netboot.xyz.efi` |
| UEFI ARM64 | 11 | `netboot.xyz-arm64.efi` |

## Building Locally

```bash
git clone https://github.com/angeletdemon/netboot-proxy.git
cd netboot-proxy
docker build -t netboot-proxy .
```

## Troubleshooting

**View logs:**
```bash
docker logs -f netboot
```

**Test TFTP manually:**
```bash
# From another machine on the network
tftp <host-ip>
get netboot.xyz.kpxe
```

**PXE client not booting:**
- Ensure the container host has port 69/udp (TFTP) available
- Check that your network allows broadcast/multicast for DHCP proxy
- Verify the DHCP_RANGE matches your network

## License

MIT
