# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'helpers.py' created 2020-01-25
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
    dothdns.helpers
    ~~~~~~~~~~~~~~~

    Helper stuff for other modules.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
from configparser import ConfigParser
from pathlib import Path
from typing import Dict, Iterable, Optional, Union

import click

from .config import (
    ABS_PATH_HOME_REPO_DIR_DOTENV_FILE,
    CHOICES_ARCHITECTURE,
    INI_FILES,
    INI_PATHS,
)


def file_finder(paths: Iterable[Path], file_names: Iterable[str]) -> Optional[Path]:
    """Search first existing file

    :param paths: Paths to check
    :param file_names: File name to check
    :return: First found file
    """
    file = None

    for path in paths:
        #: Skip non existing paths
        if not path.exists():
            continue

        for file_name in file_names:
            test_path = Path(path, file_name)
            if test_path.exists():
                file = test_path
                break

        if file:
            break

    return file


def get_bool(value: Union[str, int, bool]) -> Optional[bool]:
    """Convert given value to boolean

    :param value: Value to be a boolean
    :return: Python bool
    """
    booleans = {
        "1": True,
        "y": True,
        "yes": True,
        "true": True,
        "0": False,
        "n": False,
        "no": False,
        "false": False,
    }
    return booleans.get(str(value).lower(), None)


class CommandWithConfigFile(click.Command):
    """Command subclass with config file import"""

    @staticmethod
    def _check_choice(value: str, choices: Iterable[str]) -> Optional[str]:
        """Check if value is a valid choice

        :param value: Value to be checked
        :param choices: Valid choices
        :return: Valid value
        """
        if value in choices:
            return value
        return None

    def invoke(self, ctx: click.core.Context) -> Optional[click.core.Context]:
        """Overwritten method loading config file"""
        config_file = file_finder(INI_PATHS, INI_FILES)
        if config_file is not None:
            config = ConfigParser()
            config.read(config_file)

            if "dothdns" in config.sections():
                conf = config["dothdns"]
                ini_config = {
                    "fallback": get_bool(conf.get("fallback")),
                    "traefik_no_auth": get_bool(conf.get("traefik_no_auth")),
                    "traefik_network": conf.get("traefik_network"),
                    "architecture": self._check_choice(
                        conf.get("architecture"), CHOICES_ARCHITECTURE
                    ),
                    "interface": conf.get("interface"),
                    "host_ip": conf.get("host_ip"),
                    "hostname": conf.get("hostname"),
                    "timezone": conf.get("timezone"),
                    "domain": conf.get("domain"),
                }

                for param, value in ctx.params.items():
                    if value is None and param in ini_config:
                        ctx.params[param] = ini_config[param]

        return super().invoke(ctx)


def get_env_file_data(env_file: Union[str, Path]) -> Dict[str, str]:
    """Extract environment variables from given file

    :param env_file: File to extract from
    :return: Extracted variable:value pairs
    """
    env_file_dict = {}
    with open(env_file) as file:
        for line in file:
            line = line.strip()
            #: Skip none var=val and comment lines
            if "=" not in line or line.startswith("#"):
                continue
            key, val = line.split("=", 1)
            key = key.strip().upper()
            val = val.strip()
            env_file_dict[key] = val

    return env_file_dict


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

    #: Merge env vars from dict and file; set write mode to 'append' or 'write'
    if overwrite is True:
        dict_to_add = {**file_dict, **var_dict}
    else:
        dict_to_add = {**var_dict, **file_dict}

    #: Write env vars to .env file
    with open(str(env_file), "w") as file:
        file.writelines(f"{key.upper()}={dict_to_add[key]}\n" for key in dict_to_add)

    return str(env_file)
