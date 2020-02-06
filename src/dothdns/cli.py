# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'cli.py' created 2020-01-25
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
    dothdns.cli
    ~~~~~~~~~~~

    Base command `dothdns` for CLI.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import click

from . import __version__
from .subcommands import config, init


@click.group()
@click.version_option(
    version=__version__, prog_name="DoTH-DNS",
)
@click.help_option("-h", "--help")
def dothdns() -> None:
    """Handle your DoTH-DNS system"""
    pass  #: pylint: disable=W0107


dothdns.add_command(config)
dothdns.add_command(init)
