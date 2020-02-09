# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'command.py' created 2020-02-06
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
    dothdns.commands.init.command
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    `init` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
from datetime import datetime

import click
import requests

from ...config import ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE
from .utils import create_config_dir


@click.command()
@click.option(
    "-c",
    "--only-create",
    "creation_level",
    default=True,
    flag_value=0,
    help="Only create config dir if not already existing.",
)
@click.option(
    "-f",
    "--overwrite",
    "creation_level",
    flag_value=1,
    help="Overwrite existing config dir, additional files are not touched.",
)
@click.option(
    "-F",
    "--fresh",
    "creation_level",
    flag_value=2,
    help="Overwrite existing config dir totally. No files will be kept.",
)
@click.option(
    "-d",
    "--new-download",
    is_flag=True,
    default=False,
    help="Force new download of 'root.hints' file.",
)
@click.help_option("-h", "--help")
@click.pass_context
def init(ctx, creation_level, new_download) -> None:
    """Create DoTH-DNS configuration directory"""
    #: Create config dir
    err, always_print, msg = create_config_dir(creation_level=creation_level)
    print_stop_cmd = ["config"]
    if ctx.obj.get("invoked_internally_by") not in print_stop_cmd or always_print:
        click.secho(msg["message"], err=err, fg=msg.get("fg", None))
    if err:
        ctx.abort()

    #: Check age of `root.hints` file
    if ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE.is_file() and not new_download:
        file_time_stamp = datetime.fromtimestamp(
            ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE.stat().st_ctime
        )
        if (datetime.now() - file_time_stamp).days > 30:
            new_download = True

    #: Download `root.hints` file
    if new_download:
        try:
            root_hints = requests.get("https://www.internic.net/domain/named.root")
        except requests.exceptions.ConnectionError:
            click.secho(
                "ERROR: `root.hints` file download failed. "
                "Please check your connection.",
                err=True,
                fg="red",
            )
            ctx.abort()

        with open(ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE, "w") as file:
            file.write(root_hints.text)
