FROM debian:bookworm-slim

# Install dnsmasq and curl
RUN apt-get update && apt-get install -y dnsmasq curl && rm -rf /var/lib/apt/lists/*

# Create TFTP directory and download bootloaders
RUN mkdir -p /var/lib/tftpboot
WORKDIR /var/lib/tftpboot
RUN curl -L https://boot.netboot.xyz/ipxe/netboot.xyz.kpxe -o netboot.xyz.kpxe && \
    curl -L https://boot.netboot.xyz/ipxe/netboot.xyz.efi -o netboot.xyz.efi && \
    curl -L https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o netboot.xyz-arm64.efi

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Environment variables for configuration
ENV DHCP_RANGE=192.168.0.0
ENV NETMASK=255.255.255.0

ENTRYPOINT ["/entrypoint.sh"]
