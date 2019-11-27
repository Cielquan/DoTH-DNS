#!/bin/bash

# ==============================================================================
# Copyright (c) 2019 Christian Riedel
# 
# This file 'run.bash' created 2019-11-15 is part of the project/program 'DoTH-DNS'.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the MIT License as published by
# the Massachusetts Institute of Technology.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# MIT License for more details.
#
# You should have received a copy of the MIT License
# along with this program. If not, see <https://opensource.org/licenses/MIT>.
# 
# Github: https://github.com/Cielquan/
# ==============================================================================


# Color variables for output messages
RED='\e[0;31m' # For ERROR messages
GREEN='\e[0;32m' # For SUCCESS messages
ORANGE='\e[0;33m' # For WARNING messages
CYAN='\e[0;36m' # For INFO messages
BLANK='\e[0m' # For resetting colors


# ##########################################################################################
### Functions for error exits and help
# Exit func for boot control errors
exit_err() {
  printf "\nBefore you restart the script make sure erroring containers are removed or fixed.\n"
  printf "Please correct the error and restart the script.\n"
  exit 1
}

# Exit func for flag errors
exit_flag_err() {
  printf "\nPlease correct set flag(s) and restart.\n"
  usage
  exit 1
}

# Exit func for argument errors
exit_arg_err() {
  printf "\nPlease correct set argument(s) and restart.\n"
  usage
  exit 1
}

# Exit func for docker-compose error
exit_dc_err() {
  printf "\ndocker(-compose) failed. You may need to restart the script with root privileges.\n"
  exit 1
}

# Func for showing usage string
usage_string() {
  printf "\nUsage: %s [-f] [-a <arm|x86>] [-c] [-I <INTERFACE>] [-i <IP ADDRESS>] `
          `[-n <HOSTNAME>] [-t <TIMEZONE>] [-d <DOMAIN>] [-N] [-R] [-U] [-P] [-D] [-h]\n" "$0" 1>&2;
}

# Func for showing usage
usage() {
  usage_string
  printf "\nRun %s -h for more detailed usage.\n" "$0"
}

# Func for showing usage help page
help() {
  usage_string
  printf "\n\n%s flags:\n" "$0" && grep " .)\ #" "$0"
  exit 0
}


# ##########################################################################################
# Catching flags
while getopts ":fa:cI:i:n:t:d:NRUPDh" flag; do
  case ${flag} in
    f) # Set for overwriting existing configs with new ones.
      _FLAG_FRESH='y'
      ;;
    a) # Set ARCHITECTURE variable with 'ARM' or 'x86' (case insensitive).
      if ! [[ "${OPTARG,,}" == 'arm' ]] && ! [[ "${OPTARG,,}" == 'x86' ]]; then
        printf "No valid argument for '-a'.\n"
        exit_arg_err
      fi
      _FLAG_ARCHITECTURE=${OPTARG,,}
      ;;
    c) # Set for force compiling the 'goofball222/dns-over-https' docker image.
      _FLAG_COMPILE='y'
      ;;
    I) # Set INTERFACE variable with <INTERFACE>. E.g. eth0
      _FLAG_INTERFACE=${OPTARG}
      ;;
    i) # Set HOST_IP variable with <IP ADDRESS>. E.g. 192.168.0.2
      _FLAG_HOST_IP=${OPTARG}
      ;;
    n) # Set HOST_NAME variable with <HOSTNAME>. E.g. raspberry
      _FLAG_HOST_NAME=${OPTARG}
      ;;
    t) # Set TIMEZONE variable with <TIMEZONE>. Format e.g. Europe/London
      _FLAG_TIMEZONE=${OPTARG}
      ;;
    d) # Set DOMAIN variable with <DOMAIN>. E.g. example.com
      _FLAG_DOMAIN=${OPTARG}
      ;;
    N) # Deactivate traefik dashboard authorization
      _FLAG_TRAEFIK_NOAUTH='y'
      ;;
    R) # Recreate all conatiners taking in changed configs.
      _FLAG_RECREATE_ALL='y'
      ;;
    U) # Update all containers with newer images if available and recreate them.
      _FLAG_UPDATE_ALL='y'
      ;;
    P) # Start without reverse proxy (`traefik`).
      _FLAG_NO_PROXY='y'
      ;;
    D) # Shut all containers and networks down.
      _FLAG_DOWN_ALL='y'
      ;;
    h) # Shows this help page.
      help
      ;;
    \?)
      printf "Invalid option: '-%s'\n" "${OPTARG}" >&2
      exit_flag_err
      ;;
    :)
      printf "Option '-%s' requires an argument.\n" "${OPTARG}" >&2
      exit_arg_err
      ;;
  esac
done


# ##########################################################################################
# Shutting service down
if [[ ${_FLAG_DOWN_ALL} == 'y' ]]; then
  printf "\n####################\n"
  printf "\n%bINFO:   %b Shutting DoTH-DNS down.\n\n" "${CYAN}" "${BLANK}"
  docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml down || exit_dc_err
  printf "\n\n%bSUCCESS:%b DoTH-DNS shut down.\n" "${GREEN}" "${BLANK}"
  printf "\n####################\n\n"
  exit 0
fi


# ##########################################################################################
# Starting line
printf "\n####################\n"
printf "\n%bINFO:   %b Starting setup for DoTH-DNS.\n\n\n" "${CYAN}" "${BLANK}"


# ##########################################################################################
# Load .env file
if [[ ${_FLAG_FRESH} == 'y' ]]; then
  printf "%bINFO:   %b Skipped loading of '.env'.\n\n" "${CYAN}" "${BLANK}"
else
  if [[ -f .env ]]; then
    if . .env; then
      printf "%bINFO:   %b .env loaded.\n\n" "${CYAN}" "${BLANK}"
    else
      printf "%bWARNING:%b Failed to load '.env'. Falling back to self gather information.\n\n" "${ORANGE}" "${BLANK}"
    fi
  else
    printf "%bWARNING:%b No '.env' file found. Falling back to self gather information.\n\n" "${ORANGE}" "${BLANK}"
  fi
fi


# ##########################################################################################
# Grabbing EnvVars
if [[ ${_FLAG_FRESH} == 'y' ]]; then
  printf "%bINFO:   %b Skipped loading of Environment Variables.\n\n" "${CYAN}" "${BLANK}"
else
  if \
  _ENV_ARCHITECTURE=${DOTH_ARCHITECTURE} &&
  _ENV_INTERFACE=${DOTH_INTERFACE} &&
  _ENV_HOST_IP=${DOTH_HOST_IP} &&
  _ENV_HOST_NAME=${DOTH_HOST_NAME} &&
  _ENV_TIMEZONE=${DOTH_TIMEZONE} &&
  _ENV_DOMAIN=${DOTH_DOMAIN}
  then
    printf "%bINFO:   %b Environment Variables loaded.\n\n" "${CYAN}" "${BLANK}"
  else
    printf "%bWARNING:%b No Environment Variables could be loaded. Falling back to self gather information.\n\n" \
            "${ORANGE}" "${BLANK}"
  fi
fi


# ##########################################################################################
### Check and set ENV Vars
# Set ARCHITECTURE
if [[ -n "${_FLAG_ARCHITECTURE}" ]]; then
  if _ARCHITECTURE="${_FLAG_ARCHITECTURE}"; then
    printf "%bINFO:   %b ARCHITECTURE set by CLI argument to '%s'.\n" "${CYAN}" "${BLANK}" "${_ARCHITECTURE}"
  else
    printf "%bERROR:  %b Failed to set ARCHITECTURE by CLI argument.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${ARCHITECTURE}" ]]; then
  if _ARCHITECTURE="${ARCHITECTURE}"; then
    printf "%bINFO:   %b ARCHITECTURE set by .env file to '%s'.\n" "${CYAN}" "${BLANK}" "${_ARCHITECTURE}"
  else
    printf "%bERROR:  %b Failed to set ARCHITECTURE by .env file.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${_ENV_ARCHITECTURE}" ]]; then
  if _ARCHITECTURE="${_ENV_ARCHITECTURE}"; then
    printf "%bINFO:   %b ARCHITECTURE set by Environment Variable to '%s'.\n" "${CYAN}" "${BLANK}" "${_ARCHITECTURE}"
  else
    printf "%bERROR:  %b Failed to set ARCHITECTURE by Environment Variable.\n" "${RED}" "${BLANK}"
    exit_err
  fi
  if [[ -n "${_ARCHITECTURE}" ]]; then
    if _ARCHITECTURE=$(lscpu | grep Architecture: | awk '{print $2}'); then
      printf "%bINFO:   %b ARCHITECTURE was determined and set to '%s'.\n" "${CYAN}" "${BLANK}" "${_ARCHITECTURE}"
    else
      printf "%bERROR:  %b ARCHITECTURE was not set and could not be determined. `
              `Please set ARCHITECTURE in '.env' file or via '-a' flag.\n" "${RED}" "${BLANK}"
      exit_err
    fi
  fi
fi

# Set INTERFACE
if [[ -n "${_FLAG_INTERFACE}" ]]; then
  if _INTERFACE="${_FLAG_INTERFACE}"; then
    printf "%bINFO:   %b INTERFACE set by CLI argument to '%s'.\n" "${CYAN}" "${BLANK}" "${_INTERFACE}"
  else
    printf "%bERROR:  %b Failed to set INTERFACE by CLI argument.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${INTERFACE}" ]]; then
  if _INTERFACE="${INTERFACE}"; then
    printf "%bINFO:   %b INTERFACE set by .env file to '%s'.\n" "${CYAN}" "${BLANK}" "${_INTERFACE}"
  else
    printf "%bERROR:  %b Failed to set INTERFACE by .env file.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${_ENV_INTERFACE}" ]]; then
  if _INTERFACE="${_ENV_INTERFACE}"; then
    printf "%bINFO:   %b INTERFACE set by Environment Variable to '%s'.\n" "${CYAN}" "${BLANK}" "${_INTERFACE}"
  else
    printf "%bERROR:  %b Failed to set INTERFACE by Environment Variable.\n" "${RED}" "${BLANK}"
    exit_err
  fi
  if [[ -n "${_INTERFACE}" ]]; then
    if _INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$'); then
      printf "%bINFO:   %b INTERFACE was determined and set to '%s'.\n" "${CYAN}" "${BLANK}" "${_INTERFACE}"
    else
      printf "%bERROR:  %b INTERFACE was not set and could not be determined. `
              `Please set INTERFACE in '.env' file or via '-a' flag.\n" "${RED}" "${BLANK}"
      exit_err
    fi
  fi
fi

# Set HOST_IP for given INTERFACE
if [[ -n "${_FLAG_HOST_IP}" ]]; then
  if _HOST_IP="${_FLAG_HOST_IP}"; then
    printf "%bINFO:   %b HOST_IP set by CLI argument to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_IP}"
  else
    printf "%bERROR:  %b Failed to set HOST_IP by CLI argument.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${HOST_IP}" ]]; then
  if _HOST_IP="${HOST_IP}"; then
    printf "%bINFO:   %b HOST_IP set by .env file to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_IP}"
  else
    printf "%bERROR:  %b Failed to set HOST_IP by .env file.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${_ENV_HOST_IP}" ]]; then
  if _HOST_IP="${_ENV_HOST_IP}"; then
    printf "%bINFO:   %b HOST_IP set by Environment Variable to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_IP}"
  else
    printf "%bERROR:  %b Failed to set HOST_IP by Environment Variable.\n" "${RED}" "${BLANK}"
    exit_err
  fi
  if [[ -n "${_HOST_IP}" ]]; then
    if _HOST_IP=$(ifconfig "${_INTERFACE}" | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'); then
      printf "%bINFO:   %b HOST_IP was determined and set to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_IP}"
    else
      printf "%bERROR:  %b HOST_IP was not set and could not be determined. `
              `Please set HOST_IP in '.env' file or via '-a' flag.\n" "${RED}" "${BLANK}"
      exit_err
    fi
  fi
fi


# Set HOSTNAME
if [[ -n "${_FLAG_HOST_NAME}" ]]; then
  if _HOST_NAME="${_FLAG_HOST_NAME}"; then
    printf "%bINFO:   %b HOST_NAME set by CLI argument to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_NAME}"
  else
    printf "%bERROR:  %b Failed to set HOST_NAME by CLI argument.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${HOST_NAME}" ]]; then
  if _HOST_NAME="${HOST_NAME}"; then
    printf "%bINFO:   %b HOST_NAME set by .env file to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_NAME}"
  else
    printf "%bERROR:  %b Failed to set HOST_NAME by .env file.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${_ENV_HOST_NAME}" ]]; then
  if _HOST_NAME="${_ENV_HOST_NAME}"; then
    printf "%bINFO:   %b HOST_NAME set by Environment Variable to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_NAME}"
  else
    printf "%bERROR:  %b Failed to set HOST_NAME by Environment Variable.\n" "${RED}" "${BLANK}"
    exit_err
  fi
  if [[ -n "${_HOST_NAME}" ]]; then
    if _HOST_NAME=$(hostname); then
      printf "%bINFO:   %b HOST_NAME was determined and set to '%s'.\n" "${CYAN}" "${BLANK}" "${_HOST_NAME}"
    else
      printf "%bERROR:  %b HOST_NAME was not set and could not be determined. `
              `Please set HOST_NAME in '.env' file or via '-a' flag.\n" "${RED}" "${BLANK}"
      exit_err
    fi
  fi
fi

# Set TIMEZONE
if [[ -n "${_FLAG_TIMEZONE}" ]]; then
  if _TIMEZONE="${_FLAG_TIMEZONE}"; then
    printf "%bINFO:   %b TIMEZONE set by CLI argument to '%s'.\n" "${CYAN}" "${BLANK}" "${_TIMEZONE}"
  else
    printf "%bERROR:  %b Failed to set TIMEZONE by CLI argument.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${TIMEZONE}" ]]; then
  if _TIMEZONE="${TIMEZONE}"; then
    printf "%bINFO:   %b TIMEZONE set by .env file to '%s'.\n" "${CYAN}" "${BLANK}" "${_TIMEZONE}"
  else
    printf "%bERROR:  %b Failed to set TIMEZONE by .env file.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${_ENV_TIMEZONE}" ]]; then
  if _TIMEZONE="${_ENV_TIMEZONE}"; then
    printf "%bINFO:   %b TIMEZONE set by Environment Variable to '%s'.\n" "${CYAN}" "${BLANK}" "${_TIMEZONE}"
  else
    printf "%bERROR:  %b Failed to set TIMEZONE by Environment Variable.\n" "${RED}" "${BLANK}"
    exit_err
  fi
  if [[ -n "${_TIMEZONE}" ]]; then
    if _TIMEZONE=$(timedatectl | grep 'Time zone' | awk '{print $3}'); then
      printf "%bINFO:   %b TIMEZONE was determined and set to '%s'.\n" "${CYAN}" "${BLANK}" "${_TIMEZONE}"
    else
      printf "%bERROR:  %b TIMEZONE was not set and could not be determined. `
              `Please set TIMEZONE in '.env' file or via '-a' flag.\n" "${RED}" "${BLANK}"
      exit_err
    fi
  fi
fi

# Set DOMAIN or create with HOSTNAME
if [[ -n "${_FLAG_DOMAIN}" ]]; then
  if _DOMAIN="${_FLAG_DOMAIN}"; then
    printf "%bINFO:   %b DOMAIN set by CLI argument to '%s'.\n" "${CYAN}" "${BLANK}" "${_DOMAIN}"
  else
    printf "%bERROR:  %b Failed to set DOMAIN by CLI argument.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${DOMAIN}" ]]; then
  if _DOMAIN="${DOMAIN}"; then
    printf "%bINFO:   %b DOMAIN set by .env file to '%s'.\n" "${CYAN}" "${BLANK}" "${_DOMAIN}"
  else
    printf "%bERROR:  %b Failed to set DOMAIN by .env file.\n" "${RED}" "${BLANK}"
    exit_err
  fi
elif [[ -n "${_ENV_DOMAIN}" ]]; then
  if _DOMAIN="${_ENV_DOMAIN}"; then
    printf "%bINFO:   %b DOMAIN set by Environment Variable to '%s'.\n" "${CYAN}" "${BLANK}" "${_DOMAIN}"
  else
    printf "%bERROR:  %b Failed to set DOMAIN by Environment Variable.\n" "${RED}" "${BLANK}"
    exit_err
  fi
  if [[ -n "${_DOMAIN}" ]]; then
    if _DOMAIN="${_HOST_NAME}.dns"; then
      printf "%bINFO:   %b DOMAIN was determined and set to '%s'.\n" "${CYAN}" "${BLANK}" "${_DOMAIN}"
    else
      printf "%bERROR:  %b DOMAIN was not set and could not be created. `
              `Please set DOMAIN in '.env' file or via '-a' flag.\n" "${RED}" "${BLANK}"
      exit_err
    fi
  fi
fi

# Set TRAEFIK_AUTH
if ! [ -f traefik-docker/shared/.htpasswd ] || [[ "${_FLAG_TRAEFIK_NOAUTH}" == 'y' ]]; then
  _TRAEFIK_AUTH="NoAuth"
  printf "%bINFO:   %b Treafik dashboard authorization is set to %bINACTIVE%b.\n" \
          "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
else
  _TRAEFIK_AUTH="Auth"
  printf "%bINFO:   %b Treafik dashboard authorization is set to %bACTIVE%b.\n" \
          "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
fi


# ##########################################################################################
### Change architecture specific stuff based on ARCHITECTURE
# Set varinat of unbound to use
if printf "%s" "${_ARCHITECTURE}" | grep -iq arm; then
  _UNBOUND_VARIANT="unbound-rpi"
elif printf "%s" "${_ARCHITECTURE}" | grep -iq x86; then
  _UNBOUND_VARIANT="unbound"
else
  printf "%bERROR:  %b Invalid architecture. Only 'ARM' and 'x86' are allowed.\n" "${RED}" "${BLANK}"
  exit_err
fi

# Compile doh server image
if [[ "${_FLAG_COMPILE}" == 'y' ]] ||
    ! docker images | grep -q 'goofball222/dns-over-https' && printf "%s" "${_ARCHITECTURE}" | grep -iq arm ||
    [[ "${_FLAG_UPDATE_ALL}" == 'y' ]] && printf "%s" "${_ARCHITECTURE}" | grep -iq arm; then
  if
    VERSION="$(git ls-remote -t --refs  https://github.com/m13253/dns-over-https.git | tail -n1 |
                awk '{print $2}' | sed 's,refs/tags/v,,')" &&
    CUR_DIR="$(pwd)" &&
    printf "%bINFO:   %b Compiling image for 'goofball222/dns-over-https' for version %s.\n" \
            "${CYAN}" "${BLANK}" "${VERSION}." &&
    mkdir -p ~/dns-over-https_tmp && cd ~/dns-over-https_tmp &&
    git clone https://github.com/goofball222/dns-over-https.git && cd dns-over-https &&
    printf "%s" "${VERSION}" | tee 'stable/VERSION' > /dev/null && sudo make &&
    cd "${CUR_DIR}" && rm -rf ~/dns-over-https_tmp
  then
    printf "%bSUCCESS:%b Image compiled.\n" "${GREEN}" "${BLANK}"
  else
    printf "%bERROR:  %b Compiling failed. Deleting '~/dns-over-https_tmp' directory.\n" "${RED}" "${BLANK}"
    rm -rf ~/dns-over-https_tmp ||
      printf "%bERROR:  %b Failed to delete '~/dns-over-https_tmp' directory.\n" "${RED}" "${BLANK}"
    exit_err
  fi
fi


# ##########################################################################################
# Download root.hints file
printf "\n%bINFO:   %b Checking for 'root.hints' file.\n" "${CYAN}" "${BLANK}"
if ! [ -f unbound-docker/var/root.hints ]; then
  if wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
    printf "%bSUCCESS:%b 'root.hints' file downloaded.\n" "${GREEN}" "${BLANK}"
  else
    printf "%bERROR:  %b 'root.hints' file download failed.\n" "${RED}" "${BLANK}"
    exit_err
  fi
else
  (( DIFF = ($(date +%s) - $(stat -c %Z unbound-docker/var/root.hints))/3600 ))
  if ((DIFF > 1)) || [[ "${_FLAG_FRESH}" == 'y' ]]; then
    if wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
      printf "%bSUCCESS:%b 'root.hints' file updated.\n" "${GREEN}" "${BLANK}"
    else
      printf "%bWARNING:%b 'root.hints' file update failed.\n" "${ORANGE}" "${BLANK}"
    fi
  else
    printf "%bSUCCESS:%b 'root.hints' file found.\n" "${GREEN}" "${BLANK}"
  fi
fi


# ##########################################################################################
### Check encryption file stuff
printf "\n%bINFO:   %b Checking for TLS files.\n" "${CYAN}" "${BLANK}"
# Check for 'cert.crt' file
printf "%bINFO:   %b Checking for cert.crt file.\n" "${CYAN}" "${BLANK}"
if [ -f certificates/cert.crt ]; then
  printf "%bSUCCESS:%b Found cert.crt file.\n" "${GREEN}" "${BLANK}"
else
  printf "%bERROR:  %b No 'cert.crt' file found. Please add a 'cert.crt' file to certificates/.`
          ` Then restart this script.\n" "${RED}" "${BLANK}"
  exit_err
fi

# Check for 'key.key' file
printf "%bINFO:   %b Checking for key.key file.\n" "${CYAN}" "${BLANK}"
if [ -f certificates/key.key ]; then
  printf "%bSUCCESS:%b Found key.key file.\n" "${GREEN}" "${BLANK}"
else
  printf "%bERROR:  %b No 'key.key' file found. Please add a 'key.key' file to certificates/.`
          ` Then restart this script.\n" "${RED}" "${BLANK}"
  exit_err
fi

# Check for 'dhparam.pem' file
printf "%bINFO:   %b Checking for dhparam.pem file.\n" "${CYAN}" "${BLANK}"
if [ -f certificates/dhparam.pem ]; then
  printf "%bSUCCESS:%b Found dhparam.pem file.\n" "${GREEN}" "${BLANK}"
else
  printf "%bERROR:  %b No 'dhparam.pem' file found. Please add a 'dhparam.pem' file to certificates/.`
          ` Then restart this script.\n" "${RED}" "${BLANK}"
  exit_err
fi


# ##########################################################################################
# Creating/Overwriting '.env' file
if [ -f .env ]; then
  printf "\n%bINFO:   %b Overwriting '.env' file.\n" "${CYAN}" "${BLANK}"
  _NEW_ENV='Overwrote'
else
  printf "\n%bINFO:   %b Creating '.env' file.\n" "${CYAN}" "${BLANK}"
  _NEW_ENV='Created new'
fi
if printf "HOST_NAME=%s\nDOMAIN=%s\nTIMEZONE=%s\nUNBOUND_VARIANT=%s\nARCHITECTURE=%s\nINTERFACE=%s\nHOST_IP=%s`
            `\nTRAEFIK_AUTH=%s" "${_HOST_NAME}" "${_DOMAIN}" "${_TIMEZONE}" "${_UNBOUND_VARIANT}" "${_ARCHITECTURE}" \
            "${_INTERFACE}" "${_HOST_IP}" "${_TRAEFIK_AUTH}" | tee .env > /dev/null; then
  printf "%bSUCCESS:%b ${_NEW_ENV} '.env' file.\n" "${GREEN}" "${BLANK}"
else
  if [ -f .env ]; then
    printf "%bERROR:  %b Error while creating '.env' file. Data could not be gathered and empty file was created. `
            `Please add necessary settings (ServerIP, DOMAIN and TZ) manually.\n" "${RED}" "${BLANK}"
    exit_err
  else
    printf "%bERROR:  %b Error while creating '.env' file. The file was not created.\n" "${RED}" "${BLANK}"
    exit_err
  fi
fi


# ##########################################################################################
# Setup finish & run start line
printf "\n\n%bSUCCESS:%b Setup for DoTH-DNS finished.\n" "${GREEN}" "${BLANK}"
printf "\n####################\n"
printf "\n%bINFO:   %b Starting DoTH-DNS.\n\n\n" "${CYAN}" "${BLANK}"


# ##########################################################################################
# Different start compositions
if [[ "${_FLAG_NO_PROXY}" == 'y' ]]; then
  if [[ "${_FLAG_UPDATE_ALL}" == 'y' ]]; then
    printf "%bINFO:   %b Updating DoTH-DNS without reverse proxy.\n" "${CYAN}" "${BLANK}"
    docker-compose down || exit_dc_err
    if printf "%s" "${_ARCHITECTURE}" | grep -iq arm; then
      docker-compose pull pihole unbound || exit_dc_err
    else
      docker-compose pull || exit_dc_err
    fi
    docker-compose up -d --force-recreate || exit_dc_err
  elif [[ "${_FLAG_RECREATE_ALL}" == 'y' ]]; then
    printf "%bINFO:   %b Recreating DoTH-DNS without reverse proxy.\n" "${CYAN}" "${BLANK}"
    docker-compose up -d --force-recreate || exit_dc_err
  else
    printf "%bINFO:   %b Creating DoTH-DNS without reverse proxy.\n" "${CYAN}" "${BLANK}"
    docker-compose up -d || exit_dc_err
  fi
else
  if [[ "${_FLAG_UPDATE_ALL}" == 'y' ]]; then
    printf "%bINFO:   %b Updating DoTH-DNS with %btraefik%b reverse proxy.\n" \
            "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml down || exit_dc_err
    if printf "%s" "${_ARCHITECTURE}" | grep -iq arm; then
      docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml pull pihole unbound traefik || exit_dc_err
    else
      docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml pull || exit_dc_err
    fi
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml up -d || exit_dc_err
  elif [[ "${_FLAG_RECREATE_ALL}" == 'y' ]]; then
    printf "%bINFO:   %b Recreating DoTH-DNS with %btraefik%b reverse proxy.\n" \
            "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml up -d --force-recreate || exit_dc_err
  else
    printf "%bINFO:   %b Creating DoTH-DNS with %btraefik%b reverse proxy.\n" \
            "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml up -d || exit_dc_err
  fi
fi


# ##########################################################################################
### Testing unbound-docker
# Check if container started and works; timeout after 1 min
printf "\n%bINFO:   %b Starting up unbound container " "${CYAN}" "${BLANK}"
for i in $(seq 1 20); do
  if [ "$(docker inspect -f "{{.State.Health.Status}}" unbound)" == "healthy" ]; then
    printf " %bOK%b\n" "${GREEN}" "${BLANK}"
    break
  else
    sleep 3
    printf "."
  fi

  if [ "$i" -eq 20 ]; then
    printf " %bFAILED%b\n" "${RED}" "${BLANK}"
    printf "%bERROR:  %b Timed out waiting for unbound to start, check your container logs for more info `
            `(\`docker logs unbound\`).\n" "${RED}" "${BLANK}"
    printf "%bINFO:   %b Container health status of 'unbound': `
            `%b$(docker inspect -f "{{.State.Health.Status}}" unbound)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
    exit_err
  fi
done;
printf "%bINFO:   %b Container health status of 'unbound': `
        `%b$(docker inspect -f "{{.State.Health.Status}}" unbound)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"

# Test DNSSEC - The first command should give a status report of SERVFAIL and no IP address.
# The second should give NOERROR plus an IP address.
TEST=$(docker exec unbound drill sigfail.verteiltesysteme.net @127.0.0.1 -p 53)
if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 0 ] &&
        [ "$(echo "$TEST" | grep -c 'rcode: SERVFAIL')" = 1 ]; then
  TEST=$(docker exec unbound drill sigok.verteiltesysteme.net @127.0.0.1 -p 53)
  if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 1 ] &&
        [ "$(echo "$TEST" | grep -c 'rcode: NOERROR')" = 1 ]; then
    printf "%bSUCCESS:%b DNSSEC works.\n" "${GREEN}" "${BLANK}"
  else
    printf "%bWARNING:%b DNSSEC fail with second check (positiv check).\n" "${ORANGE}" "${BLANK}"
  fi
else
  printf "%bWARNING:%b DNSSEC fail with first check (negativ check).\n" "${ORANGE}" "${BLANK}"
fi


# ##########################################################################################
### Testing pihole-docker
# Check if container started and works; timeout after 1 min
printf "\n%bINFO:   %b Starting up pihole container " "${CYAN}" "${BLANK}"
for i in $(seq 1 20); do
  if [ "$(docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ]; then
    printf " %bOK%b\n" "${GREEN}" "${BLANK}"
    if [ "$(docker logs pihole 2> /dev/null | grep -c 'Setting password:')" -gt 0 ]; then
      printf "%bINFO:   %b $(docker logs pihole 2> /dev/null |
            grep 'Setting password:') for your pi-hole: https://pi.hole/admin/.\n" "${CYAN}" "${BLANK}"
      RAN_PW='y'
    else
      printf "%bINFO:   %b Set given WEBPASSWORD for your pi-hole: https://pi.hole/admin/.\n" "${CYAN}" "${BLANK}"
      RAN_PW='n'
    fi
    break
  else
    sleep 3
    printf "."
  fi

  if [ "$i" -eq 20 ]; then
    printf " %bFAILED%b\n" "${RED}" "${BLANK}"
    printf "%bERROR:  %b Timed out waiting for Pi-hole to start, check your container logs for more info `
            `(\`docker logs pihole\`).\n" "${RED}" "${BLANK}"
    printf "%bINFO:   %b Container health status of 'pihole': `
            `%b$(docker inspect -f "{{.State.Health.Status}}" pihole)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
    exit_err
  fi
done;
printf "%bINFO:   %b Container health status of 'pihole': `
        `%b$(docker inspect -f "{{.State.Health.Status}}" pihole)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"

# Check if blocklist setup is finished and when then restore custom conf; timeout after 10 min
printf "%bINFO:   %b Waiting for blocklist setup to finish " "${CYAN}" "${BLANK}"
for i in $(seq 1 60); do
  if [ "$(docker logs pihole 2> /dev/null | grep -c "\[services.d\] done.")" -gt 0 ]; then
    printf " %bOK%b\n" "${GREEN}" "${BLANK}"
    printf "%bSUCCESS:%b Blocklist setup finished.\n" "${GREEN}" "${BLANK}"
    break
  else
    sleep 10
    printf "."
  fi

  if [ "$i" -eq 60 ]; then
    printf " %bFAILED%b\n" "${RED}" "${BLANK}"
    printf "%bERROR:  %b Timed out waiting for blocklists to set up, check your container logs for more info `
            `(\`docker logs pihole\`).\n" "${RED}" "${BLANK}"
    exit_err
  fi
done;


# ##########################################################################################
### Testing doh_server-docker
# Check if container started and is running; timeout after 1 min
printf "\n%bINFO:   %b Starting up doh_server container " "${CYAN}" "${BLANK}"
for i in $(seq 1 20); do
  if [ "$(docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
    if [ "$(docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
      sleep 5
      printf " %bOK%b\n" "${GREEN}" "${BLANK}"
    fi
    break
  else
    sleep 3
    printf "."
  fi

  if [ "$i" -eq 20 ]; then
    printf " %bFAILED%b\n" "${RED}" "${BLANK}"
    printf "%bERROR:  %b Timed out waiting for doh_server to start, check your container logs for more info `
            `(\`docker logs doh_server\`).\n" "${RED}" "${BLANK}"
    printf "%bINFO:   %b Container health status of 'doh_server': `
            `%b$(docker inspect -f "{{.State.Status}}" doh_server)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
    exit_err
  fi
done;
printf "%bINFO:   %b Container health status of 'doh_server': `
        `%b$(docker inspect -f "{{.State.Status}}" doh_server)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"


# ##########################################################################################
### Testing traefik-docker
if ! [[ "${_FLAG_NO_PROXY}" == 'y' ]]; then
  # Check if container started and is running; timeout after 1 min
  printf "\n%bINFO:   %b Starting up traefik container " "${CYAN}" "${BLANK}"
  for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Status}}" traefik)" == "running" ]; then
      if [ "$(docker inspect -f "{{.State.Status}}" traefik)" == "running" ]; then
        sleep 5
        printf " %bOK%b\n" "${GREEN}" "${BLANK}"
      fi
      break
    else
      sleep 3
      printf "."
    fi

    if [ "$i" -eq 20 ]; then
      printf " %bFAILED%b\n" "${RED}" "${BLANK}"
      printf "%bERROR:  %b Timed out waiting for traefik to start, check your container logs for more info `
              `(\`docker logs traefik\`).\n" "${RED}" "${BLANK}"
      printf "%bINFO:   %b Container health status of 'traefik': `
            `%b$(docker inspect -f "{{.State.Status}}" traefik)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
      exit_err
    fi
  done;
  printf "%bINFO:   %b Container health status of 'traefik': `
          `%b$(docker inspect -f "{{.State.Status}}" traefik)%b\n" "${CYAN}" "${BLANK}" "${CYAN}" "${BLANK}"
fi

# ##########################################################################################
# Finishing line
printf "\n\n%bSUCCESS:%b DoTH-DNS is up and running.\n" "${GREEN}" "${BLANK}"
printf "\n####################\n\n"


# ##########################################################################################
# Warning when default random password is set at pihole
if echo "${RAN_PW}" | grep -q 'y'; then
  printf "%bATTENTION:%b\nPlease don't forget to set a secure password for your pihole dashboard.\n`
          `Run 'docker exec pihole pihole -a -p <NEW PASSWORD>' to change it.\n\n" "${ORANGE}" "${BLANK}"
fi
