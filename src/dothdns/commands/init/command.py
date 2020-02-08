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
    help="Overwrite existing config dir, but files added by the user stay.",
)
@click.option(
    "-F",
    "--fresh",
    "creation_level",
    flag_value=2,
    help="Overwrite existing config dir totally. No files will be kept.",
)
@click.help_option("-h", "--help")
@click.pass_context
def init(ctx, creation_level):
    """Create DoTH-DNS config directory in home directory"""
    #: Create config dir
    err, msg = create_config_dir(creation_level=creation_level)
    click.secho(msg["message"], err=err, fg=msg.get("fg", None))
    if err:
        ctx.abort()

    #: Download 'root.hints' file
    root_hints = requests.get("https://www.internic.net/domain/named.root")
    with open(ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE, "w") as file:
        file.write(root_hints.text)
