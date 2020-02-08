# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'main.py' created 2020-02-08
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
    dothdns.commands.main
    ~~~~~~~~~~~~~~~~~~~~~

    Base command for CLI.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import click

from ..commands import config, init
from ..version import __version__


@click.group()
@click.version_option(version=__version__, prog_name="DoTH-DNS")
@click.help_option("-h", "--help")
@click.pass_context
def main(ctx) -> None:
    """Handle your DoTH-DNS system"""
    ctx.ensure_object(dict)


main.add_command(config)
main.add_command(init)
