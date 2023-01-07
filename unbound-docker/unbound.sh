#!/usr/bin/env bash

# Starting script for unbound container

mkdir -p /opt/unbound/etc/unbound/dev && \
cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

# shellcheck disable=SC2174
mkdir -p -m 700 /opt/unbound/etc/unbound/var && \
chown _unbound:_unbound /opt/unbound/etc/unbound/var && \
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key


# Install curl
printf "### Installing 'curl'\n"
apt-get -q update && printf "#####\n" && apt-get -q install -y curl


# Download root.hints file
printf "### Downloading 'root.hints' file\n"
curl -o /opt/unbound/etc/unbound/var/root.hints https://www.internic.net/domain/named.root


# Start unbound
exec /opt/unbound/sbin/unbound -d -c /opt/unbound/etc/unbound/unbound.conf
