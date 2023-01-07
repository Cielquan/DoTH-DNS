#!/usr/bin/env bash

# Script gets called by s6 overlay which setups pihole inside docker container.
# Creates dnsmasq config file adding `lan.list` file and wildcard DNS entry for
# DOMAIN on HOST_IP

cat << EOF > /etc/dnsmasq.d/02-doth.conf
########################################################################################
#          THIS FILE IS AUTOMATICALLY POPULATED BY A SCRIPT ON CONTAINER BOOT          #
#       ANY CHANGES MADE TO THIS FILE AFTER BOOT WILL BE LOST ON THE NEXT REBOOT       #
#                                                                                      #
#                                                                                      #
#    ANY CHANGES SHOULD BE MADE IN A SEPARATE CONFIG FILE IN THE CONFIG DIRECTORY:     #
#               DoTH-DNS/pihole-docker/configs/dnsmasq.d/<filename.conf>               #
########################################################################################

# List with DNS entries in LAN
addn-hosts=/etc/pihole/lan.list

# Map used domain with host IP
address=/${DOMAIN}/${HOST_IP}

# CNAME entries for all used subdomains
cname=doh.${DOMAIN},${DOMAIN}
cname=dot.${DOMAIN},${DOMAIN}
cname=pihole.${DOMAIN},${DOMAIN}
cname=pi.hole,pihole.${DOMAIN}
cname=traefik.${DOMAIN},${DOMAIN}
EOF
