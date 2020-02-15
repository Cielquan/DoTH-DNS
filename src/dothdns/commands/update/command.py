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
    dothdns.commands.update.command
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    `update` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import click

from ...commands import down, images, run
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
    "--proxy/--no-proxy",
    default=None,
    envvar="PROXY",
    help="If predefined instance of traefik should be used as reverse proxy. "
    "[default: True]",
)
@click.help_option("-h", "--help")
@click.pass_context
def update(ctx, container_name, proxy) -> None:
    """Update DoTH-DNS container"""
    #: If proxy not set, set default
    if proxy is None:
        proxy = True

    #: Shut containers down and remove them
    echo_wr({"txt": "Removing current container(s).", "cat": "info"})
    ctx.obj["invoked_internally_by"] = "update"
    ctx.invoke(
        down, container_name=container_name or CONTAINER_NAMES, remove=True, force=True
    )

    #: Update images
    echo_wr({"txt": "Updating upgradable images.", "cat": "info"})
    ctx.obj["invoked_internally_by"] = "update"
    ctx.invoke(
        images,
        update=container_name if len(container_name) < 4 else [],
        update_all=not len(container_name) < 4,
    )

    #: Recreate containers
    echo_wr({"txt": "Recreating container(s).", "cat": "info"})
    ctx.obj["invoked_internally_by"] = "update"
    ctx.invoke(run, proxy=proxy)

    echo_wr({"txt": "Update finished.", "cat": "success"})
