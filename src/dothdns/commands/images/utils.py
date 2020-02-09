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
    dothdns.commands.images.utils
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Utilities for `images` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import re

from datetime import datetime, timezone
from typing import Dict, Tuple

import docker  # type: ignore
import requests

from docker import errors as docker_exc

from ...config import ABS_PATH_HOME_REPO_DIR_DOH_DIR
from ...helpers import process_func_output


@process_func_output
def doh_compile(
    force: bool = False, update: bool = False
) -> Tuple[bool, bool, Dict[str, str]]:
    """Compile doh_server docker image

    :param force: Force recreation if already exists
    :param update: Update if newer version is available
    :returns: If error, if print always and output for click.secho
    """
    #: Get latest version from github for doh server
    tag = requests.get(
        "https://api.github.com/repos/m13253/dns-over-https/tags"
    ).json()[0]["name"]
    extract = re.search(r"([0-9]+\.[0-9]+\.[0-9]+)", tag)
    if extract:
        version = extract.group(0)
    else:
        return (
            True,
            True,
            {
                "message": "ERROR: Current version for 'm13253/dns-over-https' "
                "could not be catched.",
                "fg": "red",
            },
        )

    client = docker.from_env()

    if not force:
        #: Check for image
        try:
            image = client.images.get("cielquan/doh_server")
            #: Exit if no newer version is available
            if version == image.labels["org.label-schema.version"]:
                return (
                    False,
                    False,
                    {
                        "message": f"Latest 'doh_server' image found: {image.id}",
                        "fg": "cyan",
                    },
                )
            #: Exit if 'update' is False
            if not update:
                return (
                    False,
                    False,
                    {
                        "message": "New version for 'doh_server' image available: "
                        f"{version}.",
                        "fg": "cyan",
                    },
                )
        except docker_exc.ImageNotFound:
            pass
        except docker_exc.APIError as exc:
            return (
                True,
                True,
                {
                    "message": f"ERROR: While searching the 'doh_server' image "
                    f"an API error occurred: {str(exc)}",
                    "fg": "red",
                },
            )

    #: Build the image
    build_date = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S%Z")

    try:
        image, _ = client.images.build(
            path=str(ABS_PATH_HOME_REPO_DIR_DOH_DIR),
            buildargs={"VERSION": version, "BUILD_DATE": build_date},
            tag="cielquan/doh_server",
            rm=True,
            quiet=False,
        )
    except (docker_exc.BuildError, docker_exc.APIError) as exc:
        return (
            True,
            True,
            {
                "message": f"ERROR: The build of 'doh_server' image raised "
                f"an error: {str(exc)}",
                "fg": "red",
            },
        )

    return (
        False,
        True,
        {"message": f"New 'doh_server' image was build: {str(image)}", "fg": "green"},
    )
