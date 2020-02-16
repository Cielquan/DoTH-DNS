# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'command.py' created 2020-01-25
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
    dothdns.commands.config.command
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    `config` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import os
import platform
import socket

from typing import Dict

import click
import tzlocal  # type: ignore

from ...config import (
    ABS_PATH_HOME_REPO_DIR_TRAEFIK_HTPASSWD_FILE,
    CHOICES_ARCHITECTURE,
)
from ...helpers import echo_wr
from ..cmd_class import CommandWithConfigFile
from ..init import init
from .utils import add_to_dotenv


@click.command(cls=CommandWithConfigFile)
@click.option(
    "--fresh", is_flag=True, help="Discard current `.env` file and write new file."
)
@click.option(
    "-n/-N",
    "--traefik-auth/--traefik-no-auth",
    default=None,
    envvar="TRAEFIK_AUTH",
    help="Activate authentication for traefik dashboard when `.htpasswd` file is "
    "present. [default: True]",
)
@click.option(
    "--traefik-network",
    envvar="TRAEFIK_NETWORK",
    help="Docker network to use for internal communication. Defaults to predefined "
    "network. Only change if you know what you do.",
)
@click.option(
    "-a",
    "--architecture",
    envvar="ARCHITECTURE",
    type=click.Choice(CHOICES_ARCHITECTURE, case_sensitive=False),
    help="ARCHITECTURE of the system's processor. [case-insensitive]",
)
@click.option(
    "-i",
    "--host-ip",
    envvar="HOST_IP",
    help="HOST_IP address used by the system by default.",
)
@click.option("-H", "--hostname", envvar="HOST_NAME", help="The system's HOST_NAME.")
@click.option(
    "-t",
    "--timezone",
    envvar="TIMEZONE",
    help="TIMEZONE of the system in 'olson' format. See docs for more info.",
)
@click.option(
    "-d",
    "--domain",
    envvar="DOMAIN",
    help="DOMAIN for dashboards, DoH and DoT (SNI). Defaults to [HOSTNAME.dns] and "
    "falls back to [doth.dns] if not HOST_NAME is found or given.",
)
@click.help_option("-h", "--help")
@click.pass_context
def config(  #: pylint: disable=C0330,R0912,R0913
    ctx,
    fresh,
    traefik_auth,
    traefik_network,
    architecture,
    host_ip,
    hostname,
    timezone,
    domain,
) -> None:
    """Edit or create DoTH-DNS configuration"""
    env_dict: Dict[str, str] = dict()

    #: HOST_IP
    if host_ip is None:
        #: https://stackoverflow.com/a/28950776
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            #: doesn't even have to be reachable
            sock.connect(("10.255.255.255", 1))
            host_ip = sock.getsockname()[0]
        except Exception:  #: pylint: disable=W0703
            host_ip = "127.0.0.1"
        finally:
            sock.close()

    if host_ip:
        env_dict.update(HOST_IP=host_ip)
    else:
        echo_wr(
            {
                "txt": "HOST_IP was not set and could not be guessed. "
                "Please set HOST_IP via `-i` option or in `dothdns.ini` to avoid"
                "future problems and recall this command.",
                "err": True,
                "cat": "error",
            }
        )

    #: HOST_NAME
    if hostname is None:
        hostname = platform.node()

    if hostname:
        env_dict.update(HOST_NAME=hostname)

    #: ARCHITECTURE
    if architecture is None:
        architecture = platform.machine()

    if not architecture:
        echo_wr(
            {
                "txt": "ARCHITECTURE was not set and could not be guessed. "
                "Falling back to 'x86' architecture. To avoid this warning or if "
                "you use 'arm' architecture please set ARCHITECTURE in "
                "`dothdns.ini`.",
                "cat": "warning",
            }
        )
    elif "arm" in architecture:
        env_dict.update(UNBOUND_VARIANT="unbound-rpi")

    # TIMEZONE
    if timezone is None:
        timezone = os.environ.get("TZ", None)
    if timezone is None:
        timezone = str(tzlocal.get_localzone())

    if timezone:
        env_dict.update(TIMEZONE=timezone)

    #: TRAEFIK_AUTH_MODE
    if ABS_PATH_HOME_REPO_DIR_TRAEFIK_HTPASSWD_FILE.is_file() and (
        traefik_auth is True or traefik_auth is None
    ):
        env_dict.update(TRAEFIK_AUTH_MODE="Auth")
    elif traefik_auth is False:
        env_dict.update(TRAEFIK_AUTH_MODE="NoAuth")

    #: TRAEFIK_NETWORK
    if traefik_network:
        env_dict.update(TRAEFIK_NETWORK=traefik_network)

    #: DOMAIN
    if domain:
        env_dict.update(DOMAIN=domain)

    #: Create config dir if non exists
    ctx.obj["invoked_internally_by"] = "config"
    ctx.invoke(init, creation_level=0)

    #: Add env vars to `.env`
    if add_to_dotenv(env_dict, overwrite=fresh) is not None:
        echo_wr({"txt": "Set environment variables in `.env` file.", "cat": "success"})
