# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'config.py' created 2020-01-26
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
    dothdns.config
    ~~~~~~~~~~~~~~

    Configuration variables for DoTH-DNS.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
from pathlib import Path


CONTAINER_NAMES = ("doh_server", "unbound", "pihole", "traefik")


CHOICES_ARCHITECTURE = ("x86", "arm")


#: Home dir
ABS_PATH_HOME = Path.home()
#: DoTH-DNS dir
ABS_PATH_HOME_REPO_DIR = Path(ABS_PATH_HOME, "DoTH-DNS")
#: unbound-docker root.hints file
ABS_PATH_HOME_REPO_DIR_UNBOUND_ROOT_HINTS_FILE = Path(
    ABS_PATH_HOME_REPO_DIR, "unbound-docker/var_dir/root.hints"
)
#: '.htpasswd' file
ABS_PATH_HOME_REPO_DIR_TRAEFIK_HTPASSWD_FILE = Path(
    ABS_PATH_HOME_REPO_DIR, "traefik-docker", "shared", ".htpasswd"
)
#: Dockerfile for doh_server
ABS_PATH_HOME_REPO_DIR_DOH_DOCKERFILE = Path(
    ABS_PATH_HOME_REPO_DIR, "doh-docker", "Dockerfile"
)
#: Docker container config file
ABS_PATH_HOME_REPO_DIR_CONTAINER_CONFIG_FILE = Path(
    ABS_PATH_HOME_REPO_DIR, "container_configs.py"
)
#: '.env' file for docker-compose
ABS_PATH_HOME_REPO_DIR_DOTENV_FILE = Path(ABS_PATH_HOME_REPO_DIR, ".env")


INI_PATHS = (
    ABS_PATH_HOME_REPO_DIR,
    ABS_PATH_HOME,
)
INI_FILES = ("dothdns.ini", ".dothdns.ini")
