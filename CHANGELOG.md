# DoTH DNS Change Log

**Release 3.0.2** - 12.11.2019
- Fixed catchall rule for global HTTPS redirect ([commit](https://github.com/Cielquan/DoTH-DNS/commit/15cc7c9306e05c4361d8477272db0dc50af29d0c))

**Release 3.0.1** - 12.11.2019
- Changed urls in `run.sh` script output from IP address to 'pi.hole' ([commit](https://github.com/Cielquan/DoTH-DNS/commit/cca5f92366388119563c9a5bb33039c702205f6f)) ([commit](https://github.com/Cielquan/DoTH-DNS/commit/28b2536bd7d493a0d61c19b2c2bcdff51f1484d9))
- Fixed issue with `run.sh` script output while checking for pihole blocklist setup ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7498f82113ff8f613268ecbad5c1f0429eb8dfc8))
- Minor code clean up

**Release 3.0.0** - 11.11.2019
- Renamed project to `DoTH-DNS`
- Added `CHANGELOG.md` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/6e8dada6eaa2316508b4d95bc658cde900969d0b))
- Dropped TLSv1.2 in nginx stream config ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0ab8f5f83ac02a7ccc70df8d7b7e0508ba2cb008))
- Added global https redirect config ([commit](https://github.com/Cielquan/DoTH-DNS/commit/05a2cd61040724960348a3a5d879056f84734530))
- Deleted old configs from `cert.toml` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/84375bccb4141bbb80267582a3211e29ee155d52))
- Changed middleware für adding `/admin` for pihole urls ([commit](https://github.com/Cielquan/DoTH-DNS/commit/34f6dde5f46a8f4b6500dcd2f0ef7dd8ee95040b))
- Changed traefik custom name format to `xxx_XxxXxx` (3 letters of category, underscore, name in camelcase) ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f90d70f4941edcf2f4d34c2cc3f78508249ac17e))
- Updated traefik config for v2.0
- Updated DoH server config to version 2.2.1 ([commit](https://github.com/Cielquan/DoTH-DNS/commit/212c9e6f3a5688ba40a071b75fb7081a619a1c1c))
- Fixed error for `-p` flag in `run.sh` script ([commit](https://github.com/Cielquan/DoTH-DNS/commit/1eae3b5fb8658022153dc02743887994aa59b447))

**Release 2.6.1** - 25.08.2019
- Fixed `dnsmasq.conf` setup ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5e7f2b0526accb7f2e1faf892962b0a697906c38))

**Release 2.6.0** - 25.08.2019
- Split Docker-Compose file ([commit](https://github.com/Cielquan/DoTH-DNS/commit/ea00a3ebfc946ff858d84a02ae2d9678cb502b14))
- Fixed password message ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5f2f5f0b1d3217132172ea2946c108339f26b596))
- Added Traefik as new and default reverse proxy ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f7f680b1306b5fea358d5d78e90e3ec4111c6ae0))
- Added colors to script outputs ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f7f680b1306b5fea358d5d78e90e3ec4111c6ae0))
- Added `DOMAIN` env var ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7439e7b6e2a02b462b2f7a351c94616eaa8b711f))

**Release 2.5.0** - 07.08.2019
- Reduced amount of certificates to domain ([commit](https://github.com/Cielquan/DoTH-DNS/commit/031d52ddf0098bca91c62c904e44da414df20fa5))
- Fixed checks on nginx conf creations ([commit](https://github.com/Cielquan/DoTH-DNS/commit/cf832e506cd6bf2c5d955e49a37e963a7b5725bf))

**Release 2.4.0** - 07.08.2019
- Added flags to `run.sh` script ([commit](https://github.com/Cielquan/DoTH-DNS/commit/c4232efdb2cdae87a49ecb328e49eea7fd06287e))

**Release 2.3.0** - 06.08.2019
- Added flags to `setup.sh` script ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0c58e1ac135e17b1137ee3ee649a3c4a35dc6727))
- Fixed nginx conf file creation ([commit](https://github.com/Cielquan/DoTH-DNS/commit/636c0a4ea60df39dd03007133995abcfb5dd22fb))
- Fixed `roots.hint`downloader ([commit](https://github.com/Cielquan/DoTH-DNS/commit/535cc44eaad24c4143c3e7eb01836887d0676d3a))

**Release 2.2.0** - 06.08.2019
- `roots.hint` file will updated when older than 1h ([commit](https://github.com/Cielquan/DoTH-DNS/commit/55eb020d321f2c921a76238377710e71b113aaab))
- Added option for fresh setup ([commit](https://github.com/Cielquan/DoTH-DNS/commit/55eb020d321f2c921a76238377710e71b113aaab))
- Nginx conf file are no longer overwritten ([commit](https://github.com/Cielquan/DoTH-DNS/commit/23d62361fd91835265b69caff16a4b9c8203df3b))
- Moved *.template files to own directory ([commit](https://github.com/Cielquan/DoTH-DNS/commit/8ca4b4ef55a352d54f85e3823abc775fcd800d83))
- Added '.conf' to DoT conf and put upstream to own file ([commit](https://github.com/Cielquan/DoTH-DNS/commit/8ca4b4ef55a352d54f85e3823abc775fcd800d83))
- Fixed issue with warnings for stapling ([commit](https://github.com/Cielquan/DoTH-DNS/commit/8ca4b4ef55a352d54f85e3823abc775fcd800d83))
- The script now exits if docker-compose fails ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e6452effbe2d1a4e31faba9a2dfab816b4d26804))
- Fixed missing declaration of $HOST_IP ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e6452effbe2d1a4e31faba9a2dfab816b4d26804))
- Added 'change password' reminder ([commit](https://github.com/Cielquan/DoTH-DNS/commit/e6452effbe2d1a4e31faba9a2dfab816b4d26804))

**Release 2.1.0** - 05.08.2019
- Removed WEBPASSWORD functionality because it did not work like intended ([commit](https://github.com/Cielquan/DoTH-DNS/commit/c603ec96cc13dbab748c1a504f414e8afe2b9a36))

**Release 2.0.2** - 05.08.2019
- Fixed bash command in `README.md` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/ed86aaa2718ab33c885b27b3f153b6465cfcda79))

**Release 2.0.1** - 05.08.2019
- Minor improvements to `README.md` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/d254424dedd7053b2aece03939c78eb70970d376))

**Release 2.0.0** - 04.08.2019
- Changed Subnet ([commit](https://github.com/Cielquan/DoTH-DNS/commit/a5bb6e659ba528922d122e3d669d7459563b1e89))
- Moved certificates directory ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7866d6fd71c5ac6cf9f56666591016c190087ce8))
- Cut setup part from `start_script.sh` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/dcfdb203eb28787aaa81362eee7d2acef409d2bd))
- Reworked setup part in new `setup.sh` script for more automation ([commit](https://github.com/Cielquan/DoTH-DNS/commit/a58be8d660321be2d3a8e219ea632ab31ea2279f))
- Renamed `start_script.sh` to `run.sh` ([commit](https://github.com/Cielquan/DoTH-DNS/commit/f1d537651b147ab106b57d0c7e8a397a556dcb9a))
- Removed `sudo` from scripts ([commit](https://github.com/Cielquan/DoTH-DNS/commit/7e8ff35ac7e372e3941fab32b957074d522fa8a6))
- Renamed conf file for unbound ([commit](https://github.com/Cielquan/DoTH-DNS/commit/0c78b24dd82c1aae2709acd80c3a77396228ac5a))
- Changed some ENV Var stuff ([commit](https://github.com/Cielquan/DoTH-DNS/commit/93f1b97fc71de90f9da73a54aae54254e67acfb5))

**Release 1.1.0** - 03.08.2019
- Fixed problem with overwriting default upstream DNS server ([commit](https://github.com/Cielquan/DoTH-DNS/commit/5fccc19555f6a4fc353a707f780bd734985d8e82))
- Minor Improvements

**Release 1.0.0** - 03.08.2019
- Initial release
