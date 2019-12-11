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

# Message category variables
ERROR="${RED}ERROR:  ${BLANK}"
SUCCESS="${GREEN}SUCCESS:${BLANK}"
WARNING="${ORANGE}WARNING:${BLANK}"
INFO="${CYAN}INFO:   ${BLANK}"


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
  printf "\nUsage: %s [-f] [-F] [-a <arm|x86>] [-c] [-I <INTERFACE>] [-i <IP ADDRESS>] `
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
while getopts ":fFa:cI:i:n:t:d:NRUPDh" flag; do
  case ${flag} in
    f) # Set for overwriting existing configs with new ones.
      _FLAG_FRESH='y'
      ;;
    F) # Set to let the script fallback to next source for configuration variables. Order: `flag -> environment -> .env file -> self gather`
      _FLAG_FALLBACK='y'
      ;;
    a) # Set ARCHITECTURE variable with 'ARM' or 'x86' (case insensitive).
      if ! [[ "${OPTARG,,}" == 'arm' ]] && ! [[ "${OPTARG,,}" == 'x86' ]]; then
        printf "No valid argument for '-a'.\n"
        exit_arg_err
      fi
      # shellcheck disable=SC2034  # Variable(s) is/are referenced indirectly
      _FLAG_ARCHITECTURE=${OPTARG,,}
      ;;
    c) # Set for force compiling the 'goofball222/dns-over-https' docker image.
      _FLAG_COMPILE='y'
      ;;
    I) # Set INTERFACE variable with <INTERFACE>. E.g. eth0
      # shellcheck disable=SC2034  # Variable(s) is/are referenced indirectly
      _FLAG_INTERFACE=${OPTARG}
      ;;
    i) # Set HOST_IP variable with <IP ADDRESS>. E.g. 192.168.0.2
      # shellcheck disable=SC2034  # Variable(s) is/are referenced indirectly
      _FLAG_HOST_IP=${OPTARG}
      ;;
    n) # Set HOST_NAME variable with <HOSTNAME>. E.g. raspberry
      # shellcheck disable=SC2034  # Variable(s) is/are referenced indirectly
      _FLAG_HOST_NAME=${OPTARG}
      ;;
    t) # Set TIMEZONE variable with <TIMEZONE>. Format e.g. Europe/London
      # shellcheck disable=SC2034  # Variable(s) is/are referenced indirectly
      _FLAG_TIMEZONE=${OPTARG}
      ;;
    d) # Set DOMAIN variable with <DOMAIN>. E.g. example.com
      # shellcheck disable=SC2034  # Variable(s) is/are referenced indirectly
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
  printf "\n%b Shutting DoTH-DNS down.\n\n" "${INFO}"
  docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml down || exit_dc_err
  printf "\n\n%b DoTH-DNS shut down.\n" "${SUCCESS}"
  printf "\n####################\n\n"
  exit 0
fi


# ##########################################################################################
# Starting line
printf "\n####################\n"
printf "\n%b Starting setup for DoTH-DNS.\n\n\n" "${INFO}"


# ##########################################################################################
# Load .env file
if [[ ${_FLAG_FRESH} == 'y' ]]; then
  printf "%b Skipped loading of '.env'.\n\n" "${INFO}"
else
  if [[ -f .env ]]; then
    if . .env; then
      printf "%b .env loaded.\n\n" "${INFO}"
    else
      printf "%b Failed to load '.env'. Falling back to self gather information.\n\n" "${WARNING}"
    fi
  else
    printf "%b No '.env' file found. Falling back to self gather information.\n\n" "${WARNING}"
  fi
fi


# ##########################################################################################
# Grabbing EnvVars
if [[ ${_FLAG_FRESH} == 'y' ]]; then
  printf "%b Skipped loading of Environment Variables.\n\n" "${INFO}"
else
  # shellcheck disable=SC2034  # Variable(s) is/are referenced indirectly
  if \
  _ENV_ARCHITECTURE=${DOTH_ARCHITECTURE} &&
  _ENV_INTERFACE=${DOTH_INTERFACE} &&
  _ENV_HOST_IP=${DOTH_HOST_IP} &&
  _ENV_HOST_NAME=${DOTH_HOST_NAME} &&
  _ENV_TIMEZONE=${DOTH_TIMEZONE} &&
  _ENV_DOMAIN=${DOTH_DOMAIN}
  then
    printf "%b Environment Variables loaded.\n\n" "${INFO}"
  else
    printf "%b No Environment Variables could be loaded. Falling back to self gather information.\n\n" \
            "${WARNING}"
  fi
fi


# ##########################################################################################
### Check and set ENV Vars
# Put config vars and sources into arrays
_CONF_VARS=(ARCHITECTURE INTERFACE HOST_IP HOST_NAME TIMEZONE DOMAIN)
_CONF_SOURCES=(FLAG ENV DOT_ENV)

# Loop trough config vars
for _CONF_VAR in "${_CONF_VARS[@]}"; do

  # Set loop variable
  _CONF_VAR_UC="_$_CONF_VAR"
  _FALLBACK_START=""

  # Loop trough sources
  for _CONF_SOURCE in "${_CONF_SOURCES[@]}"; do

    # Set variables according to source
    case ${_CONF_SOURCE} in
      FLAG)
        _CONF_SOURCE_VAR="_FLAG_$_CONF_VAR"
        _CONF_SOURCE_MESSAGE="'CLI argument'"
        ;;
      ENV)
        _CONF_SOURCE_VAR="_ENV_$_CONF_VAR"
        _CONF_SOURCE_MESSAGE="'Environment Variable'"
        ;;
      DOT_ENV)
        _CONF_SOURCE_VAR="$_CONF_VAR"
        _CONF_SOURCE_MESSAGE="'.env file'"
        ;;
    esac

    # Gather config from source
    if [[ -z "${!_CONF_VAR_UC}" ]]; then
      if [[ -n "${!_CONF_SOURCE_VAR}" ]]; then
        if eval "${_CONF_VAR_UC}"='${!_CONF_SOURCE_VAR}'; then
          printf "%b %s set to '%s' by %s.\n" "${INFO}" "${_CONF_VAR}" "${!_CONF_VAR_UC}" \
                  "${_CONF_SOURCE_MESSAGE}"
        else
          if [[ "${_FLAG_FALLBACK}" == 'y' ]]; then
            _FALLBACK_START="y"
            printf "%b Failed to set %s by %s. Falling back to next source.\n" "${WARNING}" \
                    "${_CONF_VAR}" "${_CONF_SOURCE_MESSAGE}"
          else
            printf "%b Failed to set %s by %s. Fallback to other sources is deactivated.\n" "${ERROR}" \
                    "${_CONF_VAR}" "${_CONF_SOURCE_MESSAGE}"
            exit_err
          fi
        fi
      elif [[ "${_FALLBACK_START}" == 'y' ]]; then
        printf "%b Failed to set %s by %s because not set. Falling back to next source.\n" \
                "${WARNING}" "${_CONF_VAR}" "${_CONF_SOURCE_MESSAGE}"
      fi
    fi

  done

  # Self gather config via command
  if [[ -z "${!_CONF_VAR_UC}" ]]; then
    case "${_CONF_VAR}" in
      ARCHITECTURE)
        _ARCHITECTURE=$(lscpu | grep Architecture: | awk '{print $2}')
        ;;
      INTERFACE)
        _INTERFACE=$(route | grep '^default' | grep -o '[^ ]*$')
        ;;
      HOST_IP)
        _HOST_IP=$(ifconfig "${_INTERFACE}" | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
        ;;
      HOST_NAME)
        _HOST_NAME=$(hostname)
        ;;
      TIMEZONE)
        _TIMEZONE=$(timedatectl | grep 'Time zone' | awk '{print $3}')
        ;;
      DOMAIN)
        _DOMAIN="${_HOST_NAME}".dns
        ;;
    esac

    if [[ -n "${!_CONF_VAR_UC}" ]]; then
      printf "%b %s set to '%s' by determining from system.\n" "${INFO}" "${_CONF_VAR}" \
              "${!_CONF_VAR_UC}"
    else
      printf "%b %s was not set and could not be determined. `
              `Please set %s via '-a' flag, in the shell environment or in '.env' file.\n" "${ERROR}" \
              "${_CONF_VAR}" "${_CONF_VAR}"
      exit_err
    fi
  fi

done


# ##########################################################################################
# Set TRAEFIK_AUTH
if ! [ -f traefik-docker/shared/.htpasswd ] || [[ "${_FLAG_TRAEFIK_NOAUTH}" == 'y' ]]; then
  _TRAEFIK_AUTH="NoAuth"
  printf "\n%b Treafik dashboard authorization is set to %bINACTIVE%b.\n" \
          "${INFO}" "${CYAN}" "${BLANK}"
else
  _TRAEFIK_AUTH="Auth"
  printf "\n%b Treafik dashboard authorization is set to %bACTIVE%b.\n" \
          "${INFO}" "${CYAN}" "${BLANK}"
fi


# ##########################################################################################
### Change architecture specific stuff based on ARCHITECTURE
# Set varinat of unbound to use
if printf "%s" "${_ARCHITECTURE}" | grep -iq arm; then
  _UNBOUND_VARIANT="unbound-rpi"
elif printf "%s" "${_ARCHITECTURE}" | grep -iq x86; then
  _UNBOUND_VARIANT="unbound"
else
  printf "%b Invalid architecture. Only 'ARM' and 'x86' are allowed.\n" "${ERROR}"
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
    printf "%b Compiling image for 'goofball222/dns-over-https' for version %s.\n" \
            "${INFO}" "${VERSION}." &&
    mkdir -p ~/dns-over-https_tmp && cd ~/dns-over-https_tmp &&
    git clone https://github.com/goofball222/dns-over-https.git && cd dns-over-https &&
    printf "%s" "${VERSION}" | tee 'stable/VERSION' > /dev/null && sudo make &&
    cd "${CUR_DIR}" && rm -rf ~/dns-over-https_tmp
  then
    printf "%b Image compiled.\n" "${SUCCESS}"
  else
    printf "%b Compiling failed. Deleting '~/dns-over-https_tmp' directory.\n" "${ERROR}"
    rm -rf ~/dns-over-https_tmp ||
      printf "%b Failed to delete '~/dns-over-https_tmp' directory.\n" "${ERROR}"
    exit_err
  fi
fi


# ##########################################################################################
# Download root.hints file
printf "\n%b Checking for 'root.hints' file.\n" "${INFO}"
if ! [ -f unbound-docker/var/root.hints ]; then
  if wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
    printf "%b 'root.hints' file downloaded.\n" "${SUCCESS}"
  else
    printf "%b 'root.hints' file download failed.\n" "${ERROR}"
    exit_err
  fi
else
  (( DIFF = ($(date +%s) - $(stat -c %Z unbound-docker/var/root.hints))/3600 ))
  if ((DIFF > 1)) || [[ "${_FLAG_FRESH}" == 'y' ]]; then
    if wget -nv https://www.internic.net/domain/named.root -O unbound-docker/var/root.hints; then
      printf "%b 'root.hints' file updated.\n" "${SUCCESS}"
    else
      printf "%b 'root.hints' file update failed.\n" "${WARNING}"
    fi
  else
    printf "%b 'root.hints' file found.\n" "${SUCCESS}"
  fi
fi


# ##########################################################################################
### Check encryption file stuff
printf "\n%b Checking for TLS files.\n" "${INFO}"
# Check for 'cert.crt' file
printf "%b Checking for cert.crt file.\n" "${INFO}"
if [ -f certificates/cert.crt ]; then
  printf "%b Found cert.crt file.\n" "${SUCCESS}"
else
  printf "%b No 'cert.crt' file found. Please add a 'cert.crt' file to certificates/.`
          ` Then restart this script.\n" "${ERROR}"
  exit_err
fi

# Check for 'key.key' file
printf "%b Checking for key.key file.\n" "${INFO}"
if [ -f certificates/key.key ]; then
  printf "%b Found key.key file.\n" "${SUCCESS}"
else
  printf "%b No 'key.key' file found. Please add a 'key.key' file to certificates/.`
          ` Then restart this script.\n" "${ERROR}"
  exit_err
fi

# Check for 'dhparam.pem' file
printf "%b Checking for dhparam.pem file.\n" "${INFO}"
if [ -f certificates/dhparam.pem ]; then
  printf "%b Found dhparam.pem file.\n" "${SUCCESS}"
else
  printf "%b No 'dhparam.pem' file found. Please add a 'dhparam.pem' file to certificates/.`
          ` Then restart this script.\n" "${ERROR}"
  exit_err
fi


# ##########################################################################################
# Creating/Overwriting '.env' file
if [ -f .env ]; then
  printf "\n%b Overwriting '.env' file.\n" "${INFO}"
  _NEW_ENV='Overwrote'
else
  printf "\n%b Creating '.env' file.\n" "${INFO}"
  _NEW_ENV='Created new'
fi
if printf "HOST_NAME=%s\nDOMAIN=%s\nTIMEZONE=%s\nUNBOUND_VARIANT=%s\nARCHITECTURE=%s\nINTERFACE=%s\nHOST_IP=%s`
            `\nTRAEFIK_AUTH=%s" "${_HOST_NAME}" "${_DOMAIN}" "${_TIMEZONE}" "${_UNBOUND_VARIANT}" "${_ARCHITECTURE}" \
            "${_INTERFACE}" "${_HOST_IP}" "${_TRAEFIK_AUTH}" | tee .env > /dev/null; then
  printf "%b ${_NEW_ENV} '.env' file.\n" "${SUCCESS}"
else
  if [ -f .env ]; then
    printf "%b Error while creating '.env' file. Data could not be gathered and empty file was created. `
            `Please add necessary settings (ServerIP, DOMAIN and TZ) manually.\n" "${ERROR}"
    exit_err
  else
    printf "%b Error while creating '.env' file. The file was not created.\n" "${ERROR}"
    exit_err
  fi
fi


# ##########################################################################################
# Setup finish & run start line
printf "\n\n%b Setup for DoTH-DNS finished.\n" "${SUCCESS}"
printf "\n####################\n"
printf "\n%b Starting DoTH-DNS.\n\n\n" "${INFO}"


# ##########################################################################################
# Different start compositions
if [[ "${_FLAG_NO_PROXY}" == 'y' ]]; then
  if [[ "${_FLAG_UPDATE_ALL}" == 'y' ]]; then
    printf "%b Updating DoTH-DNS without reverse proxy.\n" "${INFO}"
    docker-compose down || exit_dc_err
    if printf "%s" "${_ARCHITECTURE}" | grep -iq arm; then
      docker-compose pull pihole unbound || exit_dc_err
    else
      docker-compose pull || exit_dc_err
    fi
    docker-compose up -d --force-recreate || exit_dc_err
  elif [[ "${_FLAG_RECREATE_ALL}" == 'y' ]]; then
    printf "%b Recreating DoTH-DNS without reverse proxy.\n" "${INFO}"
    docker-compose up -d --force-recreate || exit_dc_err
  else
    printf "%b Creating DoTH-DNS without reverse proxy.\n" "${INFO}"
    docker-compose up -d || exit_dc_err
  fi
else
  if [[ "${_FLAG_UPDATE_ALL}" == 'y' ]]; then
    printf "%b Updating DoTH-DNS with %btraefik%b reverse proxy.\n" \
            "${INFO}" "${CYAN}" "${BLANK}"
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml down || exit_dc_err
    if printf "%s" "${_ARCHITECTURE}" | grep -iq arm; then
      docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml pull pihole unbound traefik || exit_dc_err
    else
      docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml pull || exit_dc_err
    fi
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml up -d || exit_dc_err
  elif [[ "${_FLAG_RECREATE_ALL}" == 'y' ]]; then
    printf "%b Recreating DoTH-DNS with %btraefik%b reverse proxy.\n" \
            "${INFO}" "${CYAN}" "${BLANK}"
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml up -d --force-recreate || exit_dc_err
  else
    printf "%b Creating DoTH-DNS with %btraefik%b reverse proxy.\n" \
            "${INFO}" "${CYAN}" "${BLANK}"
    docker-compose -f docker-compose.yaml -f docker-compose.traefik.yaml up -d || exit_dc_err
  fi
fi


# ##########################################################################################
### Testing unbound-docker
# Check if container started and works; timeout after 1 min
printf "\n%b Starting up unbound container " "${INFO}"
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
    printf "%b Timed out waiting for unbound to start, check your container logs for more info `
            `(\`docker logs unbound\`).\n" "${ERROR}"
    printf "%b Container health status of 'unbound': `
            `%b$(docker inspect -f "{{.State.Health.Status}}" unbound)%b\n" "${INFO}" "${CYAN}" "${BLANK}"
    exit_err
  fi
done;
printf "%b Container health status of 'unbound': `
        `%b$(docker inspect -f "{{.State.Health.Status}}" unbound)%b\n" "${INFO}" "${CYAN}" "${BLANK}"

# Test DNSSEC - The first command should give a status report of SERVFAIL and no IP address.
# The second should give NOERROR plus an IP address.
TEST=$(docker exec unbound drill sigfail.verteiltesysteme.net @127.0.0.1 -p 53)
if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 0 ] &&
        [ "$(echo "$TEST" | grep -c 'rcode: SERVFAIL')" = 1 ]; then
  TEST=$(docker exec unbound drill sigok.verteiltesysteme.net @127.0.0.1 -p 53)
  if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 1 ] &&
        [ "$(echo "$TEST" | grep -c 'rcode: NOERROR')" = 1 ]; then
    printf "%b DNSSEC works.\n" "${SUCCESS}"
  else
    printf "%b DNSSEC fail with second check (positiv check).\n" "${WARNING}"
  fi
else
  printf "%b DNSSEC fail with first check (negativ check).\n" "${WARNING}"
fi


# ##########################################################################################
### Testing pihole-docker
# Check if container started and works; timeout after 1 min
printf "\n%b Starting up pihole container " "${INFO}"
for i in $(seq 1 20); do
  if [ "$(docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ]; then
    printf " %bOK%b\n" "${GREEN}" "${BLANK}"
    if [ "$(docker logs pihole 2> /dev/null | grep -c 'Setting password:')" -gt 0 ]; then
      printf "%b $(docker logs pihole 2> /dev/null |
            grep 'Setting password:') for your pi-hole: https://pi.hole/admin/.\n" "${INFO}"
      RAN_PW='y'
    else
      printf "%b Set given WEBPASSWORD for your pi-hole: https://pi.hole/admin/.\n" "${INFO}"
      RAN_PW='n'
    fi
    break
  else
    sleep 3
    printf "."
  fi

  if [ "$i" -eq 20 ]; then
    printf " %bFAILED%b\n" "${RED}" "${BLANK}"
    printf "%b Timed out waiting for Pi-hole to start, check your container logs for more info `
            `(\`docker logs pihole\`).\n" "${ERROR}"
    printf "%b Container health status of 'pihole': `
            `%b$(docker inspect -f "{{.State.Health.Status}}" pihole)%b\n" "${INFO}" "${CYAN}" "${BLANK}"
    exit_err
  fi
done;
printf "%b Container health status of 'pihole': `
        `%b$(docker inspect -f "{{.State.Health.Status}}" pihole)%b\n" "${INFO}" "${CYAN}" "${BLANK}"

# Check if blocklist setup is finished and when then restore custom conf; timeout after 10 min
printf "%b Waiting for blocklist setup to finish " "${INFO}"
for i in $(seq 1 60); do
  if [ "$(docker logs pihole 2> /dev/null | grep -c "\[services.d\] done.")" -gt 0 ]; then
    printf " %bOK%b\n" "${GREEN}" "${BLANK}"
    printf "%b Blocklist setup finished.\n" "${SUCCESS}"
    break
  else
    sleep 10
    printf "."
  fi

  if [ "$i" -eq 60 ]; then
    printf " %bFAILED%b\n" "${RED}" "${BLANK}"
    printf "%b Timed out waiting for blocklists to set up, check your container logs for more info `
            `(\`docker logs pihole\`).\n" "${ERROR}"
    exit_err
  fi
done;


# ##########################################################################################
### Testing doh_server-docker
# Check if container started and is running; timeout after 1 min
printf "\n%b Starting up doh_server container " "${INFO}"
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
    printf "%b Timed out waiting for doh_server to start, check your container logs for more info `
            `(\`docker logs doh_server\`).\n" "${ERROR}"
    printf "%b Container health status of 'doh_server': `
            `%b$(docker inspect -f "{{.State.Status}}" doh_server)%b\n" "${INFO}" "${CYAN}" "${BLANK}"
    exit_err
  fi
done;
printf "%b Container health status of 'doh_server': `
        `%b$(docker inspect -f "{{.State.Status}}" doh_server)%b\n" "${INFO}" "${CYAN}" "${BLANK}"


# ##########################################################################################
### Testing traefik-docker
if ! [[ "${_FLAG_NO_PROXY}" == 'y' ]]; then
  # Check if container started and is running; timeout after 1 min
  printf "\n%b Starting up traefik container " "${INFO}"
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
      printf "%b Timed out waiting for traefik to start, check your container logs for more info `
              `(\`docker logs traefik\`).\n" "${ERROR}"
      printf "%b Container health status of 'traefik': `
            `%b$(docker inspect -f "{{.State.Status}}" traefik)%b\n" "${INFO}" "${CYAN}" "${BLANK}"
      exit_err
    fi
  done;
  printf "%b Container health status of 'traefik': `
          `%b$(docker inspect -f "{{.State.Status}}" traefik)%b\n" "${INFO}" "${CYAN}" "${BLANK}"
fi

# ##########################################################################################
# Finishing line
printf "\n\n%b DoTH-DNS is up and running.\n" "${SUCCESS}"
printf "\n####################\n\n"


# ##########################################################################################
# Warning when default random password is set at pihole
if echo "${RAN_PW}" | grep -q 'y'; then
  printf "%bATTENTION:%b\nPlease don't forget to set a secure password for your pihole dashboard.\n`
          `Run 'docker exec pihole pihole -a -p <NEW PASSWORD>' to change it.\n\n" "${ORANGE}" "${BLANK}"
fi
