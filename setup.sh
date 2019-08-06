#!/bin/bash


# Exit func for errors
exit_err() {
  echo "Please correct the error and restart the script."
  exit 1
}

echo -e "\n####################\n"
echo -e "INFO! Starting setup for docker-pihole-unbound-encrypted.\n"


# Import setup.conf file if existing
[ -f setup.conf ] && . setup.conf && echo "INFO! setup.conf loaded"


# Get architecture if not set
[ -z "${ARCHITECTURE}" ] && ARCHITECTURE=$(lscpu | grep Architecture: | awk '{print $2}')
if [ -z "${ARCHITECTURE}" ]; then
  echo "ERROR! No ARCHITECTURE set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo "INFO! No ARCHITECTURE set found and using ${ARCHITECTURE}"
fi

# Get default interface if not set
[ -z "${INTERFACE}" ] && INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')
if [ -z "${INTERFACE}" ]; then
  echo "ERROR! No INTERFACE set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo "INFO! No INTERFACE set found and using ${INTERFACE}"
fi

# Get IP for given INTERFACE if not set
[ -z "${HOST_IP}" ] && HOST_IP=$(ifconfig "${INTERFACE}" | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
if [ -z "${HOST_IP}" ]; then
  echo "ERROR! No HOST_IP set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo "INFO! No HOST_IP set found and using ${HOST_IP}"
fi

# TODO: delete if not needed anymore
## Get IP + bit length of subnet for given INTERFACE if not set
#[ -z "${HOST_IP_W_SUBNET}" ] && HOST_IP_W_SUBNET=$(ip -o -4 addr show | grep "${INTERFACE}" | awk '/scope global/ {print $4}')
#if [ -z "${HOST_IP_W_SUBNET}" ]; then
#  echo "ERROR! No HOST_IP_W_SUBNET set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
#  exit_err
#else
#  echo "INFO! No HOST_IP_W_SUBNET set found and using ${HOST_IP_W_SUBNET}"
#fi

# Get hostname if not set
[ -z "${HOST_NAME}" ] && HOST_NAME=$(hostname)
if [ -z "${HOST_NAME}" ]; then
  echo "ERROR! No HOST_NAME set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo "INFO! No HOST_NAME set found and using ${HOST_NAME}"
fi

# Get timezone if not set
[ -z "${TIMEZONE}" ] && TIMEZONE=$(timedatectl | grep 'Time zone' | awk '{print $3}')
if [ -z "${TIMEZONE}" ]; then
  echo "ERROR! No TIMEZONE set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo "INFO! No TIMEZONE set found and using ${TIMEZONE}"
fi

# Create domain if not set
[ -z "${DOMAIN}" ] && DOMAIN="${HOST_NAME}.dns"
if [ -z "${DOMAIN}" ]; then
  echo "ERROR! No DOMAIN set and none could be created. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo "INFO! No DOMAIN set found and using ${DOMAIN}"
fi


# Change architecture specific stuff based on ARCHITECTURE
if echo "${ARCHITECTURE}" | grep -iq arm; then
  sed -i 's,mvance/unbound:latest,mvance/unbound-rpi:latest,' docker-compose.yaml
elif echo "${ARCHITECTURE}" | grep -iq x86; then
  sed -i 's,mvance/unbound-rpi:latest,mvance/unbound:latest,' docker-compose.yaml
else
  echo "ERROR! Invalid architecture. Only 'ARM' and 'x86' are allowed."
  exit_err
fi


# Checking for 'server.conf' file and if necessary settings (ServerIP and TZ) are set
echo "INFO! Checking for 'server.conf' file"
if ! [ -f pihole-docker/configs/server.conf ] || echo "${FRESH}" | grep -q 'y'; then
  if echo -e "ServerIP=${HOST_IP}\nTZ=${TIMEZONE}" | tee pihole-docker/configs/server.conf > /dev/null; then
    echo "SUCCESS! Created 'server.conf' file"
  else
    if [ -f pihole-docker/configs/server.conf ]; then
      echo "ERROR! Error while creating 'server.conf' file. Data could not be gathered and empty file was created." \
           "Please add necessary settings (ServerIP and TZ) manually."
      exit_err
    else
      echo "ERROR! Error while creating 'server.conf' file. The file was not created."
      exit_err
    fi
  fi
else
  echo "SUCCESS! Found 'server.conf' file"
  if ! [ "$(. pihole-docker/configs/server.conf && [[ -n "${ServerIP}" ]] && [[ -n "${TZ}" ]] && echo "OK")" = "OK" ]; then
    echo "ERROR! Please fill necessary settings (ServerIP and TZ) in 'server.conf' file and restart this script."
    exit_err
  fi
fi


# Checking for '.env' file for compose and if necessary settings (HOSTNAME and TZ) are set
echo "INFO! Checking for '.env' file"
if ! [ -f .env ] || echo "${FRESH}" | grep -q 'y'; then
  if echo -e "HOSTNAME=${HOST_NAME}\nTZ=${TIMEZONE}" | tee .env > /dev/null; then
    echo "SUCCESS! Created '.env' file"
  else
    if [ -f .env ]; then
      echo "ERROR! Error while creating '.env' file. Data could not be gathered and empty file was created." \
           "Please add necessary settings (ServerIP and TZ) manually."
      exit_err
    else
      echo "ERROR! Error while creating '.env' file. The file was not created."
      exit_err
    fi
  fi
else
  echo "SUCCESS! Found '.env' file"
  if ! [ "$(. .env && [[ -n "${HOSTNAME}" ]] && [[ -n "${TZ}" ]] && echo "OK")" = "OK" ]; then
    echo "ERROR! Please fill necessary settings (ServerIP and TZ) in '.env' file and restart this script."
    exit_err
  fi
fi


# Auto create lan.list file or complement it
echo "INFO! Checking for 'lan.list' file"
if ! [ -f pihole-docker/configs/pihole/lan.list ] || echo "${FRESH}" | grep -q 'y'; then
  if echo "${HOST_IP}      ${HOST_NAME}.dns   ${HOST_NAME}" | tee pihole-docker/configs/pihole/lan.list > /dev/null; then
    echo "SUCCESS! Created 'lan.list' file"
  else
    if [ -f pihole-docker/configs/pihole/lan.list ]; then
      echo "ERROR! Error while creating 'lan.list' file. Data could not be gathered and empty file was created." \
           "Please add necessary host data manually."
      exit_err
    else
      echo "ERROR! Error while creating 'lan.list' file. The file was not created."
      exit_err
    fi
  fi
else
  if ! grep -qw -e "${HOST_IP}" 'pihole-docker/configs/pihole/lan.list'; then
    echo -e "\n${HOST_IP}      ${HOST_NAME}.dns   ${HOST_NAME}" | tee -a pihole-docker/configs/pihole/lan.list > /dev/null &&
    if grep -qw -e "${HOST_IP}" 'pihole-docker/configs/pihole/lan.list'; then
      echo "SUCCESS! Added host to 'lan.list' file"
    else
      echo "ERROR! Host could not be added to 'lan.list' file"
      exit_err
    fi
  else
    echo "SUCCESS! Found 'lan.list' file"
  fi
fi


# Auto create nginx conf files
echo "INFO! Checking for nginx configuration files"
# Conf files based on HOST_IP
if ! [ -f nginx-docker/configs/sites-enabled/"${HOST_IP}".conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/HOST_IP.conf.template nginx-docker/configs/sites-enabled/"${HOST_IP}".conf; then
    echo "ERROR! 'HOST_IP.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/HOST_IP/"${HOST_IP}"/g nginx-docker/templates/HOST_IP.conf.template; then
    echo "ERROR! '${HOST_IP}.conf' copy could not be modified."
    exit_err
  fi
  echo "SUCCESS! Created '${HOST_IP}.conf' file."
else
  echo "SUCCESS! Found '${HOST_IP}.conf' file."
fi
if [ -f nginx-docker/configs/snippets/cert_"${HOST_IP}".conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/cert_HOST_IP.conf.template nginx-docker/configs/snippets/cert_"${HOST_IP}".conf; then
    echo "ERROR! 'cert_HOST_IP.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/HOST_IP/"${HOST_IP}"/g nginx-docker/templates/cert_HOST_IP.conf.template; then
    echo "ERROR! 'cert_${HOST_IP}.conf' copy could not be modified."
    exit_err
  fi
  echo "SUCCESS! Created 'cert_${HOST_IP}.conf' file."
else
  echo "SUCCESS! Found 'cert_${HOST_IP}.conf' file."
fi
#Conf files based on DOMAIN
if [ -f nginx-docker/configs/sites-enabled/"${DOMAIN}".conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/DOMAIN.conf.template nginx-docker/configs/sites-enabled/"${DOMAIN}".conf; then
    echo "ERROR! 'DOMAIN.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/DOMAIN/"${DOMAIN}"/g nginx-docker/templates/DOMAIN.conf.template; then
    echo "ERROR! '${DOMAIN}.conf' copy could not be modified."
    exit_err
  fi
  echo "SUCCESS! Created '${DOMAIN}.conf' file."
else
  echo "SUCCESS! Found '${DOMAIN}.conf' file."
fi
if [ -f nginx-docker/configs/snippets/cert_"${DOMAIN}".conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/cert_DOMAIN.conf.template nginx-docker/configs/snippets/cert_"${DOMAIN}".conf; then
    echo "ERROR! 'cert_DOMAIN.conf' could not be copied."
    exit_err
  fi
  if ! sed -i s/DOMAIN/"${DOMAIN}"/g nginx-docker/templates/cert_DOMAIN.conf.template; then
    echo "ERROR! 'cert_${DOMAIN}.conf' copy could not be modified."
    exit_err
  fi
  echo "SUCCESS! Created 'cert_${DOMAIN}.conf' file."
else
  echo "SUCCESS! Found 'cert_${DOMAIN}.conf' file."
fi
# Conf file for DoT
if [ -f nginx-docker/configs/streams/dns-over-tls.conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/dns-over-tls.conf.template nginx-docker/configs/streams/dns-over-tls.conf; then
    echo "ERROR! 'dns-over-tls.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/HOST_IP/"${HOST_IP}"/g nginx-docker/templates/dns-over-tls.conf.template; then
    echo "ERROR! 'dns-over-tls.conf' copy could not be modified."
    exit_err
  fi
  echo "SUCCESS! Created 'dns-over-tls.conf' file."
else
  echo "SUCCESS! Found 'dns-over-tls.conf' file."
fi
echo "SUCCESS! nginx configuration finished."


# TODO: verify the need for 3 crt/key
# Check for certificates and keys
echo "INFO! Checking for SSL certificates and keys"
CERT_COUNT=0
for cert in certificates/certs/*.crt
do
    if [ -e "$cert" ]; then
        CERT_COUNT=$((CERT_COUNT + 1))
    fi
done

KEY_COUNT=0
for key in certificates/private/*.key
do
    if [ -e "$key" ]; then
        KEY_COUNT=$((KEY_COUNT + 1))
    fi
done

if (( CERT_COUNT < 3))  || (( KEY_COUNT < 3 )); then
  echo "ERROR! Add at least one certificate to 'certificates/certs/' and the matching key to " \
       "'certificates/' for pi.hole, your HOSTNAME and the server's IP. Then restart the script."
  exit_err
elif ! (( CERT_COUNT = KEY_COUNT )); then
  echo "WARNING! There is an uneven amount of certificates and keys."
else
  echo "SUCCESS! Found SSL certificates and keys"
fi


# Check for 'dhparam.pem' file
echo "INFO! Checking for dhparam.pem file"
if [ -f certificates/dhparam.pem ]; then
  echo "SUCCESS! Found dhparam.pem file"
else
  echo "ERROR! No 'dhparam.pem' file found. Please add a 'dhparam.pem' file to certificates/. Then restart this script."
  exit_err
fi


# Compile doh server image
if echo "${COMPILE}" | grep -q 'n'; then
  echo "INFO! COMPILE set to 'n'. Not compiling 'goofball222/dns-over-https'."
else
  if echo "${COMPILE}" | grep -q 'y' || echo "${ARCHITECTURE}" | grep -iq arm; then
    if
      VERSION="$(git ls-remote -t --refs  https://github.com/m13253/dns-over-https.git | tail -n1 | awk '{print $2}' | sed 's,refs/tags/v,,')" &&
      CUR_DIR="$(pwd)" &&
      echo "INFO! Compiling image for 'goofball222/dns-over-https' for version ${VERSION}." &&
      mkdir -p ~/dns-over-https_tmp && cd ~/dns-over-https_tmp &&
      git clone https://github.com/goofball222/dns-over-https.git && cd dns-over-https &&
      echo "$VERSION" | tee 'stable/VERSION' > /dev/null && sudo make &&
      cd "$CUR_DIR" && rm -rf ~/dns-over-https_tmp
    then
      echo "SUCCESS! Image compiled."
    else
      echo "ERROR! Compiling failed. Deleting '~/dns-over-https_tmp' directory."
      rm -rf ~/dns-over-https_tmp || echo "ERROR! Failed to delete '~/dns-over-https_tmp' directory."
      exit_err
    fi
  fi
fi


# Download root.hints file
if ! [ -f unbound-docker/var/root.hints ]; then
  if echo "" && wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
    echo "SUCCESS! 'root.hints' file downloaded."
  else
    echo "ERROR! 'root.hints' file download failed."
  fi
else
  (( DIFF = ($(date +%s) - $(stat -c %Z unbound-docker/var/root.hints))/3600 ))
  if ((DIFF > 1)) || echo "${FRESH}" | grep -q 'y'; then
    if wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
      echo "SUCCESS! 'root.hints' file updated."
    else
      echo "ERROR! 'root.hints' file update failed."
    fi
  fi
fi


echo -e "\nSUCCESS! Setup for docker-pihole-unbound-encrypted finished."
echo -e "\n####################"