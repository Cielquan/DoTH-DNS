#!/usr/bin/with-contenv bash

# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file '01-conf-dnsmasq.sh' created 2019-11-17
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

# Script gets called by s6 overlay which setups pihole inside docker container.
# Creates dnsmasq config file adding `lan.list` file and wildcard DNS entry for
# DOMAIN on HOST_IP

YEAR=$(date +"%Y")
ISODATE=$(date +"%Y-%m-%d")

cat << EOF > /etc/dnsmasq.d/02-doth.conf
# ======================================================================================
# Copyright (c) 2019-${YEAR} Christian Riedel
#
# This file '02-doth.conf' created ${ISODATE}
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
#              ~/DoTH-DNS/pihole-docker/configs/dnsmasq.d/<filename.conf>              #
########################################################################################

addn-hosts=/etc/pihole/lan.list
address=/${DOMAIN}/${HOST_IP}
EOF
