# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'cmd_class.py' created 2020-02-08
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
    dothdns.commands.cmd_class
    ~~~~~~~~~~~~~~~~~~~~~~~~~~

    click.Command subclass for loading config file inline.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
from configparser import ConfigParser
from typing import Iterable, Optional

import click

from ..config import CHOICES_ARCHITECTURE, INI_FILES, INI_PATHS
from ..helpers import file_finder, get_bool


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
                    "proxy": get_bool(conf.get("proxy")),
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
