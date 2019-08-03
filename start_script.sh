#!/bin/bash


# Import conf file if existing
if [ -f start_script.conf ]; then . start_script.conf && echo "start_script.conf loaded"; fi


# Get argument from script call
ARCHITECTURE=${1:-arm}


# Architecture based settings
if [ "$ARCHITECTURE" == "arm" ]; then
    sed -i 's,mvance/unbound:latest,mvance/unbound-rpi:latest,' docker-compose.yaml
elif [ "$ARCHITECTURE" == "x86" ]; then
    sed -i 's,mvance/unbound-rpi:latest,mvance/unbound:latest,' docker-compose.yaml
    if [ "$(sudo docker images | grep -c 'goofball222/dns-over-https' )" -gt 0 ] && [[ -z "${COMPILE}" ]]; then
        echo "'x86' architecture selected and no local image found for 'goofball222/dns-over-https'.`
        ` Do you want to compile the image? (y => yes):"
        read -r COMPILE
    fi
else
    echo "ERROR! Invalid argument given to script. Only 'arm', 'x86' or none are allowed."
    exit 1
fi


# Get interface for DNS server
if [[ -z "${INTERFACE}" ]]; then
    echo "Please enter your network interface (empty => eth0):"
    read -r INTERFACE
fi
if [[ -z "${INTERFACE}" ]]; then INTERFACE=eth0; fi


# Get host IP
HOST_IP=$(ifconfig "${INTERFACE}" | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')

# Get bit length of host's IP subnet
HOST_IP_W_SUBNET=$(ip -o -4 addr show | grep "${INTERFACE}" | awk '/scope global/ {print $4}')

# Get hostname
HOSTNAME=$(hostname)


# Checking for filled '.env' file.
echo "# Checking for .env file"
if ! [ -f .env ]; then
    if [[ -z "${TIMEZONE}" ]]; then
        echo "Please enter your timezone (empty => Europe/London):"
        read -r TIMEZONE
    fi
    if [[ -z "${PIHOLE_WEBPASSWORD}" ]]; then
        echo "Please enter a password for the pihole web interface (empty for none):"
        read -r PIHOLE_WEBPASSWORD
    fi
    echo -e "HOSTNAME=${HOSTNAME}\nSERVERIP=${HOST_IP}\nVIRTUALHOST=${HOST_IP}\nTIMEZONE=${TZ:=Europe/London}\nPIHOLE_WEBPASSWORD=${PIHOLE_WEBPASSWORD}" > .env \
    && echo "# Created .env file"
else
    echo "# Found .env file"
fi

# Loading env vars
. .env

if [[ -z "${HOSTNAME}" ]] || [[ -z "${SERVERIP}" ]] || [[ -z "${VIRTUALHOST}" ]] || [[ -z "${TIMEZONE}" ]]; then
    echo "ERROR! Please fill nessccessary settings inside '.env' file and restart this script. Only 'PIHOLE_WEBPASSWORD' may be empty."
    exit 1
fi

# Check for at least one certificate and key
echo "# Checking for SSL crt and key"
CERT_COUNT=0
for cert in nginx-docker/certificates/certs/*.crt
do
    if [ -e "$cert" ]; then
        CERT_COUNT=$((CERT_COUNT + 1))
    fi
done

KEY_COUNT=0
for key in nginx-docker/certificates/private/*.key
do
    if [ -e "$key" ]; then
        KEY_COUNT=$((KEY_COUNT + 1))
    fi
done
# TODO: verify the need for 3 crt/key # TODO: are 3 crt realy needed? Maybe w/o CN
if (( CERT_COUNT < 3))  || (( KEY_COUNT < 3 )); then
    echo "ERROR! Add at least one certificate to 'nginx-docker/certificates/certs/' and the matching key to " \
        "'nginx-docker/certificates/' for pi.hole, your HOSTNAME and the server's IP. Then restart the script."
    exit 1
elif ! (( CERT_COUNT = KEY_COUNT )); then
    echo "WARNING! There is an uneven amount of certificates and keys."
else
    echo "# Found SSL crt and key"
fi


# Generate 'dhparam.pem' file if missing.
echo "# Checking for dhparam.pem file"
if ! [ -f ~/docker-pihole-unbound-encrypted/nginx-docker/configs/dhparam.pem ]; then
    echo "ERROR! No 'dhparam.pem' file found. Please add a 'dhparam.pem' file to nginx-docker/configs/. Then restart this script."
    exit 1
else
    echo "# Found dhparam.pem file"
fi


# Auto create lan.list file
echo "# Checking for lan.list file"
if ! [ -f pihole-docker/configs/pihole/lan.list ]; then
    echo "${HOST_IP}      ${HOSTNAME}.dns   ${HOSTNAME}" | sudo tee pihole-docker/configs/pihole/lan.list > /dev/null \
    && echo "# Created lan.list file"
elif ! [ "$(grep -cw 'pihole-docker/configs/pihole/lan.list' -e "$HOST_IP")" -ge 1 ]; then

    echo -e "\n${HOST_IP}      ${HOSTNAME}.dns   ${HOSTNAME}" | sudo tee -a pihole-docker/configs/pihole/lan.list > /dev/null \
    && echo "# Added host to lan.list file"
else
    echo "# Found lan.list file with host entry"
fi


# Auto create setupVars.conf file
echo "# Checking for setupVars.conf file"
if ! [ -f pihole-docker/configs/pihole/setupVars.conf ]; then
    if [ "${PIHOLE_WEBPASSWORD}" == "" ]; then
        PIHOLE_WEBPASSWORD_HASH=""
    else
        PIHOLE_WEBPASSWORD_HASH=$(echo -n "${PIHOLE_WEBPASSWORD}" | sha256sum | awk '{printf "%s",$1 }' | sha256sum | sed 's/  -/ /g')
    fi
    echo -e "PIHOLE_INTERFACE=${INTERFACE}\nIPV4_ADDRESS=${HOST_IP_W_SUBNET}\nIPV6_ADDRESS=\nQUERY_LOGGING=true"`
        `"\nINSTALL_WEB_SERVER=true\nINSTALL_WEB_INTERFACE=true\nLIGHTTPD_ENABLED=true\nWEBPASSWORD=${PIHOLE_WEBPASSWORD_HASH}"`
        `"\nDNSMASQ_LISTENING=single\nPIHOLE_DNS_1=172.16.0.5#53\nDNS_FQDN_REQUIRED=true\nDNS_BOGUS_PRIV=true\nDNSSEC=true"`
        `"\nCONDITIONAL_FORWARDING=false\nBLOCKING_ENABLED=true" | sudo tee pihole-docker/configs/pihole/setupVars.conf \
        | sudo tee pihole-docker/configs/pihole/setupVars.conf.update.bak  > /dev/null \
    && echo "# Created setupVars.conf file"
else
    echo "# Found setupVars.conf file"
fi


# Auto create nginx conf files
echo "# Checking for nginx conf files"
if [ -f nginx-docker/configs/sites-enabled/HOST_IP.conf.template ]; then
    if ! [ -f nginx-docker/configs/sites-enabled/"${HOST_IP}".conf ]; then
        sed -i s/HOST_IP/"${HOST_IP}"/g nginx-docker/configs/sites-enabled/HOST_IP.conf.template
        mv nginx-docker/configs/sites-enabled/HOST_IP.conf.template nginx-docker/configs/sites-enabled/"${HOST_IP}".conf
    else
        rm -f nginx-docker/configs/sites-enabled/HOST_IP.conf.template
    fi
fi
if [ -f nginx-docker/configs/sites-enabled/HOSTNAME.dns.conf.template ];then
    if ! [ -f nginx-docker/configs/sites-enabled/"${HOSTNAME}".dns.conf ]; then
        sed -i s/HOSTNAME/"${HOSTNAME}"/g nginx-docker/configs/sites-enabled/HOSTNAME.dns.conf.template
        mv nginx-docker/configs/sites-enabled/HOSTNAME.dns.conf.template nginx-docker/configs/sites-enabled/"${HOSTNAME}".dns.conf
    else
        rm -f nginx-docker/configs/sites-enabled/HOSTNAME.dns.conf.template
    fi
fi
if [ -f nginx-docker/configs/snippets/cert_HOST_IP.conf.template ]; then
    if ! [ -f nginx-docker/configs/snippets/cert_"${HOST_IP}".conf ]; then
        sed -i s/HOST_IP/"${HOST_IP}"/g nginx-docker/configs/snippets/cert_HOST_IP.conf.template
        mv nginx-docker/configs/snippets/cert_HOST_IP.conf.template nginx-docker/configs/snippets/cert_"${HOST_IP}".conf
    else
        rm -f nginx-docker/configs/snippets/cert_HOST_IP.conf.template
    fi
fi
if [ -f nginx-docker/configs/snippets/cert_HOSTNAME.dns.conf.template ]; then
    if ! [ -f nginx-docker/configs/snippets/cert_"${HOSTNAME}".dns.conf ]; then
        sed -i s/HOSTNAME/"${HOSTNAME}"/g nginx-docker/configs/snippets/cert_HOSTNAME.dns.conf.template
        mv nginx-docker/configs/snippets/cert_HOSTNAME.dns.conf.template nginx-docker/configs/snippets/cert_"${HOSTNAME}".dns.conf
    else
        rm -f nginx-docker/configs/snippets/cert_HOSTNAME.dns.conf.template
    fi
fi
if [ -f nginx-docker/configs/streams/dns-over-tls.template ]; then
    if ! [ -f nginx-docker/configs/streams/dns-over-tls ]; then
        sed -i s/HOST_IP/"${HOST_IP}"/g nginx-docker/configs/streams/dns-over-tls.template
        mv nginx-docker/configs/streams/dns-over-tls.template nginx-docker/configs/streams/dns-over-tls
    else
        rm -f nginx-docker/configs/streams/dns-over-tls.template
    fi
fi
echo "# Found and/or created nginx conf files"


# Compile doh server image
if [ "$COMPILE" == "y" ] || [ "$ARCHITECTURE" == "arm" ] && ! [ "$(sudo docker images | grep -c 'goofball222/dns-over-https' )" -gt 0 ]; then
    VERSION="$(git ls-remote -t --refs  https://github.com/m13253/dns-over-https.git | tail -n1 | awk '{print $2}' | sed 's,refs/tags/v,,')"
    CUR_DIR="$(pwd)"
    echo "# Compiling image for 'goofball222/dns-over-https' for version ${VERSION}"
    sudo apt install -y git &&
    mkdir -p ~/dns-over-https_tmp && cd ~/dns-over-https_tmp &&
    git clone https://github.com/goofball222/dns-over-https.git && cd dns-over-https &&
    echo "$VERSION" | tee 'stable/VERSION' > /dev/null && sudo make
    cd "$CUR_DIR" && rm -rf ~/dns-over-https_tmp

    if ! [ "$(sudo docker images | grep -c 'goofball222/dns-over-https')" -gt 0 ]; then
        echo "ERROR! Compiling failed"
        exit 1
    else
        echo "# Image compiled"
    fi
fi


# Download root.hints file
echo ""
wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints


# Start docker container
echo ""
sudo docker-compose up -d


echo -e "\n####################\n"
echo -e "INFO! Starting docker-pihole-unbound-encrypted.\n"


# Testing unbound-docker
# Check if container started and works; timeout after 1 min
printf 'INFO! Starting up unbound container '
for i in $(seq 1 20); do
    if [ "$(sudo docker inspect -f "{{.State.Health.Status}}" unbound)" == "healthy" ]; then
        printf ' OK'
        break
    else
        sleep 3
        printf '.'
    fi

    if [ "$i" -eq 20 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for unbound to start, check your container logs for more info (\`docker logs unbound\`)"
        printf "INFO! Container health status of 'unbound': " && sudo docker inspect -f {{.State.Health.Status}} unbound
        exit 1
    fi
done;
printf "\nINFO! Container health status of 'unbound': " && sudo docker inspect -f {{.State.Health.Status}} unbound

# Test DNSSEC - The first command should give a status report of SERVFAIL and no IP address. The second should give NOERROR plus an IP address.
TEST=$(sudo docker exec unbound drill sigfail.verteiltesysteme.net @127.0.0.1 -p 53)
if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 0 ] && [ "$(echo "$TEST" | grep -c 'rcode: SERVFAIL')" = 1 ]
then
    TEST=$(sudo docker exec unbound drill sigok.verteiltesysteme.net @127.0.0.1 -p 53)
    if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 1 ] && [ "$(echo "$TEST" | grep -c 'rcode: NOERROR')" = 1 ]
    then
        echo "SUCCESS! DNSSEC works."
    else
        echo "WARNING! DNSSEC fail with second check (positiv check)."
    fi
else
    echo "WARNING! DNSSEC fail with first check (negativ check)."
fi


# Testing pihole-docker
# Check if container started and works; timeout after 1 min
printf '\nINFO! Starting up pihole container '
for i in $(seq 1 20); do
    if [ "$(sudo docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ]; then
        printf ' OK'
        if [[ -z "${PIHOLE_WEBPASSWORD}" ]]; then
            echo -e "\nINFO! $(sudo docker logs pihole 2> /dev/null | grep 'password:') for your pi-hole: https://${HOST_IP}/admin/"
        else
            echo -e "\nINFO! Password from environment: ${PIHOLE_WEBPASSWORD} for your pi-hole: https://${HOST_IP}/admin/"
        fi
        break
    else
        sleep 3
        printf '.'
    fi

    if [ "$i" -eq 20 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for Pi-hole to start, check your container logs for more info (\`docker logs pihole\`)"
        printf "INFO! Container health status of 'pihole': " && sudo docker inspect -f {{.State.Health.Status}} pihole
        exit 1
    fi
done;
printf "INFO! Container health status of 'pihole': " && sudo docker inspect -f {{.State.Health.Status}} pihole

# Check if blocklist setup is finished and when then restore custom conf; timeout after 10 min
printf 'INFO! Waiting for blocklist setup to finish '
for i in $(seq 1 60); do
    if [ "$(sudo docker logs pihole | grep -c "\[services.d\] done.")" -gt 0 ]; then
        printf ' OK'
        printf '\nINFO! Checking for setupVars.conf backup.'
        if [ -f pihole-docker/configs/pihole/setupVars.conf.update.bak ]; then
            sudo cp pihole-docker/configs/pihole/setupVars.conf.update.bak pihole-docker/configs/pihole/setupVars.conf
            sudo docker exec pihole pihole restartdns
            if [[ -z "${PIHOLE_WEBPASSWORD}" ]]; then
                echo -e "\nSUCCESS! Backup found and restored."
            else
                echo -e "\nSUCCESS! Backup found and restored. Set 'WEBPASSWORD' is overwritten by restored settings."
            fi
        else
            echo -e "\nINFO! No backup found."
        fi
        break
    else
        sleep 10
        printf '.'
    fi

    if [ "$i" -eq 60 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for blocklists to set up, check your container logs for more info (\`docker logs pihole\`)"
        exit 1
    fi
done;


# Testing doh_server-docker
# Check if container started and is running; timeout after 1 min
printf '\nINFO! Starting up doh_server container '
for i in $(seq 1 20); do
    if [ "$(sudo docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
        if [ "$(sudo docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
            sleep 5
            printf ' OK'
        fi
        break
    else
        sleep 3
        printf '.'
    fi

    if [ "$i" -eq 20 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for doh_server to start, check your container logs for more info (\`docker logs doh_server\`)"
        printf "INFO! Container health status of 'doh_server': " && sudo docker inspect -f {{.State.Status}} doh_server
        exit 1
    fi
done;
printf "\nINFO! Container health status of 'doh_server': " && sudo docker inspect -f {{.State.Status}} doh_server


# Testing nginx-docker
# Check if container started and is running; timeout after 1 min
printf '\nINFO! Starting up nginx container '
for i in $(seq 1 20); do
    if [ "$(sudo docker inspect -f "{{.State.Status}}" nginx)" == "running" ]; then
        sleep 5
        if [ "$(sudo docker inspect -f "{{.State.Status}}" nginx)" == "running" ]; then
            printf 'OK'
            break
        fi
    else
        sleep 3
        printf '.'
    fi

    if [ "$i" -eq 20 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for nginx to start, check your container logs for more info (\`docker logs nginx\`)"
        printf "INFO! Container health status of 'nginx': " && sudo docker inspect -f {{.State.Status}} nginx
        exit 1
    fi
done;
printf "\nINFO! Container health status of 'nginx': " && sudo docker inspect -f {{.State.Status}} nginx


echo -e "\nSUCCESS! docker-pihole-unbound-encrypted is up and running."
echo -e "\n####################"
