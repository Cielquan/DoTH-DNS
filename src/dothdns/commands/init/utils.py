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

    Utilities for `init` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import shutil
import sys

from pathlib import Path
from typing import Dict, Union

from ...config import ABS_PATH_HOME_REPO_DIR
from ...helpers import process_func_output


@process_func_output
def create_config_dir(*, creation_level: int = 0) -> Dict[str, Union[str, bool]]:
    """Creates/Overwrites DoTH-DNS config dir in home dir

    :param creation_level: Level 0: create, not overwrite
                           Level 1: overwrite, additional files stay
                           Level 2: remove old and create
    :returns: If error, if print always and output for 'helpers.echo_wr'
    """
    #: Abort if dir exists and shall not be overwritten
    if ABS_PATH_HOME_REPO_DIR.is_dir() and creation_level == 0:
        return {
            "txt": "`DoTH-DNS` directory already exists. "
            "Call `dothdns init -f/F` to overwrite existing directory.",
            "cat": "info",
            "err": False,
            "always_print": False,
        }

    #: Remove old config dir
    if creation_level == 2:
        try:
            shutil.rmtree(ABS_PATH_HOME_REPO_DIR)
        except Exception as exc:  #: pylint: disable=W0703
            return {
                "txt": "Failed to remove old `DoTH-DNS` config directory. Remove "
                "old directory manually and call `dothdns init` again.\n"
                f"Error description: {exc}",
                "cat": "error",
                "err": True,
                "always_print": True,
            }

    #: Copy new config dir
    try:
        if sys.version_info < (3, 8):
            if creation_level == 1:
                return {
                    "txt": "'-f' option is only supported by python >= 3.8. "
                    "Use '-F' instead and safe custom files before.",
                    "cat": "error",
                    "err": True,
                    "always_print": True,
                }

            shutil.copytree(
                Path(__file__).parents[2].joinpath("container_configs"),
                ABS_PATH_HOME_REPO_DIR,
                ignore=shutil.ignore_patterns("__pycache__"),
            )
        else:
            shutil.copytree(
                Path(__file__).parents[2].joinpath("container_configs"),
                ABS_PATH_HOME_REPO_DIR,
                ignore=shutil.ignore_patterns("__pycache__"),
                dirs_exist_ok=True,
            )
    except Exception as exc:  #: pylint: disable=W0703
        return {
            "txt": "Failed to create new `DoTH-DNS` config directory. Make sure "
            "write rights are given and call `dothdns init` again.\n"
            f"Error description: {exc}",
            "cat": "error",
            "err": True,
            "always_print": True,
        }

    creation_msg = {0: "Created new", 1: "Overwrote", 2: "Created fresh"}
    return {
        "txt": f"{creation_msg[creation_level]} `DoTH-DNS` config directory.",
        "cat": "success",
        "err": False,
        "always_print": True,
    }
