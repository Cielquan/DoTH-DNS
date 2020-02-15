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

from ...commands import config
from ...config import CONTAINER_NAMES
from ...helpers import echo_wr
from ...utils import load_container_configs_file
from .utils import check_doh_image, doh_compile


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
    type=click.Choice(CONTAINER_NAMES, case_sensitive=True),
    help="Update given image. Can be set multiple times. [case-sensitive]",
)
@click.option(
    "-U",
    "--update-all",
    is_flag=True,
    default=False,
    help="Update all images if updates are available.",
)
@click.help_option("-h", "--help")
@click.pass_context
def images(ctx, recompile, update, update_all) -> None:
    """Handle DoTH-DNS docker images"""
    #: pylint: disable=R0914
    called_by = ctx.obj.get("invoked_internally_by", "")
    #: Compile doh image message
    ctx.obj["do_not_print_when_invoked_by"] = ["run", "update"]
    if ctx.obj.get("invoked_internally_by") not in ctx.obj.get(
        "do_not_print_when_invoked_by", []
    ):
        echo_wr({"txt": "Checking for 'doh_server' image. ", "cat": "info"})
    #: Create config dir if non exists
    ctx.obj["invoked_internally_by"] = "images"
    ctx.invoke(config)
    ctx.obj["invoked_internally_by"] = called_by
    ctx.obj["do_not_print_when_invoked_by"] = ["run"]

    #: Check doh image
    check_doh_image(  #: pylint: disable=E1120,E1123
        force=recompile, update=("doh_server" in update or update_all)
    )

    #: Compile doh image
    version = ctx.obj.get("doh_version")
    if version is not None:
        echo_wr(
            {
                "txt": f"Compiling image for 'doh_server' for version {version}. "
                "This may last a bit.",
                "cat": "info",
            }
        )
        doh_compile(version)

    #: Load container configs for image info
    container_config = load_container_configs_file()

    if container_config is None:
        echo_wr(
            {
                "txt": "Could not load configs from `container_configs.py` file. "
                "Please run `dothdns init` to create a config directory.",
                "err": True,
                "cat": "error",
            }
        )

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
            echo_wr(
                {
                    "txt": f"While searching the '{image}' image an API error "
                    f"occurred: {str(exc)}",
                    "err": True,
                    "cat": "error",
                }
            )

        #: Pull images
        if img is None or key in update or update_all:
            echo_wr(
                {
                    "txt": f"Pulling image for '{image}'. This may last a bit.",
                    "cat": "info",
                }
            )
            try:
                client.images.pull(image, tag=tag)
            except docker_exc.APIError as exc:
                echo_wr(
                    {
                        "txt": f"While pulling the '{image}' image an API error "
                        f"occurred: {str(exc)}",
                        "err": True,
                        "cat": "error",
                    }
                )
            echo_wr({"txt": f"Pulled image for '{image}'.", "cat": "success"})
