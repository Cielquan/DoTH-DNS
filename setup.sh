#!/bin/bash


# Color variables for output messages
RED='\033[0;31m' # For ERROR messages
GREEN='\033[0;32m' # For SUCCESS messages
ORANGE='\033[0;33m' # For WARNING messages
CYAN='\033[0;36m' # For INFO messages
BLANK='\033[0m' # For resetting colors


# Func for showing usage string
usage_string() {
  echo -e "Usage: $0 [-f <yes|no>] [-a <arm|x86>] [-c <yes|no>] [-I <INTERFACE>] [-i <IP ADDRESS>] `
        `[-n <HOSTNAME>] [-t <TIMEZONE>] [-d <DOMAIN>] [-h]" 1>&2;
}

# Func for showing usage
usage() {
  usage_string
  echo -e "Run $0 -h for more detailed usage."
}

# Func for showing usage help page
help() {
  usage_string
  echo ""
  echo "$0 flags:" && grep " .)\ #" "$0"
  exit 0
}

# Exit func for call errors
exit_flag_err() {
  echo -e "Please correct set flags/arguments and restart.\n"
  usage
  exit 1
}

# Exit func for errors
exit_err() {
  echo "Please correct the error and restart the script."
  exit 1
}


# Import setup.conf file if existing
[ -f setup.conf ] && . setup.conf && _CONF_FILE='y'


# Catching flags
while getopts ":f:a:c:I:i:n:t:d:h" flag; do
  case $flag in
    f) # Set FRESH variable with 'yes'/'y' or 'no'/'n' (case insensitive). 'yes' -> Overwrite existing configs with new ones.
      if ! echo "${OPTARG}" | grep -iq 'yes' && ! echo "${OPTARG}" | grep -iq 'y' &&
         ! echo "${OPTARG}" | grep -iq 'no' && ! echo "${OPTARG}" | grep -iq 'n'; then
        echo "No valid argument for '-f'."
        exit_flag_err
      fi
      FRESH=$(echo "${OPTARG:0:1}" | awk '{print tolower($0)}')
      ;;
    a) # Set ARCHITECTURE variable with 'ARM' or 'x86' (case insensitive).
      if ! echo "${OPTARG}" | grep -iq 'arm' && ! echo "${OPTARG}" | grep -iq 'x86'; then
        echo "No valid argument for '-a'."
        exit_flag_err
      fi
      ARCHITECTURE=${OPTARG}
      ;;
    c) # Set COMPILE variable with 'yes'/'y' or 'no'/'n' (case insensitive). 'yes' -> Compile the 'goofball222/dns-over-https' docker image.
      if ! echo "${OPTARG}" | grep -iq 'yes' && ! echo "${OPTARG}" | grep -iq 'y' &&
         ! echo "${OPTARG}" | grep -iq 'no' && ! echo "${OPTARG}" | grep -iq 'n'; then
        echo "No valid argument for '-c'."
        exit_flag_err
      fi
      COMPILE=$(echo "${OPTARG:0:1}" | awk '{print tolower($0)}')
      ;;
    I) # Set INTERFACE variable with <INTERFACE>. E.g. eth0
      INTERFACE=${OPTARG}
      ;;
    i) # Set HOST_IP variable with <IP ADDRESS>. E.g. 192.168.0.2
      HOST_IP=${OPTARG}
      ;;
    n) # Set HOST_NAME variable with <HOSTNAME>. E.g. raspberry
      HOST_NAME=${OPTARG}
      ;;
    t) # Set TIMEZONE variable with <TIMEZONE>. Format e.g. Europe/London
      TIMEZONE=${OPTARG}
      ;;
    d) # Set DOMAIN variable with <DOMAIN>. E.g. example.com
      DOMAIN=${OPTARG}
      ;;
    h) # Shows this help page.
      help
      ;;
    \?)
      echo "Invalid option: -${OPTARG}" >&2
      exit_flag_err
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit_flag_err
      ;;
  esac
done


echo -e "\n####################\n"
echo -e "${CYAN}INFO${BLANK}: Starting setup for DoTH-DNS.\n"
if echo "${_CONF_FILE}" | grep -q 'y'; then echo -e "${CYAN}INFO${BLANK}: setup.conf loaded.\n";fi


# Get architecture if not set
[ -z "${ARCHITECTURE}" ] && ARCHITECTURE=$(lscpu | grep Architecture: | awk '{print $2}')
if [ -z "${ARCHITECTURE}" ]; then
  echo -e "${RED}ERROR${BLANK}: No ARCHITECTURE set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo -e "${CYAN}INFO${BLANK}: No ARCHITECTURE set found and using '${ARCHITECTURE}'."
fi

# Get default interface if not set
[ -z "${INTERFACE}" ] && INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')
if [ -z "${INTERFACE}" ]; then
  echo -e "${RED}ERROR${BLANK}: No INTERFACE set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo -e "${CYAN}INFO${BLANK}: No INTERFACE set found and using '${INTERFACE}'."
fi

# Get IP for given INTERFACE if not set
[ -z "${HOST_IP}" ] && HOST_IP=$(ifconfig "${INTERFACE}" | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
if [ -z "${HOST_IP}" ]; then
  echo -e "${RED}ERROR${BLANK}: No HOST_IP set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo -e "${CYAN}INFO${BLANK}: No HOST_IP set found and using '${HOST_IP}'."
fi

## Get IP + bit length of subnet for given INTERFACE if not set
#[ -z "${HOST_IP_W_SUBNET}" ] && HOST_IP_W_SUBNET=$(ip -o -4 addr show | grep "${INTERFACE}" | awk '/scope global/ {print $4}')
#if [ -z "${HOST_IP_W_SUBNET}" ]; then
#  echo -e "${RED}ERROR${BLANK}: No HOST_IP_W_SUBNET set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
#  exit_err
#else
#  echo -e "${CYAN}INFO${BLANK}: No HOST_IP_W_SUBNET set found and using '${HOST_IP_W_SUBNET}'."
#fi

# Get hostname if not set
[ -z "${HOST_NAME}" ] && HOST_NAME=$(hostname)
if [ -z "${HOST_NAME}" ]; then
  echo -e "${RED}ERROR${BLANK}: No HOST_NAME set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo -e "${CYAN}INFO${BLANK}: No HOST_NAME set found and using '${HOST_NAME}'."
fi

# Get timezone if not set
[ -z "${TIMEZONE}" ] && TIMEZONE=$(timedatectl | grep 'Time zone' | awk '{print $3}')
if [ -z "${TIMEZONE}" ]; then
  echo -e "${RED}ERROR${BLANK}: No TIMEZONE set and none could be determined. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo -e "${CYAN}INFO${BLANK}: No TIMEZONE set found and using '${TIMEZONE}'."
fi

# Create domain if not set
[ -z "${DOMAIN}" ] && DOMAIN="${HOST_NAME}.dns"
if [ -z "${DOMAIN}" ]; then
  echo -e "${RED}ERROR${BLANK}: No DOMAIN set and none could be created. Please set the variable in 'setup.conf' and restart the script."
  exit_err
else
  echo -e "${CYAN}INFO${BLANK}: No DOMAIN set found and using '${DOMAIN}'."
fi


# Change architecture specific stuff based on ARCHITECTURE
if echo "${ARCHITECTURE}" | grep -iq arm; then
  sed -i 's,mvance/unbound:latest,mvance/unbound-rpi:latest,' docker-compose.yaml
elif echo "${ARCHITECTURE}" | grep -iq x86; then
  sed -i 's,mvance/unbound-rpi:latest,mvance/unbound:latest,' docker-compose.yaml
else
  echo -e "${RED}ERROR${BLANK}: Invalid architecture. Only 'ARM' and 'x86' are allowed."
  exit_err
fi


# Checking for 'server.conf' file and if necessary settings (ServerIP and TZ) are set
echo -e "\n${CYAN}INFO${BLANK}: Checking for 'server.conf' file."
if ! [ -f pihole-docker/configs/server.conf ] || echo "${FRESH}" | grep -q 'y'; then
  if echo -e "ServerIP=${HOST_IP}\nTZ=${TIMEZONE}" | tee pihole-docker/configs/server.conf > /dev/null; then
    echo -e "${GREEN}SUCCESS${BLANK}: Created 'server.conf' file."
  else
    if [ -f pihole-docker/configs/server.conf ]; then
      echo -e "${RED}ERROR${BLANK}: Error while creating 'server.conf' file. Data could not be gathered and empty file was created." \
           "Please add necessary settings (ServerIP and TZ) manually."
      exit_err
    else
      echo -e "${RED}ERROR${BLANK}: Error while creating 'server.conf' file. The file was not created."
      exit_err
    fi
  fi
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found 'server.conf' file."
  if ! [ "$(. pihole-docker/configs/server.conf && [[ -n "${ServerIP}" ]] && [[ -n "${TZ}" ]] && echo "OK")" = "OK" ]; then
    echo -e "${RED}ERROR${BLANK}: Please fill necessary settings (ServerIP and TZ) in 'server.conf' file and restart this script."
    exit_err
  fi
fi


# Checking for '.env' file for compose and if necessary settings (HOSTNAME and TZ) are set
echo -e "\n${CYAN}INFO${BLANK}: Checking for '.env' file."
if ! [ -f .env ] || echo "${FRESH}" | grep -q 'y'; then
  if echo -e "HOSTNAME=${HOST_NAME}\nDOMAIN=${DOMAIN}\nTZ=${TIMEZONE}" | tee .env > /dev/null; then
    echo -e "${GREEN}SUCCESS${BLANK}: Created '.env' file."
  else
    if [ -f .env ]; then
      echo -e "${RED}ERROR${BLANK}: Error while creating '.env' file. Data could not be gathered and empty file was created." \
           "Please add necessary settings (ServerIP, DOMAIN and TZ) manually."
      exit_err
    else
      echo -e "${RED}ERROR${BLANK}: Error while creating '.env' file. The file was not created."
      exit_err
    fi
  fi
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found '.env' file."
  if ! [ "$(. .env && [[ -n "${HOSTNAME}" ]] && [[ -n "${DOMAIN}" ]] && [[ -n "${TZ}" ]] && echo "OK")" = "OK" ]; then
    echo -e "${RED}ERROR${BLANK}: Please fill necessary settings (ServerIP, DOMAIN and TZ) in '.env' file and restart this script."
    exit_err
  fi
fi


# Auto create lan.list file or complement it
echo -e "\n${CYAN}INFO${BLANK}: Checking for 'lan.list' file."
if ! [ -f pihole-docker/configs/pihole/lan.list ] || echo "${FRESH}" | grep -q 'y'; then
  if echo "${HOST_IP}      ${HOST_NAME}.dns   ${HOST_NAME}" | tee pihole-docker/configs/pihole/lan.list > /dev/null; then
    echo -e "${GREEN}SUCCESS${BLANK}: Created 'lan.list' file."
  else
    if [ -f pihole-docker/configs/pihole/lan.list ]; then
      echo -e "${RED}ERROR${BLANK}: Error while creating 'lan.list' file. Data could not be gathered and empty file was created." \
           "Please add necessary host data manually."
      exit_err
    else
      echo -e "${RED}ERROR${BLANK}: Error while creating 'lan.list' file. The file was not created."
      exit_err
    fi
  fi
else
  if ! grep -qw -e "${HOST_IP}" 'pihole-docker/configs/pihole/lan.list'; then
    echo -e "\n${HOST_IP}      ${HOST_NAME}.dns   ${HOST_NAME}" | tee -a pihole-docker/configs/pihole/lan.list > /dev/null
    if grep -qw -e "${HOST_IP}" 'pihole-docker/configs/pihole/lan.list'; then
      echo -e "${GREEN}SUCCESS${BLANK}: Added host to 'lan.list' file."
    else
      echo -e "${RED}ERROR${BLANK}: Host could not be added to 'lan.list' file."
      exit_err
    fi
  else
    echo -e "${GREEN}SUCCESS${BLANK}: Found 'lan.list' file."
  fi
fi


# Check for host IP address mapping in dnsmasq.conf
echo -e "\n${CYAN}INFO${BLANK}: Checking for 'dnsmasq.conf' file."
if ! [ -f pihole-docker/configs/dnsmasq.d/dnsmasq.conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp pihole-docker/templates/dnsmasq.conf.template pihole-docker/configs/dnsmasq.d/dnsmasq.conf; then
    echo -e "${RED}ERROR${BLANK}: 'dnsmasq.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i -e s/DOMAIN/"${DOMAIN}"/g -e s/HOST_IP/"${HOST_IP}"/g pihole-docker/configs/dnsmasq.d/dnsmasq.conf; then
    echo -e "${RED}ERROR${BLANK}: 'dnsmasq.conf' copy could not be modified."
    exit_err
  fi
  echo -e "${GREEN}SUCCESS${BLANK}: Created 'dnsmasq.conf' file."
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found 'dnsmasq.conf' file."
fi


# Auto create nginx conf files
echo -e "\n${CYAN}INFO${BLANK}: Checking for nginx configuration files."
# Conf files based on DOMAIN
if ! [ -f nginx-docker/configs/sites-enabled/"${DOMAIN}".conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/DOMAIN.conf.template nginx-docker/configs/sites-enabled/"${DOMAIN}".conf; then
    echo -e "${RED}ERROR${BLANK}: 'DOMAIN.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/DOMAIN/"${DOMAIN}"/g nginx-docker/configs/sites-enabled/"${DOMAIN}".conf; then
    echo -e "${RED}ERROR${BLANK}: '${DOMAIN}.conf' copy could not be modified."
    exit_err
  fi
  echo -e "${GREEN}SUCCESS${BLANK}: Created '${DOMAIN}.conf' file."
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found '${DOMAIN}.conf' file."
fi
if ! [ -f nginx-docker/configs/snippets/cert_"${DOMAIN}".conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/cert_DOMAIN.conf.template nginx-docker/configs/snippets/cert_"${DOMAIN}".conf; then
    echo -e "${RED}ERROR${BLANK}: 'cert_DOMAIN.conf' could not be copied."
    exit_err
  fi
  if ! sed -i s/DOMAIN/"${DOMAIN}"/g nginx-docker/configs/snippets/cert_"${DOMAIN}".conf; then
    echo -e "${RED}ERROR${BLANK}: 'cert_${DOMAIN}.conf' copy could not be modified."
    exit_err
  fi
  echo -e "${GREEN}SUCCESS${BLANK}: Created 'cert_${DOMAIN}.conf' file."
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found 'cert_${DOMAIN}.conf' file."
fi
# Conf file for HTTP redirect
if ! [ -f nginx-docker/configs/sites-enabled/http_redirect.conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/http_redirect.conf.template nginx-docker/configs//sites-enabled/http_redirect.conf; then
    echo -e "${RED}ERROR${BLANK}: 'http_redirect.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/DOMAIN/"${DOMAIN}"/g nginx-docker/configs//sites-enabled/http_redirect.conf; then
    echo -e "${RED}ERROR${BLANK}: 'http_redirect.conf' copy could not be modified."
    exit_err
  fi
  echo -e "${GREEN}SUCCESS${BLANK}: Created 'http_redirect.conf' file."
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found 'http_redirect.conf' file."
fi
# Conf file for DoT
if ! [ -f nginx-docker/configs/streams/dns-over-tls.conf ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp nginx-docker/templates/dns-over-tls.conf.template nginx-docker/configs/streams/dns-over-tls.conf; then
    echo -e "${RED}ERROR${BLANK}: 'dns-over-tls.conf.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/DOMAIN/"${DOMAIN}"/g nginx-docker/configs/streams/dns-over-tls.conf; then
    echo -e "${RED}ERROR${BLANK}: 'dns-over-tls.conf' copy could not be modified."
    exit_err
  fi
  echo -e "${GREEN}SUCCESS${BLANK}: Created 'dns-over-tls.conf' file."
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found 'dns-over-tls.conf' file."
fi


# Check for certificates and keys
echo -e "\n${CYAN}INFO${BLANK}: Checking for SSL certificates and keys."
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

if (( CERT_COUNT < 1))  || (( KEY_COUNT < 1 )); then
  echo -e "${RED}ERROR${BLANK}: Add at least one certificate to 'certificates/certs/' and the matching key to " \
       "'certificates/private/' for your DOMAIN. Then restart the script."
  exit_err
elif ! (( CERT_COUNT = KEY_COUNT )); then
  echo -e "${ORANGE}WARNING${BLANK}: There is an uneven amount of certificates and keys."
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found SSL certificate and key."
fi


# Check for 'dhparam.pem' file
echo -e "\n${CYAN}INFO${BLANK}: Checking for dhparam.pem file."
if [ -f certificates/dhparam.pem ]; then
  echo -e "${GREEN}SUCCESS${BLANK}: Found dhparam.pem file."
else
  echo -e "${RED}ERROR${BLANK}: No 'dhparam.pem' file found. Please add a 'dhparam.pem' file to certificates/. Then restart this script."
  exit_err
fi


# Traefik conf file for certs
echo -e "\n${CYAN}INFO${BLANK}: Checking for traefik configuration files."
if ! [ -f traefik-docker/configs/traefik.conf.d/certs.toml ] || echo "${FRESH}" | grep -q 'y'; then
  if ! cp traefik-docker/templates/certs.toml.template traefik-docker/configs/traefik.conf.d/certs.toml; then
    echo -e "${RED}ERROR${BLANK}: 'certs.toml.template' could not be copied."
    exit_err
  fi
  if ! sed -i s/DOMAIN/"${DOMAIN}"/g traefik-docker/configs/traefik.conf.d/certs.toml; then
    echo -e "${RED}ERROR${BLANK}: 'certs.toml' copy could not be modified."
    exit_err
  fi
  echo -e "${GREEN}SUCCESS${BLANK}: Created 'certs.toml' file."
else
  echo -e "${GREEN}SUCCESS${BLANK}: Found 'certs.toml' file."
fi


# Compile doh server image
echo -e "\n${CYAN}INFO${BLANK}: Checking for compiling doh_server."
if echo -e "${COMPILE}" | grep -q 'n'; then
  echo -e "${CYAN}INFO${BLANK}: COMPILE set to 'n'. Not compiling 'goofball222/dns-over-https'."
else
  if echo "${COMPILE}" | grep -q 'y' || echo "${ARCHITECTURE}" | grep -iq arm; then
    if
      VERSION="$(git ls-remote -t --refs  https://github.com/m13253/dns-over-https.git | tail -n1 | awk '{print $2}' | sed 's,refs/tags/v,,')" &&
      CUR_DIR="$(pwd)" &&
      echo -e "${CYAN}INFO${BLANK}: Compiling image for 'goofball222/dns-over-https' for version ${VERSION}." &&
      mkdir -p ~/dns-over-https_tmp && cd ~/dns-over-https_tmp &&
      git clone https://github.com/goofball222/dns-over-https.git && cd dns-over-https &&
      echo "$VERSION" | tee 'stable/VERSION' > /dev/null && sudo make &&
      cd "$CUR_DIR" && rm -rf ~/dns-over-https_tmp
    then
      echo -e "${GREEN}SUCCESS${BLANK}: Image compiled."
    else
      echo -e "${RED}ERROR${BLANK}: Compiling failed. Deleting '~/dns-over-https_tmp' directory."
      rm -rf ~/dns-over-https_tmp || echo -e "${RED}ERROR${BLANK}: Failed to delete '~/dns-over-https_tmp' directory."
      exit_err
    fi
  fi
fi


# Download root.hints file
echo -e "\n${CYAN}INFO${BLANK}: Checking for 'root.hints' file."
if ! [ -f unbound-docker/var/root.hints ]; then
  if echo "" && wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
    echo -e "${GREEN}SUCCESS${BLANK}: 'root.hints' file downloaded."
  else
    echo -e "${RED}ERROR${BLANK}: 'root.hints' file download failed."
    exit_err
  fi
else
  (( DIFF = ($(date +%s) - $(stat -c %Z unbound-docker/var/root.hints))/3600 ))
  if ((DIFF > 1)) || echo "${FRESH}" | grep -q 'y'; then
    if wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
      echo -e "${GREEN}SUCCESS${BLANK}: 'root.hints' file updated."
    else
      echo -e "${ORANGE}WARNING${BLANK}: 'root.hints' file update failed."
    fi
  else
    echo -e "${GREEN}SUCCESS${BLANK}: 'root.hints' file found."
  fi
fi


echo -e "\n${GREEN}SUCCESS${BLANK}: Setup for DoTH-DNS finished."
echo -e "\n####################\n"