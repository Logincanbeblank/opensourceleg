#!/usr/bin/env bash
set -euo pipefail

echo "[+] Installing Network Priority: Prefer Ethernet"

# Copy the script into place
sudo install -m 0755 network-priority/prefer-ethernet.sh /usr/local/bin/prefer-ethernet.sh

# Copy the service file
sudo install -m 0644 network-priority/prefer-ethernet.service /etc/systemd/system/prefer-ethernet.service

# Make sure permissions are OK
sudo chmod +x /usr/local/bin/prefer-ethernet.sh

# Reload systemd so it sees the new service
sudo systemctl daemon-reload

# Enable and start the service now
sudo systemctl enable --now prefer-ethernet.service

echo "[+] Installation done. You can verify with:"
echo "    nmcli -g NAME,TYPE,CONNECTION.AUTOCONNECT-PRIORITY connection show"
echo "    nmcli -g NAME,IP4.GATEWAY,IP4.ROUTE-METRIC connection show"
echo "    ip route"
