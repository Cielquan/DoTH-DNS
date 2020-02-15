# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'container_configs.py' created 2020-02-07
# is part of the project/program 'DoTH-DNS'.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Github: https://github.com/Cielquan/
# ======================================================================================
"""
    container_configs
    ~~~~~~~~~~~~~~~~~

    Configuration file for dothdns container.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
#: pylint: disable=R0903,W0212
import sys

from pathlib import Path
from typing import Dict, List, Optional, Union


#: Load environment variables from `.env` file
EVARS = {}
try:
    with open(Path(Path(__file__).parent, ".env")) as file:
        for line in file:
            line = line.strip()
            if "=" not in line or line.startswith("#"):
                continue
            key, val = line.split("=", 1)
            key = key.strip().upper()
            val = val.strip()
            EVARS[key] = val
except FileNotFoundError:
    sys.exit("'.env' missing in ~/DoTH-DNS. Aborting ... ")


USER_CONFIG_DIR = Path(Path.home(), "DoTH-DNS")


class NetworkConfig:
    """Config for the internal network"""

    #: Network config
    name = "doth_dns_network"
    driver = "bridge"
    options = {"encrypted": "true"}
    attachable = False


class ContainerBaseConfig:
    """Basic config for all container"""

    detach = True
    restart_policy = {"Name": "always"}
    environment = {"TZ": f"{EVARS.get('TZ', 'Europe/London')}"}
    labels = {
        "traefik.enable": "true",
        "traefik.docker.network": ""
        f"{EVARS.get('TRAEFIK_NETWORK', NetworkConfig.name)}",
    }
    volumes = {"/etc/localtime": {"bind": "/etc/localtime", "mode": "ro"}}
    _domain = EVARS.get("DOMAIN", EVARS.get("HOST_NAME", "doth") + ".dns")
    network = NetworkConfig.name


class DohServerConfig(ContainerBaseConfig):
    """Config for doh_server container"""

    name = "doh_server"  #: DO NOT CHANGE
    image = "cielquan/doh_server:latest"
    ports: Dict[str, Union[str, List[Optional[str]]]] = {"8053": []}
    volumes = {
        **ContainerBaseConfig.volumes,
        f"{USER_CONFIG_DIR.joinpath('doh-docker/configs/doh-server.conf')}": {
            "bind": "/opt/dns-over-https/conf/doh-server.conf",
            "mode": "rw",
        },
    }
    _http_rou_opt = "traefik.http.routers.rou_DohServer"
    labels = {
        **ContainerBaseConfig.labels,
        #: DoH server http interface for traefik
        "traefik.http.services.svc_DohServer.loadbalancer.server.port": "8053",
        f"{_http_rou_opt}.entrypoints": "https",
        f"{_http_rou_opt}.rule": f"Host(`doh.{ContainerBaseConfig._domain}`) "
        f"&& Path(`/dns-query`)",
        f"{_http_rou_opt}.tls": "true",
        f"{_http_rou_opt}.tls.options": "default",
        f"{_http_rou_opt}.middlewares": "mdw_SecureHeaders@file",
        f"{_http_rou_opt}.service": "svc_DohServer",
    }


class UnboundConfig(ContainerBaseConfig):
    """Config for unbound container"""

    name = "unbound"  #: DO NOT CHANGE
    image = f"mvance/{EVARS.get('UNBOUND_VARIANT', 'unbound')}:latest"
    ports: Dict[str, Union[str, List[Optional[str]]]] = {"53": []}
    volumes = {
        **ContainerBaseConfig.volumes,
        f"{USER_CONFIG_DIR.joinpath('unbound-docker/configs')}": {
            "bind": "/opt/unbound/etc/unbound/",
            "mode": "rw",
        },
        f"{USER_CONFIG_DIR.joinpath('unbound-docker/unbound.sh')}": {
            "bind": "/unbound.sh",
            "mode": "ro",
        },
    }
    labels = {"traefik.enable": "false"}


class PiholeConfig(ContainerBaseConfig):
    """Config for pihole container"""

    name = "pihole"  #: DO NOT CHANGE
    hostname = f"{EVARS.get('HOST_NAME', 'DoTH-DNS')}"
    image = "pihole/pihole:latest"
    environment = {
        **ContainerBaseConfig.environment,
        "ServerIP": EVARS["HOST_IP"],
        "DNS1": "208.67.222.222#53",  #: OpenDNS, only for initial boot3
        "DNS2": "no",
        "DOMAIN": f"{ContainerBaseConfig._domain}",
        "HOST_IP": EVARS["HOST_IP"],
    }
    ports: Dict[str, Union[str, List[Optional[str]]]] = {
        "53/tcp": "53",
        "53/udp": "53",
        "80": [],
    }
    _s6_dir = USER_CONFIG_DIR.joinpath("pihole-docker/s6_scripts/")
    volumes = {
        **ContainerBaseConfig.volumes,
        f"{USER_CONFIG_DIR.joinpath('pihole-docker/configs/pihole')}": {
            "bind": "/etc/pihole",
            "mode": "rw",
        },
        f"{USER_CONFIG_DIR.joinpath('pihole-docker/configs/dnsmasq.d/')}": {
            "bind": "/etc/dnsmasq.d/",
            "mode": "rw",
        },
        f"{USER_CONFIG_DIR.joinpath('pihole-docker/configs/resolv.conf')}": {
            "bind": "/etc/resolv.conf",
            "mode": "ro",
        },
        f"{_s6_dir.joinpath('cont-init.d/01-conf-dnsmasq.sh')}": {
            "bind": "/etc/cont-init.d/01-conf-dnsmasq.sh",
            "mode": "rw",  #: Must be 'rw' for s6 to work
        },
        f"{_s6_dir.joinpath('cont-init.d/21-conf-dns.sh')}": {
            "bind": "/etc/cont-init.d/21-conf-dns.sh",
            "mode": "rw",  #: Must be 'rw' for s6 to work
        },
        f"{_s6_dir.joinpath('fix-attrs.d/02-chown-pihole-configs')}": {
            "bind": "/etc/fix-attrs.d/02-chown-pihole-configs",
            "mode": "rw",  #: Must be 'rw' for s6 to work
        },
    }
    _http_mdw = "traefik.http.middlewares"
    _http_mdw_redirect_regex = f"{_http_mdw}.mdw_RedirectPihole.redirectregex"
    _http_mdw_admin_replace = f"{_http_mdw}.mdw_AddAdminPath.replacepathregex"
    _http_rou_opt = "traefik.http.routers.rou_PiholeGui"
    _tcp_rou_opt = "traefik.tcp.routers.rou_PiholeDot"
    labels = {
        **ContainerBaseConfig.labels,
        #: Middleware redirecting pi.hole
        f"{_http_mdw_redirect_regex}.permanent": "true",
        f"{_http_mdw_redirect_regex}.regex": r"^.*pi\.hole(.*)",
        f"{_http_mdw_redirect_regex}.replacement": ""
        f"https://pihole.{ContainerBaseConfig._domain}$1",
        #: Middleware to make sure `/admin` is there
        f"{_http_mdw_admin_replace}.regex": r"^/((?i:(admin)/{0,1}|.{0})(.*))",
        f"{_http_mdw_admin_replace}.replacement": "/admin/$3",
        #: Middleware chain
        f"{_http_mdw}.mdw_PiholeChain.chain.middlewares": ""
        "mdw_RedirectPihole,mdw_AddAdminPath,mdw_SecureHeaders@file",
        #: Pihole dashboard
        "traefik.http.services.svc_PiholeGui.loadbalancer.server.port": "80",
        f"{_http_rou_opt}.entrypoints": "https",
        f"{_http_rou_opt}.rule": ""
        f"Host(`pihole.{ContainerBaseConfig._domain}`,`pi.hole`)",
        f"{_http_rou_opt}.tls": "true",
        f"{_http_rou_opt}.tls.options": "default",
        f"{_http_rou_opt}.middlewares": "mdw_PiholeChain",
        f"{_http_rou_opt}.service": "svc_PiholeGui",
        #: DoT: TLS termination and forwarding request to pihole
        "traefik.tcp.services.svc_PiholeDns.loadbalancer.server.port": "53",
        f"{_tcp_rou_opt}.entrypoints": "dot",
        f"{_tcp_rou_opt}.rule": f"HostSNI(`dot.{ContainerBaseConfig._domain}`)",
        f"{_tcp_rou_opt}.tls": "true",
        f"{_tcp_rou_opt}.tls.options": "default",
        f"{_tcp_rou_opt}.service": "svc_PiholeDns",
    }


class TraefikConfig(ContainerBaseConfig):
    """Config for traefik container"""

    name = "traefik"  #: DO NOT CHANGE
    image = "traefik:v2.1"
    ports: Dict[str, Union[str, List[Optional[str]]]] = {
        "80": "80",
        "443": "443",
        "853": "853",
        "8080": "8080",
    }
    volumes = {
        **ContainerBaseConfig.volumes,
        "/var/run/docker.sock": {"bind": "/var/run/docker.sock", "mode": "ro"},
        f"{USER_CONFIG_DIR.joinpath('traefik-docker/configs/')}": {
            "bind": "/etc/traefik/",
            "mode": "rw",
        },
        f"{USER_CONFIG_DIR.joinpath('traefik-docker/shared/')}": {
            "bind": "/shared/",
            "mode": "ro",
        },
        f"{USER_CONFIG_DIR.joinpath('certificates/cert.crt')}": {
            "bind": "/etc/ssl/certs/cert.crt",
            "mode": "ro",
        },
        f"{USER_CONFIG_DIR.joinpath('certificates/key.key')}": {
            "bind": "/etc/ssl/private/key.key",
            "mode": "ro",
        },
    }
    _http_mdw = "traefik.http.middlewares"
    _http_rou_opt = "traefik.http.routers.rou_Traefik"
    labels = {
        **ContainerBaseConfig.labels,
        #: traefik dashboard authentication
        f"{_http_mdw}.mdw_TraefikAuth.basicauth.usersfile": "/shared/.htpasswd",
        #: Middleware chain for NoAuth
        f"{_http_mdw}.mdw_TraefikChainNoAuth.chain.middlewares": ""
        "mdw_SecureHeaders@file",
        #: Middleware chain for Auth
        f"{_http_mdw}.mdw_TraefikChainAuth.chain.middlewares": ""
        "mdw_SecureHeaders@file,mdw_TraefikAuth",
        #: traefik dashboard
        f"{_http_rou_opt}.entrypoints": "https",
        f"{_http_rou_opt}.rule": f"Host(`traefik.{ContainerBaseConfig._domain}`)",
        f"{_http_rou_opt}.tls": "true",
        f"{_http_rou_opt}.tls.options": "default",
        f"{_http_rou_opt}.middlewares": ""
        f"mdw_TraefikChain{EVARS.get('TRAEFIK_AUTH_MODE', 'NoAuth')}",
        f"{_http_rou_opt}.service": "api@internal",
    }
