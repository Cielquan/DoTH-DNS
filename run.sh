#!/bin/bash


# Color variables for output messages
RED='\033[0;31m' # For ERROR messages
GREEN='\033[0;32m' # For SUCCESS messages
ORANGE='\033[0;33m' # For WARNING messages
CYAN='\033[0;36m' # For INFO messages
BLANK='\033[0m' # For resetting colors


# Default value for variables
NO_PROXY='n'
PROXY='traefik'


# Func for showing usage string
usage_string() {
  echo -e "Usage: $0 [-R] [-U] [-h] [-p <traefik|nginx>] [-P]" 1>&2;
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

# Exit func for docker-compose error
exit_dc_err() {
  echo "docker(-compose) failed. You may need to restart the script with root privileges."
  exit 1
}

# Exit func for boot control errors
exit_err() {
  echo "Before you restart the script make sure the not working container is stopped, removed and fixed."
  exit 1
}


# Catching flags
while getopts ":RUhpP" flag; do
  case $flag in
    R) # Restart conatiners. Accutally a recreation of the containers taking in changed configs.
      RECREATE_ALL='y'
      ;;
    U) # Update containers.
      UPDATE_ALL='y'
      ;;
    h) # Shows this help page.
      help
      ;;
    p) # Set reverse proxy to use. 'ngnix' or 'traefik' (case insensitive). Default: traefik
      if ! echo "${OPTARG}" | grep -iq 'nginx' && ! echo "${OPTARG}" | grep -iq 'traefik'; then
        echo "No valid argument for '-p'."
        exit_flag_err
      fi
      PROXY=$(echo "${OPTARG}" | awk '{print tolower($0)}')
      ;;
    P) # Start without a reverse proxy. Overwrites '-p'.
      NO_PROXY='y'
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


# Different start compositions
if echo "${NO_PROXY}" | grep -q 'y'; then
  if echo "${UPDATE_ALL}" | grep -q 'y'; then
    echo -e "\n${CYAN}INFO${BLANK}: Updating DoTH-DNS without reverse proxy.\n"
    docker-compose down || exit_dc_err
    docker-compose pull || exit_dc_err
    docker-compose up -d --force-recreate || exit_dc_err
  elif echo "${RECREATE_ALL}" | grep -q 'y'; then
    echo -e "\n${CYAN}INFO${BLANK}: Recreating DoTH-DNS without reverse proxy.\n"
    docker-compose down || exit_dc_err
    docker-compose up -d --force-recreate || exit_dc_err
  else
    echo -e "\n${CYAN}INFO${BLANK}: Creating DoTH-DNS without reverse proxy.\n"
    docker-compose up -d --quiet-pull || exit_dc_err
  fi
else
  if echo "${UPDATE_ALL}" | grep -q 'y'; then
    echo -e "\n${CYAN}INFO${BLANK}: Updating DoTH-DNS with ${PROXY} reverse proxy.\n"
    docker-compose -f docker-compose.yaml -f docker-compose."${PROXY}".yaml down || exit_dc_err
    docker-compose -f docker-compose.yaml -f docker-compose."${PROXY}".yaml pull || exit_dc_err
    docker-compose -f docker-compose.yaml -f docker-compose."${PROXY}".yaml up -d --force-recreate || exit_dc_err
  elif echo "${RECREATE_ALL}" | grep -q 'y'; then
    echo -e "\n${CYAN}INFO${BLANK}: Recreating DoTH-DNS with ${PROXY} reverse proxy.\n"
    docker-compose -f docker-compose.yaml -f docker-compose."${PROXY}".yaml down || exit_dc_err
    docker-compose -f docker-compose.yaml -f docker-compose."${PROXY}".yaml up -d --force-recreate || exit_dc_err
  else
    echo -e "\n${CYAN}INFO${BLANK}: Creating DoTH-DNS with ${PROXY} reverse proxy.\n"
    docker-compose -f docker-compose.yaml -f docker-compose."${PROXY}".yaml up -d --quiet-pull || exit_dc_err
  fi
fi


echo -e "\n####################\n"
echo -e "${CYAN}INFO${BLANK}: Starting DoTH-DNS.\n"


# Testing unbound-docker
# Check if container started and works; timeout after 1 min
echo -e -n "${CYAN}INFO${BLANK}: Starting up unbound container "
for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Health.Status}}" unbound)" == "healthy" ]; then
        echo -e -n " ${GREEN}OK${BLANK}"
        break
    else
        sleep 3
        echo -e -n "."
    fi

    if [ "$i" -eq 20 ]; then
        echo -e -n " ${RED}FAILED${BLANK}"
        echo -e "\n${RED}ERROR${BLANK}: Timed out waiting for unbound to start, check your container logs for more info (\`docker logs unbound\`)."
        echo -e -n "${CYAN}INFO${BLANK}: Container health status of 'unbound': " && docker inspect -f {{.State.Health.Status}} unbound
        exit_err
    fi
done;
echo -e -n "\n${CYAN}INFO${BLANK}: Container health status of 'unbound': " && docker inspect -f {{.State.Health.Status}} unbound

# Test DNSSEC - The first command should give a status report of SERVFAIL and no IP address. The second should give NOERROR plus an IP address.
TEST=$(docker exec unbound drill sigfail.verteiltesysteme.net @127.0.0.1 -p 53)
if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 0 ] && [ "$(echo "$TEST" | grep -c 'rcode: SERVFAIL')" = 1 ]
then
    TEST=$(docker exec unbound drill sigok.verteiltesysteme.net @127.0.0.1 -p 53)
    if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 1 ] && [ "$(echo "$TEST" | grep -c 'rcode: NOERROR')" = 1 ]
    then
        echo -e "${GREEN}SUCCESS${BLANK}: DNSSEC works."
    else
        echo -e "${ORANGE}WARNING${BLANK}: DNSSEC fail with second check (positiv check)."
    fi
else
    echo -e "${ORANGE}WARNING${BLANK}: DNSSEC fail with first check (negativ check)."
fi


# Testing pihole-docker
# Check if container started and works; timeout after 1 min
echo -e -n "\n${CYAN}INFO${BLANK}: Starting up pihole container "
for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ]; then
        echo -e -n " ${GREEN}OK${BLANK}"
        HOST_IP=$(grep 'ServerIP' pihole-docker/configs/server.conf | sed 's/ServerIP=//')
        if [ "$(docker logs pihole 2> /dev/null | grep -c 'Setting password:')" -gt 0 ]; then
            echo -e "\n${CYAN}INFO${BLANK}: $(docker logs pihole 2> /dev/null | grep 'Setting password:') for your pi-hole: https://${HOST_IP}/admin/."
            RAN_PW='y'
        else
            echo -e "\n${CYAN}INFO${BLANK}: Set given WEBPASSWORD for your pi-hole: https://${HOST_IP}/admin/."
            RAN_PW='n'
        fi
        break
    else
        sleep 3
        echo -e -n "."
    fi

    if [ "$i" -eq 20 ]; then
        echo -e -n " ${RED}FAILED${BLANK}"
        echo -e "\n${RED}ERROR${BLANK}: Timed out waiting for Pi-hole to start, check your container logs for more info (\`docker logs pihole\`)."
        echo -e -n "${CYAN}INFO${BLANK}: Container health status of 'pihole': " && docker inspect -f {{.State.Health.Status}} pihole
        exit_err
    fi
done;
echo -e -n "${CYAN}INFO${BLANK}: Container health status of 'pihole': " && docker inspect -f {{.State.Health.Status}} pihole

# Check if blocklist setup is finished and when then restore custom conf; timeout after 10 min
echo -e -n "${CYAN}INFO${BLANK}: Waiting for blocklist setup to finish "
for i in $(seq 1 60); do
    if [ "$(docker logs pihole | grep -c "\[services.d\] done.")" -gt 0 ]; then
        echo -e -n " ${GREEN}OK${BLANK}"
        echo -e "\n ${CYAN}INFO${BLANK}: Blocklists setup finished."
        break
    else
        sleep 10
        echo -e -n "."
    fi

    if [ "$i" -eq 60 ]; then
        echo -e -n " ${RED}FAILED${BLANK}"
        echo -e "\n${RED}ERROR${BLANK}: Timed out waiting for blocklists to set up, check your container logs for more info (\`docker logs pihole\`)."
        exit_err
    fi
done;


# Testing doh_server-docker
# Check if container started and is running; timeout after 1 min
echo -e -n "\n${CYAN}INFO${BLANK}: Starting up doh_server container "
for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
        if [ "$(docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
            sleep 5
            echo -e -n " ${GREEN}OK${BLANK}"
        fi
        break
    else
        sleep 3
        echo -e -n "."
    fi

    if [ "$i" -eq 20 ]; then
        echo -e -n " ${RED}FAILED${BLANK}"
        echo -e "\n${RED}ERROR${BLANK}: Timed out waiting for doh_server to start, check your container logs for more info (\`docker logs doh_server\`)."
        echo -e -n "${CYAN}INFO${BLANK}: Container health status of 'doh_server': " && docker inspect -f {{.State.Status}} doh_server
        exit_err
    fi
done;
echo -e -n "\n${CYAN}INFO${BLANK}: Container health status of 'doh_server': " && docker inspect -f {{.State.Status}} doh_server


# Testing nginx-docker
if echo "${PROXY}" | grep -q 'traefik' || echo "${PROXY}" | grep -q 'nginx'; then
  # Check if container started and is running; timeout after 1 min
  echo -e -n "\n${CYAN}INFO${BLANK}: Starting up nginx container "
  for i in $(seq 1 20); do
      if [ "$(docker inspect -f "{{.State.Status}}" nginx)" == "running" ]; then
          sleep 5
          if [ "$(docker inspect -f "{{.State.Status}}" nginx)" == "running" ]; then
              echo -e -n " ${GREEN}OK${BLANK}"
              break
          fi
      else
          sleep 3
          echo -e -n "."
      fi

      if [ "$i" -eq 20 ]; then
          echo -e -n " ${RED}FAILED${BLANK}"
          echo -e "\n${RED}ERROR${BLANK}: Timed out waiting for nginx to start, check your container logs for more info (\`docker logs nginx\`)"
          echo -e -n "${CYAN}INFO${BLANK}: Container health status of 'nginx': " && docker inspect -f {{.State.Status}} nginx
          exit_err
      fi
  done;
  echo -e -n "\n${CYAN}INFO${BLANK}: Container health status of 'nginx': " && docker inspect -f {{.State.Status}} nginx
fi


# Testing traefik-docker
if echo "${PROXY}" | grep -q 'traefik'; then
  # Check if container started and is running; timeout after 1 min
  echo -e -n "\n${CYAN}INFO${BLANK}: Starting up traefik container "
  for i in $(seq 1 20); do
      if [ "$(docker inspect -f "{{.State.Status}}" traefik)" == "running" ]; then
          if [ "$(docker inspect -f "{{.State.Status}}" traefik)" == "running" ]; then
              sleep 5
              echo -e -n " ${GREEN}OK${BLANK}"
          fi
          break
      else
          sleep 3
          echo -e -n "."
      fi

      if [ "$i" -eq 20 ]; then
          echo -e -n " ${RED}FAILED${BLANK}"
          echo -e "\n${RED}ERROR${BLANK}: Timed out waiting for traefik to start, check your container logs for more info (\`docker logs traefik\`)."
          echo -e -n "${CYAN}INFO${BLANK}: Container health status of 'traefik': " && docker inspect -f {{.State.Status}} traefik
          exit_err
      fi
  done;
  echo -e -n "\n${CYAN}INFO${BLANK}: Container health status of 'traefik': " && docker inspect -f {{.State.Status}} traefik
fi


echo -e "\n${GREEN}SUCCESS${BLANK}: DoTH-DNS is up and running."
echo -e "\n####################\n"


if echo "${RAN_PW}" | grep -q 'y'; then
  echo -e "${ORANGE}ATTENTION${BLANK}:\nPlease don't forget to set a secure password for your pihole dashboard.\nRun 'docker exec pihole pihole -a -p <NEW PASSWORD>' to change it.\n"
fi