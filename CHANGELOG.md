<!-- markdownlint-disable no-emphasis-as-heading -->

# DoTH-DNS Change Log

**NOTE:**
These changes are listed in decreasing version number order and not necessarily chronological.
Version numbers follow the [SemVer](https://semver.org/) principle.
See the [tags on this repository](https://github.com/Cielquan/DoTH-DNS/tags) for all available versions.

**NOTE:**
Not all commits are linked. Commits are only linked when they match the specific note.

## Release 8.0.0

_Released: 22.01.2023_

- Turn back to docker-compose setup without CLI app or scripts
- Merge docs into README

## Release 7.0.1

_Released: 16.02.2020_

- Added PyPI & TravisCI badges ([commit](https://github.com/Cielquan/DoTH-DNS/commit/1f927d8a211d05611302f3f40dc0b8a07b1e4ec9))

## Release 7.0.0

_Released: 16.02.2020_

This release is also published on PyPI.

- Added CLI written in python with click
- Revised container configs:

  - Custom start script for unbound adding additional config files (access protection and PTR
    entries) ([commit](https://github.com/Cielquan/DoTH-DNS/commit/d51b67c29cc4c6f916011f961603c0eaecb050ee))
  - Removed unused log file stuff from unbound ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e4f6795b0a037c47902ad432f0c15be87c196837))
  - Added s6 script to pihole to grab unbound's IP and write to config ([commit](https://github.com/Cielquan/DoTH-DNS/commit/d2d90c75f340241618a02847199f20f77fd55abe))
  - Improved s6 script for pihole adding host wildcard entry ([commit](https://github.com/Cielquan/DoTH-DNS/commit/d2d90c75f340241618a02847199f20f77fd55abe))
  - Activated logging for doh_server by default ([commit](https://github.com/Cielquan/DoTH-DNS/commit/ff21b0b233dc702ebe44454fd386dc3ba6c62ab7))

- Added Dockerfile for doh_server based on [goofball's Dockerfile](https://github.com/goofball222/dns-over-https/blob/master/stable/Dockerfile)
  ([commit](https://github.com/Cielquan/DoTH-DNS/commit/fd4edc168f1492fa86bc9a80a6c7cff98a450f92))
- Updated traefik to v2.1 (incl. config) ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5aaa77f66a7a4884c799bfcac3b68ffc936b6b33))
- Removed Bash scripts ([commit](https://github.com/Cielquan/DoTH-DNS/commit/abe398e29cc01e9d1794b1e13f17c68b34bcabeb))
- Removed docker-compose files ([commit](https://github.com/Cielquan/DoTH-DNS/commit/a53b556ba38174fd707cc5c13bff6175f1234b07))
- Updated documentation ([commit](https://github.com/Cielquan/DoTH-DNS/commit/43a47cdee23cadabd6fb26bba259bec97f8f9495))

## Release 6.0.3

_Released: 01.02.2020_

- Fixed LICENSE.rst to be detectable by Github again ([commit](https://github.com/Cielquan/DoTH-DNS/commit/6540fce766e705d59c9ad7487a988e5d4dabfed8))
- Updated Changelog reST syntax stuff ([commit](https://github.com/Cielquan/DoTH-DNS/commit/73a433093fc75e98e73c35744e66765d74fc09b2))
- Added basic Github Issue template ([commit](https://github.com/Cielquan/DoTH-DNS/commit/33604d61dc3443e17733c0466f9d1d4079d5cc16))

## Release 6.0.2

_Released: 01.02.2020_

- Changed LICENSE to rst because of parsing errors in docs ([commit](https://github.com/Cielquan/DoTH-DNS/commit/94ad3308c582a34d5b44be2aa42567c7ebe07b17))
- Updated README ([commit](https://github.com/Cielquan/DoTH-DNS/commit/2de12da82f3c30309bf7603059323a26461b184f))

## Release 6.0.1

_Released: 01.02.2020_

- Added missing release note for 6.0.0 ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f51ecb09929499d05853b695148aca18a18b4753))

## Release 6.0.0

_Released: 30.01.2020_

- Changed License from MIT to GPLv3 ([commit](https://github.com/Cielquan/DoTH-DNS/commit/3088cbac82cc3cf5e62479412199cb294509c0ea))

## Release 5.4.0

_Released: 25.01.2020_

- Added sphinx documentation ([commit](https://github.com/Cielquan/DoTH-DNS/commit/574469f04829b3565c413d6edb45d48df90643f4))
- Changed README, LICENSE, CHANGELOG from MD to reST ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5890a05586032c2a6074d032d35f49660d899ec6))
- Added .gitattributes ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0dd209fc9575f3ee8b373d5c6f237160e6058b81))
- Minor additions and fixes to documentation.

## Release 5.3.0

_Released: 11.12.2019_

- Reworked config gathering in script and added fallback mechanism ([commit](https://github.com/Cielquan/DoTH-DNS/commit/30a33776a36d2fc44465710c8335958248b1ad37))
- Added `-F` flag for fallback option ([commit](https://github.com/Cielquan/DoTH-DNS/commit/ef9677ef8d089ca5b5ad6e221b8601cc1c5e0c4d))
- Minor code improvements in script
- Updated README ([commit](https://github.com/Cielquan/DoTH-DNS/commit/359eed77a263d1d0efd82444f1d33aaaf5ad05cd))

## Release 5.2.1

_Released: 30.11.2019_

- Added missing hint for `whiptail` in README ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f389e3ab123a64066b67acaf2a33c6a80bf1c139))

## Release 5.2.0

_Released: 29.11.2019_

- Added very basic menu script based on `whiptail` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f2805004ca10a73f1dedef11023b1cdab371c3a5))
- Added support for setting config environment variables in shell context ([commit](https://github.com/Cielquan/DoTH-DNS/commit/8cff59eb92ef03a4874b51b0d6a70ff527e4767e))

## Release 5.1.0

_Released: 27.11.2019_

- Added shut down function to script (`-D` flag) ([commit](https://github.com/Cielquan/DoTH-DNS/commit/2d00c4c7c751f746cc577b869244a125a3153b8f))

## Release 5.0.2

_Released: 25.11.2019_

- Fixed update function to not pull `doh_server`'s image when architecture is `arm` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5969d1e394212c647fd2f43e42889485cc08d584))
- Made `.env` file import messages more clear ([commit](https://github.com/Cielquan/DoTH-DNS/commit/ae21fc2a2e1deef6d2c2408338285287005178c7))
- Fixed `.env` file import error when no file is there ([commit](https://github.com/Cielquan/DoTH-DNS/commit/6b84f3026679bc361c8c4f79e4ddd25b7877c9fe))

## Release 5.0.1

_Released: 25.11.2019_

- Added "fix-attrs" file for s6 overlay for `pihole` container to fix config file ownerships ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f4b302f57670a34331f547256a53abff3cbd1744))
- Added `ro` flag to `cert.crt`, `key.key` and `docker.sock` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/34d55434e821eddf8a202f2990906ed52cca617a))
- Added `TZ` EnvVar and `/etc/localtime` to all containers missing it ([commit](https://github.com/Cielquan/DoTH-DNS/commit/2629da5b0decfbcdb8e7c6bc6a2fae3d3c06609c))
- Minor fixes

## Release 5.0.0

_Released: 24.11.2019_

- Removed `nginx` support ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e63567409815e0c511353baee5593a9d888f4d43))
- Removed second docker network ([commit](https://github.com/Cielquan/DoTH-DNS/commit/4beb000a6d79e01eff459d09816aa3fc3ae2d60b))

## Release 4.0.0

_Released: 17.11.2019_

- Added detection for `.htpasswd` file and auto setting traefik dashboard authZ on or off & added
  `-N` flag to deactivate ([commit](https://github.com/Cielquan/DoTH-DNS/commit/51d24cef59aeb485e7b403fea9e996424d34bd9b))
- Moved dnsmasq's conf setup from script to container via script for s6 ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0971352710634728599221745460ed3260b2419e))
- Merged `setup.sh` and `run.sh` into new simplified `start_doth_dns.bash` script ([commit](https://github.com/Cielquan/DoTH-DNS/commit/1442597736ff25eeeafc587345d2500a824d7d6e))
- Restructured `certificates` directory ([commit](https://github.com/Cielquan/DoTH-DNS/commit/43991d4091c3df069d7e3ba16f8aed83b8537cae))
- Changed cert and key file from being dynamic to being static & renamed `cert.toml` to `tls.toml` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/32ae66d1b0290c04129e4c8f3a412c341bf4393d))
- Moved nginx conf setup from script into docker command ([commit](https://github.com/Cielquan/DoTH-DNS/commit/4848143d21287dda2605724b45d3c4b16cf0c3ae))
- Renamed some Env Vars in compose files to match script Vars & moved pihole Env Vars from conf
  files to compose ([commit](https://github.com/Cielquan/DoTH-DNS/commit/a54283a593ce9252f6756cec90a9fec67003e6fd))
- Made nginx HTTPS redirect a global static setting ([commit](https://github.com/Cielquan/DoTH-DNS/commit/b0ff0723df0cef27712d5e016621842bbea23599))
- Updated README ([commit](https://github.com/Cielquan/DoTH-DNS/commit/490a72a0dfd25ec88fe76535edf6ea7724fed556))
- Smaller code and file cleanups
- Smaller fixes

## Release 3.0.2

_Released: 12.11.2019_

- Fixed catchall rule for global HTTPS redirect ([commit](https://github.com/Cielquan/DoTH-DNS/commit/15cc7c9306e05c4361d8477272db0dc50af29d0c))

## Release 3.0.1

_Released: 12.11.2019_

- Changed urls in `run.sh` script output from IP address to 'pi.hole'
  ([commit](https://github.com/Cielquan/DoTH-DNS/commit/cca5f92366388119563c9a5bb33039c702205f6f))
  ([commit](https://github.com/Cielquan/DoTH-DNS/commit/28b2536bd7d493a0d61c19b2c2bcdff51f1484d9))
- Fixed issue with `run.sh` script output while checking for pihole blocklist setup ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7498f82113ff8f613268ecbad5c1f0429eb8dfc8))
- Minor code clean up

## Release 3.0.0

_Released: 11.11.2019_

- Renamed project to `DoTH-DNS`
- Added `CHANGELOG.md` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/6e8dada6eaa2316508b4d95bc658cde900969d0b))
- Dropped TLSv1.2 in nginx stream config ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0ab8f5f83ac02a7ccc70df8d7b7e0508ba2cb008))
- Added global https redirect config ([commit](https://github.com/Cielquan/DoTH-DNS/commit/05a2cd61040724960348a3a5d879056f84734530))
- Deleted old configs from `cert.toml` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/84375bccb4141bbb80267582a3211e29ee155d52))
- Changed middleware für adding `/admin` for pihole urls ([commit](https://github.com/Cielquan/DoTH-DNS/commit/34f6dde5f46a8f4b6500dcd2f0ef7dd8ee95040b))
- Changed traefik custom name format to `xxx_XxxXxx` (3 letters of category, underscore, name in
  camelcase) ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f90d70f4941edcf2f4d34c2cc3f78508249ac17e))
- Updated traefik config for v2.0
- Updated DoH server config to version 2.2.1 ([commit](https://github.com/Cielquan/DoTH-DNS/commit/212c9e6f3a5688ba40a071b75fb7081a619a1c1c))
- Fixed error for `-p` flag in `run.sh` script ([commit](https://github.com/Cielquan/DoTH-DNS/commit/1eae3b5fb8658022153dc02743887994aa59b447))

## Release 2.6.1

_Released: 25.08.2019_

- Fixed `dnsmasq.conf` setup ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5e7f2b0526accb7f2e1faf892962b0a697906c38))

## Release 2.6.0

_Released: 25.08.2019_

- Split Docker-Compose file ([commit](https://github.com/Cielquan/DoTH-DNS/commit/ea00a3ebfc946ff858d84a02ae2d9678cb502b14))
- Fixed password message ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5f2f5f0b1d3217132172ea2946c108339f26b596))
- Added Traefik as new and default reverse proxy ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f7f680b1306b5fea358d5d78e90e3ec4111c6ae0))
- Added colors to script outputs ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f7f680b1306b5fea358d5d78e90e3ec4111c6ae0))
- Added `DOMAIN` env var ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7439e7b6e2a02b462b2f7a351c94616eaa8b711f))

## Release 2.5.0

_Released: 07.08.2019_

- Reduced amount of certificates to domain ([commit](https://github.com/Cielquan/DoTH-DNS/commit/031d52ddf0098bca91c62c904e44da414df20fa5))
- Fixed checks on nginx conf creations ([commit](https://github.com/Cielquan/DoTH-DNS/commit/cf832e506cd6bf2c5d955e49a37e963a7b5725bf))

## Release 2.4.0

_Released: 07.08.2019_

- Added flags to `run.sh` script ([commit](https://github.com/Cielquan/DoTH-DNS/commit/c4232efdb2cdae87a49ecb328e49eea7fd06287e))

## Release 2.3.0

_Released: 06.08.2019_

- Added flags to `setup.sh` script ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0c58e1ac135e17b1137ee3ee649a3c4a35dc6727))
- Fixed nginx conf file creation ([commit](https://github.com/Cielquan/DoTH-DNS/commit/636c0a4ea60df39dd03007133995abcfb5dd22fb))
- Fixed `roots.hint` downloader ([commit](https://github.com/Cielquan/DoTH-DNS/commit/535cc44eaad24c4143c3e7eb01836887d0676d3a))

## Release 2.2.0

_Released: 06.08.2019_

- `roots.hint` file will updated when older than 1h ([commit](https://github.com/Cielquan/DoTH-DNS/commit/55eb020d321f2c921a76238377710e71b113aaab))
- Added option for fresh setup ([commit](https://github.com/Cielquan/DoTH-DNS/commit/55eb020d321f2c921a76238377710e71b113aaab))
- Nginx conf file are no longer overwritten ([commit](https://github.com/Cielquan/DoTH-DNS/commit/23d62361fd91835265b69caff16a4b9c8203df3b))
- Moved \*.template files to own directory ([commit](https://github.com/Cielquan/DoTH-DNS/commit/8ca4b4ef55a352d54f85e3823abc775fcd800d83))
- Added '.conf' to DoT conf and put upstream to own file ([commit](https://github.com/Cielquan/DoTH-DNS/commit/8ca4b4ef55a352d54f85e3823abc775fcd800d83))
- Fixed issue with warnings for stapling ([commit](https://github.com/Cielquan/DoTH-DNS/commit/8ca4b4ef55a352d54f85e3823abc775fcd800d83))
- The script now exits if docker-compose fails ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e6452effbe2d1a4e31faba9a2dfab816b4d26804))
- Fixed missing declaration of $HOST_IP ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e6452effbe2d1a4e31faba9a2dfab816b4d26804))
- Added 'change password' reminder ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e6452effbe2d1a4e31faba9a2dfab816b4d26804))

## Release 2.1.0

_Released: 05.08.2019_

- Removed WEBPASSWORD functionality because it did not work like intended ([commit](https://github.com/Cielquan/DoTH-DNS/commit/c603ec96cc13dbab748c1a504f414e8afe2b9a36))

## Release 2.0.2

_Released: 05.08.2019_

- Fixed bash command in `README.md` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/ed86aaa2718ab33c885b27b3f153b6465cfcda79))

## Release 2.0.1

_Released: 05.08.2019_

- Minor improvements to `README.md` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/d254424dedd7053b2aece03939c78eb70970d376))

## Release 2.0.0

_Released: 04.08.2019_

- Changed Subnet ([commit](https://github.com/Cielquan/DoTH-DNS/commit/a5bb6e659ba528922d122e3d669d7459563b1e89))
- Moved certificates directory ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7866d6fd71c5ac6cf9f56666591016c190087ce8))
- Cut setup part from `start_script.sh` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/dcfdb203eb28787aaa81362eee7d2acef409d2bd))
- Reworked setup part in new `setup.sh` script for more automation ([commit](https://github.com/Cielquan/DoTH-DNS/commit/a58be8d660321be2d3a8e219ea632ab31ea2279f))
- Renamed `start_script.sh` to `run.sh` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f1d537651b147ab106b57d0c7e8a397a556dcb9a))
- Removed `sudo` from scripts ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7e8ff35ac7e372e3941fab32b957074d522fa8a6))
- Renamed conf file for unbound ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0c78b24dd82c1aae2709acd80c3a77396228ac5a))
- Changed some ENV Var stuff ([commit](https://github.com/Cielquan/DoTH-DNS/commit/93f1b97fc71de90f9da73a54aae54254e67acfb5))

## Release 1.1.0

_Released: 03.08.2019_

- Fixed problem with overwriting default upstream DNS server ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5fccc19555f6a4fc353a707f780bd734985d8e82))
- Minor Improvements

## Release 1.0.0

_Released: 03.08.2019_

- Initial release
