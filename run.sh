#!/bin/bash


# Func for showing usage string
usage_string() {
  echo -e "Usage: $0 [-R] [-U] [-h]" 1>&2;
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
while getopts ":RUh" flag; do
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


# docker-compose commands
if echo "${UPDATE_ALL}" | grep -q 'y'; then
  echo ""
  docker-compose down || exit_dc_err
  docker-compose pull || exit_dc_err
  docker-compose up -d --force-recreate || exit_dc_err
elif echo "${RECREATE_ALL}" | grep -q 'y'; then
  echo ""
  docker-compose down || exit_dc_err
  docker-compose up -d --force-recreate || exit_dc_err
else
  echo ""
  docker-compose up -d --quiet-pull || exit_dc_err
fi


echo -e "\n####################\n"
echo -e "INFO! Starting docker-pihole-unbound-encrypted.\n"


# Testing unbound-docker
# Check if container started and works; timeout after 1 min
printf 'INFO! Starting up unbound container '
for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Health.Status}}" unbound)" == "healthy" ]; then
        printf ' OK'
        break
    else
        sleep 3
        printf '.'
    fi

    if [ "$i" -eq 20 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for unbound to start, check your container logs for more info (\`docker logs unbound\`)"
        printf "INFO! Container health status of 'unbound': " && docker inspect -f {{.State.Health.Status}} unbound
        exit_err
    fi
done;
printf "\nINFO! Container health status of 'unbound': " && docker inspect -f {{.State.Health.Status}} unbound

# Test DNSSEC - The first command should give a status report of SERVFAIL and no IP address. The second should give NOERROR plus an IP address.
TEST=$(docker exec unbound drill sigfail.verteiltesysteme.net @127.0.0.1 -p 53)
if [ "$(echo "$TEST" | sed '/SERVER:/d' | grep -cE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')" = 0 ] && [ "$(echo "$TEST" | grep -c 'rcode: SERVFAIL')" = 1 ]
then
    TEST=$(docker exec unbound drill sigok.verteiltesysteme.net @127.0.0.1 -p 53)
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
    if [ "$(docker inspect -f "{{.State.Health.Status}}" pihole)" == "healthy" ]; then
        printf ' OK'
        HOST_IP=$(grep 'ServerIP' pihole-docker/configs/server.conf | sed 's/ServerIP=//')
        if [ "$(docker logs pihole 2> /dev/null | grep -c 'password:')" -gt 0 ]; then
            echo -e "\nINFO! $(docker logs pihole 2> /dev/null | grep 'password:') for your pi-hole: https://${HOST_IP}/admin/"
            RAN_PW='y'
        else
            echo -e "\nINFO! Set given WEBPASSWORD for your pi-hole: https://${HOST_IP}/admin/"
            RAN_PW='n'
        fi
        break
    else
        sleep 3
        printf '.'
    fi

    if [ "$i" -eq 20 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for Pi-hole to start, check your container logs for more info (\`docker logs pihole\`)"
        printf "INFO! Container health status of 'pihole': " && docker inspect -f {{.State.Health.Status}} pihole
        exit_err
    fi
done;
printf "INFO! Container health status of 'pihole': " && docker inspect -f {{.State.Health.Status}} pihole

# Check if blocklist setup is finished and when then restore custom conf; timeout after 10 min
printf 'INFO! Waiting for blocklist setup to finish '
for i in $(seq 1 60); do
    if [ "$(docker logs pihole | grep -c "\[services.d\] done.")" -gt 0 ]; then
        printf ' OK'
        echo -e "\n INFO! Blocklists setup finished"
        break
    else
        sleep 10
        printf '.'
    fi

    if [ "$i" -eq 60 ]; then
        printf ' FAILED'
        echo -e "\nERROR! Timed out waiting for blocklists to set up, check your container logs for more info (\`docker logs pihole\`)"
        exit_err
    fi
done;


# Testing doh_server-docker
# Check if container started and is running; timeout after 1 min
printf '\nINFO! Starting up doh_server container '
for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
        if [ "$(docker inspect -f "{{.State.Status}}" doh_server)" == "running" ]; then
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
        printf "INFO! Container health status of 'doh_server': " && docker inspect -f {{.State.Status}} doh_server
        exit_err
    fi
done;
printf "\nINFO! Container health status of 'doh_server': " && docker inspect -f {{.State.Status}} doh_server


# Testing nginx-docker
# Check if container started and is running; timeout after 1 min
printf '\nINFO! Starting up nginx container '
for i in $(seq 1 20); do
    if [ "$(docker inspect -f "{{.State.Status}}" nginx)" == "running" ]; then
        sleep 5
        if [ "$(docker inspect -f "{{.State.Status}}" nginx)" == "running" ]; then
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
        printf "INFO! Container health status of 'nginx': " && docker inspect -f {{.State.Status}} nginx
        exit_err
    fi
done;
printf "\nINFO! Container health status of 'nginx': " && docker inspect -f {{.State.Status}} nginx


echo -e "\nSUCCESS! docker-pihole-unbound-encrypted is up and running."
echo -e "\n####################"

if echo ${RAN_PW} | grep -q 'y'; then
  echo -e "\nPlease don't forget to set a secure password for your pihole dashboard.\nRun 'sudo docker exec pihole pihole -a -p' to change it."
fi