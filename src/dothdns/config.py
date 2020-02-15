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


#: DO NOT CHANGE NAMES .. order is start up order and my be changed
CONTAINER_NAMES = ("traefik", "doh_server", "pihole", "unbound")


#: Choices for `dothdns config -a`
CHOICES_ARCHITECTURE = ("x86", "arm")


#: Home dir
ABS_PATH_HOME = Path.home()
#: DoTH-DNS dir
ABS_PATH_HOME_REPO_DIR = Path(ABS_PATH_HOME, "DoTH-DNS")
#: certificates dir
ABS_PATH_HOME_REPO_DIR_CERT_DIR = Path(ABS_PATH_HOME_REPO_DIR, "certificates")
#: traefik-docker `.htpasswd` file
ABS_PATH_HOME_REPO_DIR_TRAEFIK_HTPASSWD_FILE = Path(
    ABS_PATH_HOME_REPO_DIR, "traefik-docker", "shared", ".htpasswd"
)
#: doh_server `Dockerfile` file
ABS_PATH_HOME_REPO_DIR_DOH_DIR = Path(ABS_PATH_HOME_REPO_DIR, "doh-docker")
#: `container_configs.py` file
ABS_PATH_HOME_REPO_DIR_CONTAINER_CONFIG_FILE = Path(
    ABS_PATH_HOME_REPO_DIR, "container_configs.py"
)
#: `.env` file for `container_configs.py`
ABS_PATH_HOME_REPO_DIR_DOTENV_FILE = Path(ABS_PATH_HOME_REPO_DIR, ".env")


#: Paths an ini file can be placed
INI_PATHS = (
    ABS_PATH_HOME_REPO_DIR,
    ABS_PATH_HOME,
)
#: Names the ini file can have
INI_FILES = ("dothdns.ini", ".dothdns.ini")
