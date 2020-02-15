#!/bin/bash

# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'unbound.sh' created 2020-02-14
# is part of the project/program 'DoTH-DNS'.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Github: https://github.com/Cielquan/
# ======================================================================================

# Based on 'unbound.sh' from https://github.com/MatthewVance/unbound-docker-rpi
# Starting script for unbound container

YEAR=$(date +"%Y")
ISODATE=$(date +"%Y-%m-%d")


mkdir -p /opt/unbound/etc/unbound/dev && \
cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

# shellcheck disable=SC2174
mkdir -p -m 700 /opt/unbound/etc/unbound/var && \
chown _unbound:_unbound /opt/unbound/etc/unbound/var && \
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key


#: Install curl and ipcalc
printf "### Installing 'curl' and 'ipcalc'\n"
apt-get -q update && printf "#####\n" && apt-get -q install -y curl ipcalc


#: Download root.hints file
printf "### Downloading 'root.hints' file\n"
curl -o /opt/unbound/etc/unbound/var/root.hints https://www.internic.net/domain/named.root


#: Get IPs for containers from docker DNS
DOH_SERVER_IP=$(drill @127.0.0.11 doh_server | sed 's/127.0.0.11//g' |
        grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $5}')
printf "### doh_server IP: %s\n" "${DOH_SERVER_IP}"
UNBOUND_IP=$(drill @127.0.0.11 unbound | sed 's/127.0.0.11//g' |
        grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $5}')
printf "### unbound IP: %s\n" "${UNBOUND_IP}"
PIHOLE_IP=$(drill @127.0.0.11 pihole | sed 's/127.0.0.11//g' |
        grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $5}')
printf "### pihole IP: %s\n" "${PIHOLE_IP}"
TRAEFIK_IP=$(drill @127.0.0.11 traefik | sed 's/127.0.0.11//g' |
        grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $5}')
printf "### traefik IP: %s\n" "${TRAEFIK_IP}"

# Add DNS entries for containers to conf file
printf "### Adding 'container-dns.conf' file\n"
cat << EOF > /opt/unbound/etc/unbound/unbound.conf.d/container-dns.conf
# ======================================================================================
# Copyright (c) 2019-${YEAR} Christian Riedel
#
# This file 'container-dns.conf' created ${ISODATE}
# is part of the project/program 'DoTH-DNS'.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Github: https://github.com/Cielquan/
# ======================================================================================

########################################################################################
#          THIS FILE IS AUTOMATICALLY POPULATED BY A SCRIPT ON CONTAINER BOOT          #
#       ANY CHANGES MADE TO THIS FILE AFTER BOOT WILL BE LOST ON THE NEXT REBOOT       #
#                                                                                      #
#                                                                                      #
#                ANY CHANGES SHOULD BE MADE IN A SEPARATE CONFIG FILE:                 #
#           ~/DoTH-DNS/unbound-docker/configs/unbound.conf.d/<filename.conf>           #
########################################################################################

#: DNS entries for container stack

server:
    # DNS entry for container 'doh_server'
    local-data: "doh_server A ${DOH_SERVER_IP}"
    local-data-ptr: "${DOH_SERVER_IP} doh_server"

    # DNS entry for container 'unbound'
    local-data: "unbound A ${UNBOUND_IP}"
    local-data-ptr: "${UNBOUND_IP} unbound"

    # DNS entry for container 'pihole'
    local-data: "pihole A ${PIHOLE_IP}"
    local-data-ptr: "${PIHOLE_IP} pihole"

    # DNS entry for container 'traefik'
    local-data: "traefik A ${TRAEFIK_IP}"
    local-data-ptr: "${TRAEFIK_IP} traefik"
EOF


#: Get IP with CIDR notation
IP_CIDR=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
#: Get subnetmask with CIDR notation
SUBNETMASK_CIDR=$(ipcalc "${IP_CIDR}" | grep '^Network:' | awk '{print $2}')


#: Add subnet to access-control conf file
printf "### Adding 'access-control.conf' file\n"
cat << EOF > /opt/unbound/etc/unbound/unbound.conf.d/access-control.conf
# ======================================================================================
# Copyright (c) 2019-${YEAR} Christian Riedel
#
# This file 'container-dns.conf' created ${ISODATE}
# is part of the project/program 'DoTH-DNS'.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Github: https://github.com/Cielquan/
# ======================================================================================

########################################################################################
#          THIS FILE IS AUTOMATICALLY POPULATED BY A SCRIPT ON CONTAINER BOOT          #
#       ANY CHANGES MADE TO THIS FILE AFTER BOOT WILL BE LOST ON THE NEXT REBOOT       #
#                                                                                      #
#                                                                                      #
#                ANY CHANGES SHOULD BE MADE IN A SEPARATE CONFIG FILE:                 #
#           ~/DoTH-DNS/unbound-docker/configs/unbound.conf.d/<filename.conf>           #
########################################################################################

#: Restrict 'unbound' access to docker network (other containers)

server:
    access-control: ${SUBNETMASK_CIDR} allow
EOF


#: Start unbound
exec /opt/unbound/sbin/unbound -d -c /opt/unbound/etc/unbound/unbound.conf
