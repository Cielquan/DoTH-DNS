# DoTH-DNS

**Your server _doth_ DNS the safe way if you use DoTH-DNS.**

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/Cielquan/DoTH-DNS/main.svg)](https://results.pre-commit.ci/latest/github/Cielquan/DoTH-DNS/main)
![GitHub License](https://img.shields.io/github/license/Cielquan/DoTH-DNS?style=flat-square)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/Cielquan/DoTH-DNS?logo=github&style=flat-square)
![GitHub commits since latest release (by SemVer)](https://img.shields.io/github/commits-since/Cielquan/DoTH-DNS/latest?logo=github&style=flat-square)
![GitHub last commit](https://img.shields.io/github/last-commit/Cielquan/DoTH-DNS?logo=github&style=flat-square)
![GitHub Repo stars](https://img.shields.io/github/stars/Cielquan/DoTH-DNS?logo=github&style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/Cielquan/DoTH-DNS?logo=github&style=flat-square)
![GitHub contributors](https://img.shields.io/github/contributors/Cielquan/DoTH-DNS?logo=github&style=flat-square)

Utilizes the power of the DNS sinkhole [pi-hole][main-pihole] and the recursive DNS resolver
[unbound][main-unbound] to create a DNS server under your own authority with the added benefit
to be able to also use encrypted Transport Protocols.

By default DNS traffic is send unencrypted to port 53 also called Do53 (DNS over port 53).
DNS over HTTPS ([DoH][main-doh]) and DNS over TLS ([DoT][main-dot]) are both **encrypted**
alternative Transport Protocols which are both supported by the DoTH-DNS stack, hence the name.

[main-pihole]: https://pi-hole.net
[main-unbound]: https://www.nlnetlabs.nl/projects/unbound/about
[main-doh]: https://en.wikipedia.org/wiki/DNS_over_HTTPS
[main-dot]: https://en.wikipedia.org/wiki/DNS_over_TLS

## Disclaimer

This project is **not** actively maintained. Nonthenless are issues or PRs welcome.

The versioning and development of this project is rather wild. In its core it was always the same:
bringing docker containers up to run the DoTH-DNS stack, but the way this is achieved changes over
the course of different versions. You may see the [Changelog](Changelog.rst) for more information.
This means also that the handling of the stack may change in future versions.

Use at own risk see the License file for more details.

**WARNING:**
This project was created for use in a local network. If you want to use it on a VPS or in an
cloud environment be sure to properly secure your environment and know what you do.

## Usage

### Prerequisites and what to know before starting

#### Operating system

In the following section I explain how to run the stack on ubuntu. If you use another linux distro
the commands shown may differ.

I don't own a Mac and don't use Windows for such things, so I can not help you there. You will have
to modify this guide to fit your system yourself. Sorry.

#### Processor architecture

I run this stack on a _x86_ maschine. If you want to run this on an _ARM_ maschine, e.g.
RaspberryPi you need to make some adjustments.

**WARNING:**
I did not test these changes in practice.

1. _pihole_ and _traefik_ should work fine as is.
1. The _doh_server_ image needs to be build on the host anyways.
1. The _unbound_ image needs to change to the `mvance/unbound-rpi` image by changing it in the
   [docker-compose.yaml](docker-compose.yaml) file.

#### SSL Certificates

Because of the TLS encryption we need certificates accordingly.

traefik proxy supports different setups for certificates:

1. By default traefik creates a self signed wildcard certificate.

   This is ok for testing and works
   in the sense that a TLS secured connection can be established, but your browser will complain
   that the connection is not secure. I am not sure but this will most certainly block when
   trying to establish a DoH or DoT connection.

1. Self configured certificates - self-signed and/or official ones.

   Here you need to pass the certificate files into the docker
   container yourself and also configure a certificate store for traefik by updating the
   [docker-compose.yaml](docker-compose.yaml) file.

   See traefik's documention for more information (link in the [resources section](#resources--help)).

1. Automatic generation of certificates with [letsencrypt][letsencrypt] and the ACME protocol.

   letsencrypt is a nonprofit Certificate Authority (CA) and provides free and automated
   certificates. Only caveat is that you need a _real_ domain and a domain registrar that is
   supported by the lego library which traefik uses, but there are a lot of supported ones.

   See traefik's documention for more information (link in the [resources section](#resources--help)).

   Because the certification process is easily automated I use this approach with my domain from
   [name.com][namecom].
   This approach also works when the stack, like mine, only runs in your LAN and is not visible to
   the internet, thanks to the _DNS-01 challenge_.

[letsencrypt]: https://letsencrypt.org
[namecom]: https://name.com

#### Additional Software

1. To get the source we use _git_. Alternatively you could download the zip archive and extract it.
1. To run the stack we need _docker_ and _docker-compose_.
1. To create a user/password combo for the [`.htpasswd`][htpasswd] file for password protection
   of the traefik dashboard we need the _htpasswd_ utility from the _apache2-utils_ package.
   Alternatively you can use e.g. this [online tool][htpasswd-gen].
1. To edit files I use the _nano_ text editor.

To install all run this:

```console
sudo apt install git docker.io docker-compose apache2-utils nano
```

[htpasswd]: https://en.wikipedia.org/wiki/.htpasswd
[htpasswd-gen]: https://wtools.io/generate-htpasswd-online

### Configuration

#### `.env` file

The run configuration is done inside the `.env` file in the root directory of this repository.

- HOST_IP - (**Mandatory**)

  This is the IPv4 address of the docker host system and is needed for pihole.

- DOMAIN - (**Mandatory**)

  This is the domain you want to use for your DNS server.

- HOSTNAME - (Optional; defaults to `dns_server`)

  This sets the hostname of the containers.

- PIHOLE_WEBPASSWORD - (Optional; unset by default -> no password)

  The password you want to use for the pihole dashboard. Can be changed again later.

- TIMEZONE - (Optional; defaults to Europe/Berlin)

  TZ database name of your timezone which gets uses for timestamps etc.

  You can see a list of thouse names at
  [link](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

- ACME_EMAIL - (**Mandatory**)

  Email address used for registration at letsencrypt (no account needed).

- ACME_CASERVER - (Optional; defaults to <https://acme-v02.api.letsencrypt.org/directory>)

  This is the server to get the certificates from. By default the _production_ server is used.
  When you test things you should set the _staging_ server to avoid the weekly rate limiting.

  Staging server: <https://acme-staging-v02.api.letsencrypt.org/directory>

- ACME_DNSCHALLENGE_PROVIDER - (Optional; defaults to namedotcom)

  The domain registrar or the DNS provider for your domain, if they are not the same.

- NAMECOM_USERNAME - (Optional; unset by default)

  This is you name.com username.

- NAMECOM_API_TOKEN - (Optional; unset by default)

  This is your name.com API Token, which you can create at
  [link](https://www.name.com/account/settings/api).

#### DoH Server

If you need to modify the DoH server config, what you most certainly not, you can find the config
file here: `doh-docker/data/doh-server.conf`.

#### pihole

The pihole configuration files and directory you can find here: `pihole-docker/data`.

#### traefik

If you need to create a traefik config file put it here: `traefik-docker/data`.

#### unbound

If you need to modify the unbound boot script, what you most certainly not, you can find it here:
`unbound-docker/scripts/unbound.sh`.

unbound's config files can be found here: `unbound-docker/data/unbound.conf.d`. Here you most
certainly only want to change things in the `default.conf` file or add another custom file.

### Logs

In `unbound-docker/data/var/log` you can find unbounds log file, which will be recreated each boot.

All other container do not log to a file but stdout/stderr. You can see them by running

```console
docker-compose logs CONTAINERNAME
```

### Step by Step

All following steps are run from the command line:

1. Git clone this repository via

   - SSH:

     ```console
     git clone git@github.com:Cielquan/DoTH-DNS
     ```

   - or HTTPS:

     ```console
     git clone https://github.com/Cielquan/DoTH-DNS
     ```

1. Open the directory:

   ```console
   cd DoTH-DNS
   ```

1. Build the `doh_server` docker image:

   ```console
   docker build --tag cielquan/doh_server:latest doh-docker
   ```

1. Create `.htpasswd` file for password protection of the traefik dashboard

   - via the `htpasswd` utility:

     ```console
     htpasswd -c traefik-docker/data/.htpasswd USERNAME
     ```

   - or when you created the user/password combi online, create the file and copy it there:

   ```console
   nano traefik-docker/data/.htpasswd
   ```

   - If you do not want or need password protection you need to remove `TraefikAuth` from the
     `traefik.http.routers.Traefik.middlewares` label for the traefik container in the
     [docker-compose.yaml](docker-compose.yaml) file.

1. Create a `.env` file and edit it with your configuration
   (see [configuration section](#configuration)):

   ```console
   nano .env
   ```

1. Start all containers:

   ```console
   docker-compose up -d
   ```

### How to use the DNS server stack

#### Do53

To normally use your new DNS server simply provide your set `HOST_IP` as your DNS server e.g. in
your DHCP server.

#### DoH

To use DoH you need to set `https://doh.DOMAIN/dns-query` URL in the corresponding DoH settings
of your used software.

#### DoT

To use DoT you either need to set `https://dot.DOMAIN` URL or `HOST_IP` with port 853 in the DoT
settings of your used software.

#### pihole

At the URL `https://pihole.DOMAIN` you can find the pihole dashboard where you can set your
blocklists, etc.

#### traefik

At the URL `https://traefik.DOMAIN` you can find the traefik dashboard which has only informational
use.

### Updates

When there are new version of one or more of the used containers simply replace the container.
Because the configuration of all containers is mapped to directories and files outside, they are preserved.

1. Stop the container

   ```console
   docker-compose stop CONTAINERNAME
   ```

1. Remove the container

   ```console
   docker-compose rm CONTAINERNAME
   ```

1. Pull the new image

   ```console
   docker-compose pull CONTAINERNAME
   ```

1. Start the container

   ```console
   docker-compose up -d CONTAINERNAME
   ```

## Resources / Help

Here are some external links for further information that may help if you have issues.<br>
If the documention does not help, open an issue and I will try to help.

- Pi-hole documentation
  [link](https://docs.pi-hole.net)
- Pi-hole docker image repository
  [link](https://github.com/pi-hole/docker-pi-hole)
- Unbound documentation
  [link](https://www.nlnetlabs.nl/documentation/unbound)
- Unbound docker image for x86 (normal pc)
  [link](https://github.com/MatthewVance/unbound-docker)
- Unbound docker image for ARM (RaspberryPi)
  [link](https://github.com/MatthewVance/unbound-docker-rpi)
- traefik proxy documentation
  [link](https://docs.traefik.io/)
- traefik proxy letsencrypt documentation
  [link](https://doc.traefik.io/traefik/https/acme/)
- dns-over-https repository
  [link](https://github.com/m13253/dns-over-https)
- dns-over-https docker image repository
  [link](https://github.com/goofball222/dns-over-https)
- Docker documentation
  [link](https://docs.docker.com)
- Similar project without DoH and DoT
  [link](https://github.com/chriscrowe/docker-pihole-unbound)
- Pi-hole blog post about slow loading sides and blocking QUIC protocol
  [link](https://pi-hole.net/2018/02/02/why-some-pages-load-slow-when-using-pi-hole-and-how-to-fix-it)
- Pi-hole guide about pi-hole + unbound
  [link](https://docs.pi-hole.net/guides/unbound)
- Two Blog post realizing a similar construct
  [link 1](https://www.aaflalo.me/2018/10/tutorial-setup-dns-over-https-server)
  [link 2](https://www.bentasker.co.uk/documentation/linux/407-building-and-running-your-own-dns-over-https-server)

## FAQ

### Where does the name come from

Firstly the name `DoTH-DNS` is a word construct resulting from the ability to
use `DoT` and `DoH` for `DNS` queries.

Secondly `doth` is an _[archaic word for third person singular present tense of do][doth-source]_,
which matches the name perfectly well, because it `does DNS` (see slogan at top).

[doth-source]: https://www.lexico.com/definition/doth

### Where is the python CLI app?

The python CLI app from v7 lifes on the [`python-cli-pihole4` branch][faq-py-cli-branch] and is
also still available from PyPI.

Because as of now I find the CLI app solution over-engineered so I switched back to a simpler
docker-compose setup.

**WARNING:**
The app was build for pihole v4 which is outdated and I am unsure if it works with
pihole v5. Also traefik proxy will release its next major version soon,
which is incompatible with the config used in the app.

[faq-py-cli-branch]: https://github.com/Cielquan/DoTH-DNS/tree/python-cli-pihole4

## Known issues

- There is an issue with `alpine linux 1.13` which breaks the build of the `doh_server`
  container on presumably ARM hardware (e.g. RaspberryPi).<br>
  See [issue #8](https://github.com/Cielquan/DoTH-DNS/issues/8).

## Acknowledgements

Thanks to the creators, maintainers and developers of the software and linked resources used in
this project.

Special thanks to:

- the [dns-over-https][ack-doh] project and its [docker version][ack-doh-docker] as a base for my
  Dockerfile.
- the [docker-pihole-unbound][ack-dpu-proj] project for the inspiration.
- this [blog post][ack-blog-1] and this [blog post][ack-blog-2] for being the first foundation of
  this project.

[ack-doh]: https://github.com/m13253/dns-over-https
[ack-doh-docker]: https://github.com/goofball222/dns-over-https
[ack-dpu-proj]: https://github.com/chriscrowe/docker-pihole-unbound
[ack-blog-1]: https://www.aaflalo.me/2018/10/tutorial-setup-dns-over-https-server
[ack-blog-2]: https://www.bentasker.co.uk/documentation/linux/407-building-and-running-your-own-dns-over-https-server
