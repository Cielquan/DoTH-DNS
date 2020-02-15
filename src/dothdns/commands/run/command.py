# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'cmd_start.py' created 2020-01-25
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
    dothdns.subcommands.run
    ~~~~~~~~~~~~~~~~~~~~~~~

    `run` subcommand for `dothdns` command.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
#: pylint: disable=R0912,R0915
import click
import docker  # type: ignore
import docker.errors  # type: ignore

from ...commands import config, images
from ...config import (
    ABS_PATH_HOME_REPO_DIR_CERT_DIR,
    ABS_PATH_HOME_REPO_DIR_DOTENV_FILE,
    CONTAINER_NAMES,
)
from ...helpers import echo_wr, get_env_file_data
from ...utils import load_container_configs_file
from ..cmd_class import CommandWithConfigFile
from .utils import (
    container_boot_check,
    pihole_blocklist_n_service_setup_check,
    pihole_password_check,
    unbound_dnssec_check,
)


@click.command(cls=CommandWithConfigFile)
@click.option(
    "--proxy/--no-proxy",
    default=None,
    envvar="PROXY",
    help="If predefined instance of traefik should be used as reverse proxy. "
    "[default: True]",
)
@click.help_option("-h", "--help")
@click.pass_context
def run(ctx, proxy) -> None:
    """Start DoTH-DNS docker container"""
    #: If proxy not set, set default
    if proxy is None:
        proxy = True

    ctx.obj["invoked_internally_by"] = "run"
    ctx.invoke(config)

    #: Check for cert.crt and key.key
    missing = []
    if not ABS_PATH_HOME_REPO_DIR_CERT_DIR.joinpath("cert.crt").is_file():
        missing.append("cert.crt")
    if not ABS_PATH_HOME_REPO_DIR_CERT_DIR.joinpath("key.key").is_file():
        missing.append("key.key")
    if missing:
        echo_wr(
            {
                "txt": f"No {missing} file{'s' if len(missing) == 2 else ''} found. "
                "Dashboards, DoH and DoT need both a 'certificate' and a corresponding "
                "'key'. If you have not set those files up on another way encryption "
                "will not work properly.",
                "cat": "warning",
            }
        )

    #: Load configs
    configs = load_container_configs_file()
    if configs is None:
        echo_wr(
            {
                "txt": "No 'container_configs.py' file found. Run 'dothdns config' "
                "to create config directory and configure the setup.",
                "err": True,
                "cat": "error",
            }
        )

    #: Create config dir if non exists
    ctx.obj["invoked_internally_by"] = "run"
    ctx.invoke(images, recompile=False, update=[], update_all=False)

    client = docker.from_env()

    #: Create network
    network_config = configs["network"]  # type: ignore
    if proxy:
        try:
            network = client.networks.get(network_config["name"])
        except docker.errors.NotFound:
            network = client.networks.create(**network_config)
            echo_wr({"txt": f"Created '{network.name}' network.", "cat": "success"})
        echo_wr({"txt": f"Using '{network.name}' network.", "cat": "info"})
    else:
        env_vars = get_env_file_data(ABS_PATH_HOME_REPO_DIR_DOTENV_FILE)
        try:
            network = client.networks.get(env_vars["TRAEFIK_NETWORK"])
        except docker.errors.NotFound:
            echo_wr({"txt": "Custom network not found.", "err": True, "cat": "error"})
        except KeyError:
            echo_wr(
                {
                    "txt": "Traefik proxy deactivated but no custom network defined.",
                    "err": True,
                    "cat": "error",
                }
            )
        echo_wr({"txt": f"Using custom '{network.name}' network.", "cat": "info"})

    #: Create container
    started_containers = []
    for container_name in CONTAINER_NAMES:
        try:
            client.containers.get(container_name)
        except docker.errors.NotFound:
            echo_wr({"txt": f"Starting '{container_name}'.", "cat": "info"})
            container = client.containers.run(**configs[container_name])  # type: ignore
            started_containers.append(container)
            if not proxy:
                network.disconnect(container_name)
        else:
            echo_wr(
                {
                    "txt": f"Container '{container_name}' is already running/existing.",
                    "cat": "info",
                }
            )

    #: Check started containers
    for container in started_containers:
        #: Check boot of container
        max_time = 60
        if not container_boot_check(container, max_time=max_time):
            echo_wr(
                {
                    "txt": f"Container '{container.name}' did not pass boot up check "
                    f"in {max_time} seconds. Check logs for more information.",
                    "cat": "warning",
                }
            )
        else:
            #: Additional functionality checks
            if container.name == "pihole":
                pihole_blocklist_n_service_setup_check(container)
                pihole_password_check(container)
            if container.name == "unbound":
                unbound_dnssec_check(container)
        echo_wr({"txt": f"Boot of '{container.name}' finished.", "cat": "success"})
