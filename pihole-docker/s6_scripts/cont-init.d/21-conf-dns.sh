#!/usr/bin/with-contenv bash

# Changes pihole upstream DNS to unbound after setup.

sed -i "s/PIHOLE_DNS_1=.*/PIHOLE_DNS_1=172.16.1.4#53/" /etc/pihole/setupVars.conf
