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

    Helper functions for other modules.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
from pathlib import Path
from typing import Callable, Dict, Iterable, Optional, Union, cast

import click

from click.core import Context


def file_finder(paths: Iterable[Path], file_names: Iterable[str]) -> Optional[Path]:
    """Search first existing file

    :param paths: Paths to check
    :param file_names: File names to check
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
    :return: Python bool if valid
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


def get_env_file_data(env_file: Union[str, Path]) -> Dict[str, str]:
    """Extract environment variables from given file (`.env`)

    :param env_file: File to extract from
    :return: Extracted variable:value pairs
    """
    env_file_dict = {}
    with open(env_file) as file:
        for line in file:
            line = line.strip()
            #: Skip none key=val and comment lines
            if "=" not in line or line.startswith("#"):
                continue
            key, val = line.split("=", 1)
            key = key.strip().upper()
            val = val.strip()
            env_file_dict[key] = val

    return env_file_dict


def echo_wr(msg: Dict[str, Union[str, bool]]) -> None:
    """Echo given message"""
    # Categories for click.echo
    echo_cat = {
        "attention": click.style("ATTENTION: ", fg="bright_yellow"),
        "warning": click.style("WARNING:   ", fg="yellow"),
        "error": click.style("ERROR:     ", fg="red"),
        "success": click.style("SUCCESS:   ", fg="green"),
        "info": click.style("INFO:      ", fg="cyan"),
    }

    #: Get data needed for printing
    msg_cat = cast(str, msg.get("cat", ""))
    msg_txt = cast(Optional[str], msg.get("txt"))
    msg_err = cast(bool, msg.get("err", False))
    msg_fg = cast(Optional[str], msg.get("fg"))

    if msg_txt:
        click.echo(echo_cat.get(msg_cat, ""), err=msg_err, nl=False)
        click.secho(msg_txt, err=msg_err, fg=msg_fg)


def process_func_output(
    function: Callable[..., Dict[str, Union[str, bool]]]
) -> Callable[..., None]:
    """Handle feedback from sub functions called in cmd functions"""

    @click.pass_context
    def wrapper(ctx: Context, *args, **kwargs) -> None:
        """Work with given function"""

        msg = function(*args, **kwargs)

        if msg.get("always_print", True) or ctx.obj.get(
            "invoked_internally_by"
        ) not in ctx.obj.get("do_not_print_when_invoked_by", []):
            echo_wr(msg)

        if msg.get("err"):
            ctx.abort()

    return wrapper
