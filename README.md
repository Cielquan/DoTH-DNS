# [docker-pihole-unbound-encrypted](https://github.com/Cielquan/docker-pihole-unbound-encrypted)

Utilizes the power of [pi-hole](https://pi-hole.net) and [unbound](https://www.nlnetlabs.nl/projects/unbound/about) 
to create a DNS server under your own authority but with the abillity to use DoH 
([DNS over HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS)) and DoT ([DNS over TLS](https://en.wikipedia.org/wiki/DNS_over_TLS)).

## Disclaimer
Currently still work in progress.
Use at own risk. This project is made for linux. I run it on my raspberry pi 3b+ with raspbian buster lite.

## Description
This project's goal is setup a DNS server inside docker with the option to connect via DoH or DoT.
Therefor pi-hole, unbound, nginx and a [DoH-server](https://github.com/m13253/dns-over-https) are utilized.

You may ask 'Why use DoH or DoT for an local DNS server?'. Good question! I set this up because firefox needs you to use 
DoH if you want to use [ESNI](https://en.wikipedia.org/wiki/Server_Name_Indication). The DoT support was just some lines 
of code more so I did it also.

The docker-compose file sets up a bridge network and the following images: 
`pi-hole/pi-hole`, `mvance:unbound`, `nginx`, `goofball222/dns-over-https`.

Query forwarding:
* Normal DNS query: port 53 -> pihole -> unbound
* DoT query: port 853 -> nginx -> pihole -> unbound
* DoH query: port 443 -> nginx -> DoH-server -> pihole -> unbound
* pihole dashboard query: port 80/443 -> nginx -> pihole (HTTP is forwarded to HTTPS)


## Instructions

### Prerequisites
Your maschine needs to match the following conditions:
* Have a static IP
* Have docker and docker-compose installed
* Have valid SSL certificates (`*.crt`) and matching keys (`*.key`). 

### Setup
Here I show my way of setting the server (RasPi) up via SSH. Variation of the process is totally viable and up to you.

#### 1. Get this repo and make configs
Firstly clone this repo to your SSH machine

##### 1.1 SSL certificate files
* copy your SSL `*.crt` files to 'nginx-docker/certificates/certs/'
* copy your SSL `*.key` files to 'nginx-docker/certificates/private/'
* copy your `dhparam.pem` file to 'nginx-docker/configs/'

##### 1.2 pihole config files
You may also add the following files to 'pihole-docker/configs/pihole/':
* `adlists.list` - list of all blocklists
* `blacklist.txt` - blacklisted URLs except URLs from blocklists
* `lan.list` - list of addresses for local network 
* `whitelist.txt` - list of all whitelisted URLs

##### 1.3 custom.env file
You can add a 'custom.env' file in 'pihole-docker' directory with parameters listed [here](https://github.com/pi-hole/docker-pi-hole#environment-variables). 
However this is not recommended because the script will create it for you. `ServerIP` and `TZ` are required.

##### 1.4 start_script.conf file
You can add a 'start_script.conf' file at the repo's root with following parameters. The file can be used to auto fill the prompts. 
See Variable Notes below.
* `ARCHITECTURE`
* `COMPILE`
* `INTERFACE`
* `TIMEZONE`
* `PIHOLE_WEBPASSWORD`

#### 2 Send files to server
Now your setup is done and you can move the files to your server.

    $ scp -r ~/docker-pihole-unbound-encrypted/ pi@192.168.0.1:~

Copies the repo from your home directory to the directory of the server. You need to alter the user, IP and paths to your parameters.

#### 3 run the script
Now cd into the repo on the server via SSH and start the script

    $ ./start_script.sh

The script may prompt you for some data, depending of the additional configuration you did before. The script outputs information at runtime.

You can also give the architecture variable to the script:

    $ ./start_script.sh x86

#### 4 use the new DNS server
Now you can setup your other devices to use the server.

### Variable Notes
Here are some explanations for above mentioned variables.
`ARCHITECTURE`:
- architecture of the processor used by the server
- can be 'arm', 'x86' or empty
- defaults to 'arm'
- can be given as argument to script at call, which overwrites conf file entry

`COMPILE`:
- if the DoH-server image should be compiled (forces new compile every run)
- can be 'y' for yes
- for 'arm' architecture the script will automatically compile the image if none is locally found, 
because the image on docker hub is not arm compatible

`INTERFACE`:
- network interface to use
- defaults to 'eth0'

`TIMEZONE`:
- timezone the server stands in
- format is like 'Europe/London'
- if not set in either `custom.env` or `start_script.conf` script will prompt you
- if a `custom.env` file exists the entry in `start_script.conf` will be omitted

`PIHOLE_WEBPASSWORD`:
- password for the web dashboard of pihole
- can be empty for no password
- if not set in either `custom.env` or `start_script.conf` script will prompt you
- if a `custom.env` file exists the entry in `start_script.conf` will be omitted


### Update
If you want to update a container with a newer image run following commands on your Pi in the directory with the scripts 
_(via SSH)_:

    sudo docker stop CONTAINER && sudo rm CONTAINER && sudo docker rmi CONTAINER
    ./start_container.sh

The script will then pull the newest image or compile it (DoH-server image).

## Get help
* Pi-hole [documentation](https://docs.pi-hole.net/)
* Pi-hole image [documentation](https://github.com/pi-hole/docker-pi-hole/blob/master/README.md)
* Unbound [documentation](https://www.nlnetlabs.nl/documentation/unbound/)
* Unbound image [documentation](https://github.com/MatthewVance/unbound-docker-rpi/blob/master/README.md)
* nginx [documentation](https://nginx.org/en/docs/)
* nginx image [documentation](https://github.com/docker-library/docs/blob/master/nginx/README.md)
* dns-over-https [documentation](https://github.com/m13253/dns-over-https/blob/master/Readme.md)
* dns-over-https image [documentation](https://github.com/goofball222/dns-over-https/blob/master/README.md)
* Docker [documentation](https://docs.docker.com/)
* Docker-compose [documentation](https://docs.docker.com/compose/)
* Similar project - [link](https://github.com/chriscrowe/docker-pihole-unbound)
* Pi-hole blog post about slow loading sides and blocking QUIC protocol - 
[link](https://pi-hole.net/2018/02/02/why-some-pages-load-slow-when-using-pi-hole-and-how-to-fix-it/)
* Pi-hole guide about pi-hole+unbound - 
[link](https://docs.pi-hole.net/guides/unbound/)

## Rights
This project is licensed under the MIT License - see [LICENSE](https://github.com/Cielquan/docker-pihole-unbound-encrypted/blob/master/LICENSE)

The rights of the docker images and software lie by their creators.

## Acknowledgements
Thanks to the creators of docker, pi-hole, unbound, nginx and 'dns-over-https' for their awesome software. Also thanks you 
to the maintainers of the images.

## Author
Christian Riedel

## Version and State
Version: 1.1.0

State: 03.08.2019

## WIP
* Scripts are subject to change.
* Encrypt outgoing traffic is planned.
