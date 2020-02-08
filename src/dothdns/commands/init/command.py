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
import shutil

import click
import requests

from ...config import (
    ABS_PATH_HOME_REPO_DIR,
    ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE,
    REL_PATH_PACKAGE_CONTAINER_CONFIGS_DIR,
)


def create_config_dir(*, overwrite: bool = False) -> bool:
    """Creates/Overwrites DoTH-DNS config dir in home dir"""
    if ABS_PATH_HOME_REPO_DIR.is_dir() and overwrite is False:
        return False
    shutil.copytree(
        REL_PATH_PACKAGE_CONTAINER_CONFIGS_DIR,
        ABS_PATH_HOME_REPO_DIR,
        dirs_exist_ok=True,
    )
    return True


@click.command()
@click.option("-f", "--new", is_flag=True, help="Overwrite existing config dir.")
@click.help_option("-h", "--help")
def init(new):
    """Create DoTH-DNS config directory in home directory"""
    created = create_config_dir(overwrite=new)
    if created is False:
        click.secho(
            "'DoTH-DNS' directory already exists. "
            "Call `dothdns init -f` to overwrite existing directory."
        )
    elif created is True:
        click.secho("New 'DoTH-DNS' config dir created.")

    #: Download 'root.hints' file
    root_hints = requests.get("https://www.internic.net/domain/named.root")
    with open(ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE, "w") as file:
        file.write(root_hints.text)
