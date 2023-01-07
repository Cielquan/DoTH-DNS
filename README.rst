Step guide
##########

1. run build script in doh-docker
2. run htpasswd in traefik-docker/shares/
3. enter DOMAIN and HOST_IP in .env
4. run docker-compose up -d

# Troble with pihole and port 53 in use:

sudo sed -i "s/^#Cache=yes/Cache=no/g" /etc/systemd/resolved.conf
sudo sed -i "s/^#DNSStubListener=yes/DNSStubListener=no/g" /etc/systemd/resolved.conf
# then either reboot or restart systemd-resolved : 
systemctl restart systemd-resolved

# https://blog.sleeplessbeastie.eu/2020/09/11/how-to-start-docker-service-at-system-boot/
# start docker on boot
sudo systemctl enable --now docker

Based on:
# https://www.aaflalo.me/2018/10/tutorial-setup-dns-over-https-server/
# https://www.bentasker.co.uk/documentation/linux/407-building-and-running-your-own-dns-over-https-server
