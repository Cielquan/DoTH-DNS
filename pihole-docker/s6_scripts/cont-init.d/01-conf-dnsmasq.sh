#!/usr/bin/with-contenv bash

# Script gets called by s6 overlay which setups pihole inside docker container.
# Creates dnsmasq config file adding `lan.list` file and wildcard DNS entry for
# DOMAIN on HOST_IP

YEAR=$(date +"%Y")
ISODATE=$(date +"%Y-%m-%d")

cat << EOF > /etc/dnsmasq.d/02-doth.conf
########################################################################################
#          THIS FILE IS AUTOMATICALLY POPULATED BY A SCRIPT ON CONTAINER BOOT          #
#       ANY CHANGES MADE TO THIS FILE AFTER BOOT WILL BE LOST ON THE NEXT REBOOT       #
#                                                                                      #
#                                                                                      #
#                ANY CHANGES SHOULD BE MADE IN A SEPARATE CONFIG FILE:                 #
#              ~/DoTH-DNS/pihole-docker/configs/dnsmasq.d/<filename.conf>              #
########################################################################################

addn-hosts=/etc/pihole/lan.list
address=/${DOMAIN}/${HOST_IP}
EOF
