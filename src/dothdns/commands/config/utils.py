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
    dothdns.commands.config.utils
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Utilities for `config` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
from typing import Dict, Optional

from ...config import ABS_PATH_HOME_REPO_DIR_DOTENV_FILE
from ...helpers import get_env_file_data


def add_to_dotenv(
    var_dict: Dict[str, str], *, overwrite: bool = False, create: bool = True,
) -> Optional[str]:
    """Write Env Vars to '.env' file

    :param var_dict: Environment variables to add
    :param overwrite: Overwrite same existing entries, other entries will be kept
    :param create: Create '.env' file if non is found
    :param dotenv_paths: Possible paths
    :param dotenv_files: Possible file names
    :return: Path of env file
    """
    env_file = ABS_PATH_HOME_REPO_DIR_DOTENV_FILE

    if env_file.is_file():
        #: Get env vars from file
        file_dict = get_env_file_data(env_file)
    elif create is not True:
        #: Abort if no file and creation is not permitted
        return None
    else:
        #: No file found -> no vars to load
        file_dict = {}

    #: Merge env vars from dict and file accordingly
    if overwrite is True:
        dict_to_add = {**file_dict, **var_dict}
    else:
        dict_to_add = {**var_dict, **file_dict}

    #: Write env vars to `.env` file
    with open(str(env_file), "w") as file:
        file.writelines(f"{key.upper()}={dict_to_add[key]}\n" for key in dict_to_add)

    return str(env_file)
