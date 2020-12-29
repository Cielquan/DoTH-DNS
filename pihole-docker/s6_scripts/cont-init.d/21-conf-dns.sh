#!/usr/bin/with-contenv bash

# Changes pihole upstream DNS to unbound after setup.
# Done by script so no IP address needs to be fixed beforehand for more dynamic setup.

UNBOUND_IP="$(dig @127.0.0.11 unbound | sed 's/127.0.0.11//g' |
          grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $5}')"

sed -i "s/PIHOLE_DNS_1=.*/PIHOLE_DNS_1=${UNBOUND_IP}#53/" /etc/pihole/setupVars.conf

