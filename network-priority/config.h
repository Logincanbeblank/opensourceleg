# Private, isolated Ethernet to laptop/PC
ETH_STATIC_IP_CIDR="192.168.50.2/24"   # Pi's IP on eth0
ETH_DNS="8.8.8.8"                      # only used for name resolution on the private link
ETH_ROUTE_METRIC="100"                 # doesn't affect default route since never-default=yes

# Edit these in if, a new subnet layers is needed in the future :)
# Example:
# ETH_STATIC_IP_CIDR="10.10.10.2/24"
# and set pc to 10.10.10.1/24 (no gateway)
