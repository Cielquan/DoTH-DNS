#!/bin/bash


# Start docker container
echo ""
docker-compose up -d


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
        exit 1
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
        if [ "$(docker logs pihole 2> /dev/null | grep -c 'password:')" -gt 0 ]; then
            echo -e "\nINFO! $(docker logs pihole 2> /dev/null | grep 'password:') for your pi-hole: https://${HOST_IP}/admin/"
        else
            echo -e "\nINFO! Set given WEBPASSWORD for your pi-hole: https://${HOST_IP}/admin/"
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
        exit 1
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
        exit 1
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
        exit 1
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
        exit 1
    fi
done;
printf "\nINFO! Container health status of 'nginx': " && docker inspect -f {{.State.Status}} nginx


echo -e "\nSUCCESS! docker-pihole-unbound-encrypted is up and running."
echo -e "\n####################"
