# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'command.py' created 2020-02-08
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
    dothdns.commands.down.command
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    `down` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import click
import docker  # type: ignore
import docker.errors  # type: ignore

from ...config import CONTAINER_NAMES
from ...helpers import echo_wr


@click.command()
@click.option(
    "-c",
    "--container-name",
    multiple=True,
    type=click.Choice(CONTAINER_NAMES, case_sensitive=True),
    help="Shut down given container. Can be set multiple times. [case-sensitive]",
)
@click.option(
    "-r",
    "--remove",
    is_flag=True,
    default=False,
    help="Remove container after shutdown.",
)
@click.option(
    "-f",
    "--force",
    is_flag=True,
    default=False,
    help="Force container shutdown and removal if '-r' flag is set.",
)
@click.help_option("-h", "--help")
def down(container_name, remove, force) -> None:
    """Shut down DoTH-DNS container"""

    client = docker.from_env()

    for name in container_name or CONTAINER_NAMES:
        try:
            container = client.containers.get(name)
        except docker.errors.NotFound:
            echo_wr(
                {"txt": f"Container '{name}' could not be found.", "cat": "warning"}
            )
            continue

        container.stop(timeout=0 if force else 10)

        if remove:
            container.remove(force=force)

        echo_wr(
            {
                "txt": f"Container '{name}' was shut down"
                f"{' and removed.' if remove else '.'}",
                "cat": "info",
            }
        )
