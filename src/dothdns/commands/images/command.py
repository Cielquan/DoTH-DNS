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
    dothdns.commands.images.command
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    `images` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import click
import docker  # type: ignore

from docker import errors as docker_exc

from ...utils import load_container_configs_file
from ..init import init
from .utils import doh_compile


@click.command()
@click.option(
    "-c",
    "--recompile",
    is_flag=True,
    default=False,
    help="Force recompiling 'cielquan/doh_server' docker image.",
)
@click.option(
    "-u",
    "--update",
    multiple=True,
    help="Update given image. Can be set multiple times. "
    "Accepted values: ['doh_server', 'unbound', 'pihole', 'traefik']",
)
@click.option("-U", "--update-all", help="Update all images if updates are available.")
@click.help_option("-h", "--help")
@click.pass_context
def images(ctx, recompile, update, update_all) -> None:
    """Handle DoTH-DNS docker images"""
    #: pylint: disable=R0914
    #: Compile doh_image
    err, always_print, msg = doh_compile(
        force=recompile, update=("doh_server" in update or update_all)
    )
    print_stop_cmd = ["run"]
    if ctx.obj.get("invoked_internally_by") not in print_stop_cmd or always_print:
        click.secho(msg["message"], err=err, fg=msg.get("fg", None))
    if err:
        ctx.abort()

    #: Create config dir if non exists
    ctx.obj["invoked_internally_by"] = "images"
    ctx.invoke(init, creation_level=0, new_download=False)
    #: Load container configs for image info
    container_config = load_container_configs_file()

    if container_config is None:
        click.secho(
            "ERROR: Could not load configs from `container_configs.py` file. "
            "Please run `dothdns init` to create a config directory",
            err=True,
            fg="red",
        )
        ctx.abort()

    image_dict = {
        "unbound": container_config["unbound"]["image"],  # type: ignore
        "pihole": container_config["pihole"]["image"],  # type: ignore
        "traefik": container_config["traefik"]["image"],  # type: ignore
    }

    client = docker.from_env()

    #: Check images
    for key in image_dict:
        image, tag = image_dict[key].split(":")
        try:
            img = client.images.get(image)
        except docker_exc.ImageNotFound:
            img = None
        except docker_exc.APIError as exc:
            click.secho(
                f"ERROR: While searching the '{image}' image an API error "
                f"occurred: {str(exc)}",
                err=True,
                fg="red",
            )
            ctx.abort()

        #: Pull images
        if img is None or key in update or update_all:
            try:
                client.images.pull(image, tag=tag)
            except docker_exc.APIError as exc:
                click.secho(
                    f"ERROR: While pulling the '{image}' image an API error "
                    f"occurred: {str(exc)}",
                    err=True,
                    fg="red",
                )
                ctx.abort()