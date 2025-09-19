#!/usr/bin/env bash
set -euo pipefail

# Load optional config overrides if present
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${SCRIPT_DIR}/config.sh" ]]; then
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/config.sh"
fi

# Defaults if config.sh not present
ETH_STATIC_IP_CIDR="${ETH_STATIC_IP_CIDR:-192.168.50.2/24}"
ETH_DNS="${ETH_DNS:-8.8.8.8}"
ETH_ROUTE_METRIC="${ETH_ROUTE_METRIC:-100}"

# Discover profiles
ETH_CON=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="ethernet"{print $1; exit}')
mapfile -t WIFI_CONS < <(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wifi"{print $1}')

# Configure Ethernet for isolated, static link to a laptop/PC
# - Static IP (no gateway, never-default) so it never steals internet route
# - High autoconnect priority so it comes up immediately when cable present
if [[ -n "${ETH_CON:-}" ]]; then
  nmcli connection modify "$ETH_CON" autoconnect yes
  nmcli connection modify "$ETH_CON" connection.autoconnect-priority 100
  nmcli connection modify "$ETH_CON" ipv4.method manual
  nmcli connection modify "$ETH_CON" ipv4.addresses "$ETH_STATIC_IP_CIDR"
  nmcli connection modify "$ETH_CON" ipv4.gateway ""                 # no gateway on the private wire
  nmcli connection modify "$ETH_CON" ipv4.dns "$ETH_DNS"
  nmcli connection modify "$ETH_CON" ipv4.never-default yes          # wifi keeps default route
  nmcli connection modify "$ETH_CON" ipv4.route-metric "$ETH_ROUTE_METRIC"
fi

# Wi-Fi stays for internet (fallback / default)
for W in "${WIFI_CONS[@]}"; do
  nmcli connection modify "$W" autoconnect yes || true
  nmcli connection modify "$W" connection.autoconnect-priority 0 || true
  nmcli connection modify "$W" ipv4.method auto || true
  nmcli connection modify "$W" ipv4.never-default no || true
  nmcli connection modify "$W" ipv4.route-metric 600 || true
done

# Re-activate active connections so changes take effect immediately
nmcli -t -f NAME connection show --active | while read -r A; do
  nmcli connection up "$A" || true
done
