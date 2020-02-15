#!/usr/bin/with-contenv bash

# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file '02-conf-dns.sh' created 2020-02-13
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

# Changes pihole upstream DNS to unbound after setup.
# Done by script so no IP address needs to be fixed beforehand for more dynamic setup.

UNBOUND_IP="$(dig @127.0.0.11 unbound | sed 's/127.0.0.11//g' |
          grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $5}')"

sed -i "s/PIHOLE_DNS_1=.*/PIHOLE_DNS_1=${UNBOUND_IP}#53/" /etc/pihole/setupVars.conf
