#!/bin/bash
# Automated installation script for HAProxy and Keepalived on Debian/Ubuntu
# Emulation of Cloud Load Balancing

set -e

# Ensure execution with root privileges
if [ "$EUID" -ne 0 ]; then 
  echo "[!] Please run this script as root (sudo)"
  exit 1
fi

echo "============================================================"
echo " Initializing HAProxy Load Balancer Installation"
echo "============================================================"

# Update package list and install pending updates
echo "[+] Updating system repositories..."
apt-get update -y && apt-get upgrade -y

# Install base dependencies
echo "[+] Installing HAProxy, Keepalived, and utilities (Certbot)..."
apt-get install -y haproxy keepalived certbot psmisc curl iptables-persistent net-tools ufw

# Kernel level configuration (Sysctl)
echo "[+] Optimizing Kernel for high-performance load balancing..."
cat <<EOF > /etc/sysctl.d/99-loadbalancer.conf
# Allow binding to an IP that is not assigned locally (required for Keepalived Floating IP)
net.ipv4.ip_nonlocal_bind=1

# Enable IP forwarding
net.ipv4.ip_forward=1

# Hardening: Protection against TCP SYN flood attacks
net.ipv4.tcp_syncookies=1

# Performance: TIME_WAIT connections optimization
net.ipv4.tcp_max_tw_buckets=1440000
net.ipv4.tcp_tw_reuse=1

# Performance: Increase ephemeral port range for outgoing connections
net.ipv4.ip_local_port_range=1024 65000

# Performance: Increase queued TCP connections limit
net.core.somaxconn=65535
EOF

# Apply kernel changes
sysctl --system

# Configuration directories
echo "[+] Creating directory structure for SSL Certificates..."
mkdir -p /etc/haproxy/certs

echo "============================================================"
echo " Base Installation Completed."
echo "============================================================"
echo "Next Steps:"
echo " 1. Configure Keepalived by copying master.conf or backup.conf to /etc/keepalived/keepalived.conf"
echo " 2. Generate a combined Let's Encrypt certificate (.pem) and place it in /etc/haproxy/certs/site.pem"
echo " 3. Replace the configuration in /etc/haproxy/haproxy.cfg"
echo " 4. Enable the services: systemctl enable --now haproxy keepalived"
echo "============================================================"
