# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'utils.py' created 2020-02-08
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
    dothdns.commands.init.utils
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Utlilties for `init` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import shutil

from pathlib import Path
from typing import Dict, Tuple

from dothdns.config import ABS_PATH_HOME_REPO_DIR


def create_config_dir(*, creation_level: int = 0) -> Tuple[bool, Dict[str, str]]:
    """Creates/Overwrites DoTH-DNS config dir in home dir

    :param creation_level: Level 0: create, not overwrite
                           Level 1: overwrite, user added stuff stays
                           Level 2: remove old and create
    :returns: If error and output for click.secho
    """
    #: Abort if dir exists and shall not be overwritten
    if ABS_PATH_HOME_REPO_DIR.is_dir() and creation_level == 0:
        return (
            False,
            {
                "message": "'DoTH-DNS' directory already exists. "
                "Call `dothdns init -f/F` to overwrite existing directory.",
                "fg": "cyan",
                "print": "only_directly_invoked",
            },
        )

    #: Remove old config dir
    if creation_level == 2:
        try:
            shutil.rmtree(ABS_PATH_HOME_REPO_DIR)
        except Exception as exc:  #: pylint: disable=W0703
            return (
                True,
                {
                    "message": "ERROR: Failed to remove old 'DoTH-DNS' config "
                    "directory. Remove old directory manually and call `dothdns init` "
                    f"again. \nError description: {exc}",
                    "fg": "red",
                },
            )

    #: Copy new config dir
    try:
        shutil.copytree(
            Path(__file__).parents[2].joinpath("container_configs"),
            ABS_PATH_HOME_REPO_DIR,
            ignore=shutil.ignore_patterns("__pycache__"),
            dirs_exist_ok=True,
        )
    except Exception as exc:  #: pylint: disable=W0703
        return (
            True,
            {
                "message": "ERROR: Failed to create new 'DoTH-DNS' config directory. "
                "Make sure write rights are given and call `dothdns init` "
                f"again. \nError description: {exc}",
                "fg": "red",
            },
        )
    creation_msg = {0: "created new", 1: "overwrote", 2: "created fresh"}
    return (
        False,
        {
            "message": f"Successfully {creation_msg[creation_level]} 'DoTH-DNS' "
            "config directory. ",
            "fg": "green",
        },
    )
