# [DoTH-DNS](https://github.com/Cielquan/DoTH-DNS)

[![License: MIT](https://img.shields.io/github/license/Cielquan/DoTH-DNS)](https://github.com/Cielquan/DoTH-DNS/blob/master/LICENSE.md)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/Cielquan/DoTH-DNS)](https://github.com/Cielquan/DoTH-DNS/releases/latest)

Utilizes the power of [pi-hole](https://pi-hole.net) and [unbound](https://www.nlnetlabs.nl/projects/unbound/about) 
to create a DNS server under your own authority but with the abillity to use DoH 
([DNS over HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS)) and DoT ([DNS over TLS](https://en.wikipedia.org/wiki/DNS_over_TLS)).


## Disclaimer
Use at own risk. This project is made for docker. I run it on my raspberry pi 3b+ with raspbian buster lite. 


## Description
This project's goal is setup a DNS server inside docker with the option to connect via DoH or DoT. 
Therefor pi-hole, unbound, traefik and a [DoH-server](https://github.com/m13253/dns-over-https) are utilized. 

You may ask 'Why use DoH or DoT for an local DNS server?'. Good question! I set this up because firefox needs you to use 
DoH if you want to use [ESNI](https://en.wikipedia.org/wiki/Server_Name_Indication). The DoT support was just some lines 
of code more so I did it also. 

The docker-compose file creates a bridge network and the following containers: 
`pi-hole/pi-hole`, `mvance/unbound`, `traefik`, `goofball222/dns-over-https`. 

Query forwarding: 
* Normal DNS query: port 53 -> pihole -> unbound 
* DoT query: port 853 -> traefik -> pihole -> unbound 
* DoH query: port 443 -> traefik -> DoH-server -> pihole -> unbound 
* pihole dashboard query: port 80/443 -> traefik -> pihole (HTTP is forwarded to HTTPS) 


## Instructions

### Prerequisites
Your machine needs to match the following conditions: 
* Have a static IP 
* Have `git`, `docker` and `docker-compose` installed 
* Have valid SSL certificate (`cert.crt`) and matching key (`key.key`) 
* Have a `dhparam.pem` file 

### Quick setup
Here I show my way of setting the server (RasPi) up via SSH. Your mileage may vary. 
Given paths are relative to this repositories root.

#### 1. Get this repo and make configs
First clone this repo to your local machine.

#### 2. Add custom files

##### 2.1. SSL certificate files
Copy your `cert.crt`, `key.key` and `dhparam.pem` files to 'certificates/'.

##### 2.2. .httpasswd file
To secure your traefik dashboard add a `.htpasswd` file to 'traefik-docker/shared/' containing a user-password-string following htpasswd standard. This is optional. 

#### 3. Send files to server
When your setup is done and you can send the files to your server. 

    $ scp -r ~/DoTH-DNS/ pi@192.168.0.1:~

Copies the repo from your home directory to the directory of the server. You need to alter the user, IP and paths to your parameters! 

#### 4. Run the `start_doth_dns.bash` script
Now cd into the repo on the server via SSH and start the `start_doth_dns.bash` script. Depending on the settings on your server you may need to start the script with `sudo` 
because for docker root privileges are needed. The script supports flags. Information regarding available flag you can find below.

    $ ./start_doth_dns.bash

#### 5. Secure your pihole dashboard
If you have not set the `WEBPASSWORD` environment variable on your server you should now set a secure password for your pihole dashboard or deactivate it.

    $ docker exec pihole -a -p <PASSWORD>

_The script also reminds you if a random password was generated from pihole._

#### 6. Use the new DNS server
Now you can setup your other devices to use the server.
You may also install your CA certificate on your other devices.


### Config flag notes
Here is an overview of the available flags for setup when calling the script. Run `-h` flag for help on commandline.

* `-f`): If set then old configuration settings saved in `.env` file will not be loaded and a new `root.hints` file will be downloaded.

* `-a`): Set Architecture of the processor ('arm' or 'x86') used by the server. Needed for determining the right docker images. If not set script will determine it. 

* `-c`): Set to force `goofball222/dns-over-https` docker image to be compiled. If not set then the `ARCHITECTURE` determines if the image will be compiled 
('arm' -> yes; 'x86' -> no). Will only be compiled if non existing.

* `-I`): Set the network interface used from the server. Needed for determining the right IP address. If not set script will determine it.

* `-i`): Set the IP address used by the server. If not set script will determine it with determined oder given (via `-I` flag) `INTERFACE`.

* `-n`): Set hostname of the host machine. If not set script will determine it.

* `-t`): Set timezone the server is in. Used for e.g. daily resets. Format is like 'Europe/London'. If not set script will determine it.

* `-d`): Set domain the server is reachable under. If not set created by script: '`HOST_NAME`.dns'.

* `-N`): Set to deactivate traefik dashboard authorization when `.htpasswd` file is given.


### Run flag notes
Here is an overview of the available flags for running when calling the script. Run `-h` flag for help on commandline. 

* `-R`): Set to recreate all containers. Containers will load new config files if given.

* `-U`): Set to recreate and update all containers.

* `-P`): Set to start without reverse proxy (`traefik`).

* `-D`): Set to shut DoTH-DNS down. It will remove all DoTH-DNS containers and networks.

### Reverse proxy
You have two options for the reverse proxy: `None` or `traefik`. 
If you want to use `None` you have to set the flag `-P` when running the script else `traefik` will be used.


## Get help
* Pi-hole [documentation](https://docs.pi-hole.net/)
* Pi-hole image [documentation](https://github.com/pi-hole/docker-pi-hole/blob/master/README.md)
* Unbound [documentation](https://www.nlnetlabs.nl/documentation/unbound/)
* Unbound image [documentation](https://github.com/MatthewVance/unbound-docker-rpi/blob/master/README.md)
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
Thanks to the creators of docker, pi-hole, unbound, traefik and 'dns-over-https' for their awesome software. Also thanks you 
to the maintainers of the images.

Thanks to the creator of this [docker-pihole-unbound](https://github.com/chriscrowe/docker-pihole-unbound) project which inspired me.


## Author
Christian Riedel


## Versioning
[SemVer](https://semver.org/) is used for versioning. For the versions available, see the [tags on this repository](https://github.com/Cielquan/DoTH-DNS/tags).