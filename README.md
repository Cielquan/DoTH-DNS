# [DoTH-DNS](https://github.com/Cielquan/DoTH-DNS)

[![License: MIT](https://img.shields.io/github/license/Cielquan/DoTH-DNS)](https://github.com/Cielquan/DoTH-DNS/blob/master/LICENSE.md)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/Cielquan/DoTH-DNS)](https://github.com/Cielquan/DoTH-DNS/releases/latest)

Utilizes the power of [pi-hole](https://pi-hole.net) and [unbound](https://www.nlnetlabs.nl/projects/unbound/about) 
to create a DNS server under your own authority but with the abillity to use DoH 
([DNS over HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS)) and DoT ([DNS over TLS](https://en.wikipedia.org/wiki/DNS_over_TLS)).


## Disclaimer
Currently still work in progress. 
Use at own risk. This project is made for linux. I run it on my raspberry pi 3b+ with raspbian buster lite. 


## Description
This project's goal is setup a DNS server inside docker with the option to connect via DoH or DoT. 
Therefor pi-hole, unbound, traefik/nginx and a [DoH-server](https://github.com/m13253/dns-over-https) are utilized. 

You may ask 'Why use DoH or DoT for an local DNS server?'. Good question! I set this up because firefox needs you to use 
DoH if you want to use [ESNI](https://en.wikipedia.org/wiki/Server_Name_Indication). The DoT support was just some lines 
of code more so I did it also. 

The docker-compose file creates a bridge network and the following containers: 
`pi-hole/pi-hole`, `mvance:unbound`, `nginx`, `traefik`, `goofball222/dns-over-https`. 
When using traefik a second bridge network will be created.

Query forwarding: 
* Normal DNS query: port 53 -> pihole -> unbound 
* DoT query: port 853 -> nginx/traefik -> pihole -> unbound 
* DoH query: port 443 -> nginx/traefik -> DoH-server -> pihole -> unbound 
* pihole dashboard query: port 80/443 -> nginx/traefik -> pihole (HTTP is forwarded to HTTPS) 


## Instructions

### Prerequisites
Your machine needs to match the following conditions: 
* Have a static IP 
* Have `git`, `docker` and `docker-compose` installed 
* Have valid SSL certificate (`*.crt`) and matching key (`*.key`) 
* Have a `dhparam.pem` file 

### Setup
Here I show my way of setting the server (RasPi) up via SSH. Your mileage may vary. 
Given paths are relative to this repositories root. 

#### 1. Get this repo and make configs
Firstly clone this repo to your SSH machine 

##### 1.1 SSL certificate files
* copy your SSL `*.crt` file to 'certificates/certs/' 
* copy your SSL `*.key` file to 'certificates/private/' 
* copy your `dhparam.pem` file to 'certificates/' 

##### 1.2 pihole config files
You may also add the following files to 'pihole-docker/configs/pihole/': 
* `adlists.list` - list of all blocklists 
* `blacklist.txt` - blacklisted URLs except URLs from blocklists 
* `lan.list` - list of addresses for local network _(added by `setup.sh` script)_ 
* `whitelist.txt` - list of all whitelisted URLs 

##### 1.3 setup.conf file
You can add a 'setup.conf' file at '/' with the following parameters. Every variable not set in this file will be gathered 
from the system. See [Variable Notes](https://github.com/Cielquan/DoTH-DNS#variable-notes) below for more information. 
* `FRESH`
* `ARCHITECTURE` 
* `COMPILE` 
* `INTERFACE` 
* `HOST_IP` 
* `HOST_NAME` 
* `TIMEZONE` 
* `DOMAIN` 

##### 1.4 server.conf file
You can add a 'server.conf' file in 'pihole-docker/configs/' directory with parameters listed 
[here](https://github.com/pi-hole/docker-pi-hole#environment-variables). 
However this is not recommended because the `setup.sh` script will create it for you (rather set given variables in 'setup.conf'). 
`ServerIP` and `TZ` are mandatory. 
`DNS1` and `DNS2` are set in default.conf, but are overwritten by server.conf if set. 

##### 1.5 .env file
You can add a '.env' file to '/' with variables used by 'docker-compose.yaml' file (listed below) . 
However this is not recommended because the `setup.sh` script will create it for you (rather set given variables in 'setup.conf'). 
* `HOSTNAME` 
* `TZ` 

#### 2. Send files to server
Now your setup is done and you can move the files to your server. 

    $ scp -r ~/DoTH-DNS/ pi@192.168.0.1:~

Copies the repo from your home directory to the directory of the server. You need to alter the user, IP and paths to your parameters. 

#### 3. run the scripts
Now cd into the repo on the server via SSH and first start the setup script. You can also start the script without sudo, but for the compiling part (when compiling)  
root privileges are needed. The script supports flags see 
[Variable Notes](https://github.com/Cielquan/DoTH-DNS#variable-notes) below for more information.

    $ ./setup.sh

After the script finished successfully you can start the `run.sh` script to actually start the docker containers. 
You may need to start the script with sudo, because the docker daemon needs root privileges. The script supports flags run `$ ./run.sh -h` to see the help page.

    $ ./run.sh

Instead of the `run.sh` script you can also run `docker-compose up -d`. 
The script does the same, but it also outputs information about the status of the single containers till they are done booting and setting up.

#### 4. Secure your pihole dashboard
If you have not set the '`WEBPASSWORD` variable in `server.conf` file (not recommended) you should now set a secure password for your pihole dashboard or deactivate it.

    $ docker exec pihole -a -p

_The `run.sh` script also reminds you if a random password was generated from pihole._

#### 5. Use the new DNS server
Now you can setup your other devices to use the server.
You may also install your CA certificate on your other devices.

### Variable Notes
Here are some explanations for above mentioned variables. The variables can also be set as flags when calling `setup.sh`. 
Run `$ ./setup.sh -h` to see the help page. Flags overwrite variables from 'setup.conf'.

`FRESH` (flag: `-f`):
If set to 'y' then all configuration files are overwritten with new ones.

`ARCHITECTURE` (flag: `-a`):
If not set, gathered and printed by `setup.sh` script.
Architecture of the processor ('arm' or 'x86') used by the server.
Needed for determining the right docker images.

`COMPILE` (flag: `-c`):
Determines if the 'goofball222/dns-over-https' image will rather be compiled than downloaded. 
The image on docker hub is not compatible with ARM processors. 
Can be set to 'n' to completely disable the compile part or set to 'y' for always compiling the image.
If not set then the `ARCHITECTURE` determines if the image will be compiled ('arm' -> yes; 'x86' -> no).

`INTERFACE` (flag: `-I`):
If not set, gathered and printed by `setup.sh` script.
The network interface used for the server.

`HOST_IP` (flag: `-i`):
If not set, gathered and printed by `setup.sh` script.
IP used with the `INTERFACE`.

`HOST_NAME` (flag: `-n`):
If not set, gathered and printed by `setup.sh` script.
Name of the host machine `$ hostname`.

`TIMEZONE` (flag: `-t`):
If not set, gathered and printed by `setup.sh` script.
Timezone the server is in. Used for e.g. daily resets.
Format is like 'Europe/London'.

`DOMAIN` (flag: `-d`):
If not set created by `setup.sh` script: '`HOST_NAME`.dns'.

### Update
If you want to update container with a newer image run following commands on your server while inside the repository directory _(via SSH)_. 

_But be wary of the need to compile the `goofball222/dns-over-https` image yourself for 'ARM' processors!_

Single container:

    $ docker stop CONTAINER && docker rm CONTAINER
    $ docker-compose pull CONTAINER
    $ ./run.sh

All containers:
    
    $ docker-compose down
    $ docker-compose pull
    $ ./run.sh

### Reverse proxy
You have three options for the reverse proxy. None, the old one `ngnix` and the new one `traefik`. 
Traefik 2.0 is used which is currently in beta.
If you want to use none you have to set the flag `-P` when running the `run.sh` script. For setting `nginx` or `traefik`
you have to set the flag `-p` followed by `ngnix` or `traefik` (case insensitive). The latter is the default.

Currently traefik does not work solo. I am working on getting the DoT part to work. 
Till then DoT traffic is passed through by traefik to ngnix to handle.
When traefik works solo ngnix may be deprecated.


## Get help
* Pi-hole [documentation](https://docs.pi-hole.net/)
* Pi-hole image [documentation](https://github.com/pi-hole/docker-pi-hole/blob/master/README.md)
* Unbound [documentation](https://www.nlnetlabs.nl/documentation/unbound/)
* Unbound image [documentation](https://github.com/MatthewVance/unbound-docker-rpi/blob/master/README.md)
* nginx [documentation](https://nginx.org/en/docs/)
* nginx image [documentation](https://github.com/docker-library/docs/blob/master/nginx/README.md)
* traefik [documentation](https://docs.traefik.io/v2.0/)
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
This project is licensed under the MIT License - see [LICENSE](https://github.com/Cielquan/DoTH-DNS/blob/master/LICENSE)

The rights of the docker images and software lie by their creators.


## Acknowledgements
Thanks to the creators of docker, pi-hole, unbound, nginx, traefik and 'dns-over-https' for their awesome software. Also thanks you 
to the maintainers of the images.

Thanks to the creator of this [docker-pihole-unbound](https://github.com/chriscrowe/docker-pihole-unbound) project which inspired me.


## Author
Christian Riedel


## Versioning
[SemVer](http://semver.org/) is used for versioning. For the versions available, see the [tags on this repository](https://github.com/Cielquan/DoTH-DNS/tags).