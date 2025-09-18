#!/usr/bin/env bash
set -euo pipefail

# Find the first ethernet connection profile
ETH_CON=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="ethernet"{print $1; exit}')

# Find all wifi connection profiles
mapfile -t WIFI_CONS < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wifi"{print $1}')

# If we found an Ethernet profile
if [[ -n "${ETH_CON:-}" ]]; then
  # Enable auto-connect so Ethernet connects automatically when plugged
  nmcli connection modify "$ETH_CON" autoconnect yes

  # Set Ethernet to high priority (higher number = more preferred for auto-connect)
  nmcli connection modify "$ETH_CON" connection.autoconnect-priority 100

  # Set route metric lower so routing prefers Ethernet
  nmcli connection modify "$ETH_CON" ipv4.route-metric 100 ipv6.route-metric 100
fi

# For Wi-Fi profiles: still allow them, but make them lower priority
for W in "${WIFI_CONS[@]}"; do
  nmcli connection modify "$W" autoconnect yes
  nmcli connection modify "$W" connection.autoconnect-priority 0
  nmcli connection modify "$W" ipv4.route-metric 600 ipv6.route-metric 600
done

# If any connection is active, re-activate it so changes take effect
nmcli -t -f NAME connection show --active | while read -r A; do
  nmcli connection up "$A" || true
done
