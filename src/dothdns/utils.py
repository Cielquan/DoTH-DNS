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
    dothdns.utils
    ~~~~~~~~~~~~~

    Utils used by more than oen cmd.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import importlib.util
import sys

from typing import Any, Dict, Optional

from dothdns.config import (
    ABS_PATH_HOME_REPO_DIR_CONTAINER_CONFIG_FILE,
    CONTAINER_NAMES,
)


def load_container_configs_file() -> Optional[Dict[str, Dict[str, Any]]]:
    """Load, parse `container_configs.py` file and return config dict"""
    if not ABS_PATH_HOME_REPO_DIR_CONTAINER_CONFIG_FILE.is_file():
        return None

    #: Load config file
    spec = importlib.util.spec_from_file_location(
        "container_config", str(ABS_PATH_HOME_REPO_DIR_CONTAINER_CONFIG_FILE)
    )
    config_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(config_module)  # type: ignore

    try:
        container_classes = (
            config_module.DohServerConfig,  # type: ignore
            config_module.UnboundConfig,  # type: ignore
            config_module.PiholeConfig,  # type: ignore
            config_module.TraefikConfig,  # type: ignore
        )
        network_class = config_module.NetworkConfig  # type: ignore
    except AttributeError as exc:
        print(
            "ERROR: While loading container config "
            f"a missing config class was found: {exc}"
        )
        sys.exit(1)

    configs: Dict[str, Dict[str, Any]] = {}

    #: Load container config classes
    for config_cls in container_classes:
        #: Abort if name was changed
        if config_cls.name not in CONTAINER_NAMES:
            print(
                f"ERROR: Config class '{config_cls}' "
                f"has an invalid name: {config_cls.name}"
            )
            sys.exit(1)

        #: Get all attrs from config class except internals (start w/ '_')
        attrs = [attr for attr in dir(config_cls) if not attr.startswith("_")]

        #: Append config class as dict to rv dict
        configs[config_cls.name] = {key: getattr(config_cls, key) for key in attrs}

    #: Load network config
    network_class_attr_list = [
        attr for attr in dir(network_class) if not attr.startswith("_")
    ]
    #: Append network config class as dict to rv dict
    configs["network"] = {
        key: getattr(network_class, key) for key in network_class_attr_list
    }

    return configs
