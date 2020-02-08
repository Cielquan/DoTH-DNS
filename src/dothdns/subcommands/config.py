# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'cmd_config.py' created 2020-01-25
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
    dothdns.subcommands.config
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

    `config` subcommand for `dothdns` command.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import os
import platform
import socket

from typing import Dict

import click
import tzlocal  # type: ignore

from ..config import (
    ABS_PATH_HOME_REPO_DIR_TRAEFIK_HTPASSWD_FILE,
    CHOICES_ARCHITECTURE,
)
from ..helpers import CommandWithConfigFile, add_to_dotenv
from .init import create_config_dir


@click.command(cls=CommandWithConfigFile)
@click.option("--fresh", is_flag=True, help="Discard '.env' and write new")
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
    "network.",
)
@click.option(
    "-a",
    "--architecture",
    envvar="ARCHITECTURE",
    type=click.Choice(CHOICES_ARCHITECTURE, case_sensitive=False),
    help="ARCHITECTURE of the system's processor",
)
@click.option(
    "-i",
    "--host-ip",
    envvar="HOST_IP",
    help="HOST_IP address corresponding to INTERFACE",
)
@click.option("-H", "--hostname", envvar="HOST_NAME", help="HOST_NAME of the system")
@click.option("-t", "--timezone", envvar=["TIMEZONE"], help="TIMEZONE of the system")
@click.option(
    "-d",
    "--domain",
    envvar="DOMAIN",
    help="DOMAIN for dashboards and DoH. [default: HOSTNAME.dns]",
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
    """Edit or create DoTH-DNS configuration file"""
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
        click.secho(
            "ERROR: HOST_IP was not set and could not be guessed. "
            "Please set HOST_IP via '-i' option or in dothdns.ini to avoid"
            "future problems and recall this command.",
            err=True,
            fg="red",
        )
        ctx.exit()

    #: HOST_NAME
    if hostname is None:
        hostname = platform.node()

    if hostname:
        env_dict.update(HOST_NAME=hostname)

    #: ARCHITECTURE
    if architecture is None:
        architecture = platform.machine()

    if not architecture:
        click.secho(
            "WARNING: ARCHITECTURE was not set and could not be guessed. "
            "Falling back to 'x86' architecture. To avoid this warning or if "
            "you use 'arm' architecture please set ARCHITECTURE in "
            "dothdns.ini.",
            fg="yellow",
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
    if create_config_dir(overwrite=False):
        click.secho("New 'DoTH-DNS' config dir created.")

    #: Add env vars to '.env'
    if add_to_dotenv(env_dict, overwrite=fresh) is not None:
        click.secho("SUCCESS: environment variables set in '.env' file.", fg="green")
