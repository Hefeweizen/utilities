#! /bin/sh
#
# USAGE:
#
# add to .ssh/config
# # Connect via VPN:
# Host bastion*
#   ProxyCommand autoconnect_vpn.sh %h %p
#

VPNNAME="Company VPN"

is_vpn_connected()
{
    scutil --nc status "${VPNNAME}" | head -1 | grep -E '^Connected$' >/dev/null
}

connect_and_wait()
{
    networksetup -connectpppoeservice "${VPNNAME}"      # connect to WIFI

    while ! is_vpn_connected
    do
        sleep 2
    done
}

connect_and_wait

# Tunnel, '%h' and '%p' are passed in
/usr/local/Cellar/netcat/0.7.1/bin/nc "$1" "$2" 2>/dev/null

# Disconnect VPN
#  - not working; fix later
# scutil --nc stop "${VPNNAME}"
