#!/usr/bin/with-contenv bash

# ==============================================================================
# Copyright (c) 2019 Christian Riedel
#
# This file 'custom-init.bash' created 2019-11-17 is part of the project/program 'DoTH-DNS'.
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
# ==============================================================================

# Script gets called by s6 overlay which setups pihole inside docker container.
# Appends DoTH-DNS' DOMAIN to dnsmasq's configuration file for wildcard use of domain.
printf "\naddress=/%s/%s" "${DOMAIN}" "${HOST_IP}" >> /etc/dnsmasq.d/02-custom.conf