# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'utils.py' created 2020-02-09
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
    dothdns.commands.run.utils
    ~~~~~~~~~~~~~~~~~~~~~~~~~

    Utilities for `run` subcommand.

    :copyright: (c) 2019-2020 Christian Riedel
    :license: GPLv3, see LICENSE for more details
"""
import re
import time

from typing import Dict, Union

from docker.models.containers import Container  # type: ignore

from ...helpers import process_func_output


def container_boot_check(container: Container, *, max_time=60, repeat_break=3) -> bool:
    """Check for 'running' state and checks health if set

    :param container: Docker container instance to work with
    :param max_time: Maximum time in seconds to check for successful boot
    :param repeat_break: Time in second between each check
    :return: Check result
    """
    container_healthchecks = {
        "unbound": ["drill", "cloudflare.com", "@127.0.0.1"],
        "pihole": ["dig", "@127.0.0.1", "pi.hole"],
    }

    healthcheck = container_healthchecks.get(container.name)

    i = 0
    while i < max_time:
        time.sleep(repeat_break)
        i += repeat_break
        container.reload()

        if container.status == "running":
            if healthcheck is None:
                return True

            exit_code, _ = container.exec_run(healthcheck)
            if exit_code == 0:
                return True

    return False


@process_func_output
def unbound_dnssec_check(container: Container) -> Dict[str, Union[str, bool]]:
    """DNSSEC check for 'unbound' container

    :param container: Docker container instance to work with
    :returns: If error and output for 'helpers.echo_wr'
    """
    neg_fail = pos_fail = False
    #: Test DNSSEC
    #: This call should give a status report of SERVFAIL and no IP address.
    exit_code, response = container.exec_run(
        ["drill", "sigfail.verteiltesysteme.net", "@127.0.0.1", "-p", "53"]
    )
    if isinstance(response, bytes):
        response = response.decode("utf-8")
    ips = re.findall(r"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}", response)
    if exit_code == 0 and "rcode: SERVFAIL" not in response and len(ips) != 1:
        pos_fail = True

    #: This call should give NOERROR plus an IP address.
    exit_code, response = container.exec_run(
        ["drill", "sigok.verteiltesysteme.net", "@127.0.0.1", "-p", "53"]
    )
    if isinstance(response, bytes):
        response = response.decode("utf-8")
    ips = re.findall(r"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}", response)
    if exit_code == 0 and "rcode: NOERROR" not in response and len(ips) != 2:
        neg_fail = True

    #: Return message
    if pos_fail and neg_fail:
        return {
            "txt": "DNSSEC check failed both (pos/neg) tests on 'unbound'.",
            "cat": "warning",
            "err": True,
        }
    if pos_fail:
        return {
            "txt": "DNSSEC check failed 'positive' test on 'unbound'.",
            "cat": "warning",
            "err": True,
        }
    if neg_fail:
        return {
            "txt": "DNSSEC check failed 'negative' test on unbound.",
            "cat": "warning",
            "err": True,
        }

    return {"txt": "DNSSEC works on 'unbound'.", "cat": "success"}


@process_func_output
def pihole_blocklist_n_service_setup_check(
    container: Container, *, max_time=600, repeat_break=5
) -> Dict[str, Union[str, bool]]:
    """Blocklist setup check for 'pihole' container

    :param container: Docker container instance to work with
    :param max_time: Maximum time in seconds to check for successful boot
    :param repeat_break: Time in second between each check
    :returns: If error and output for 'helpers.echo_wr'
    """
    i = 0
    while i < max_time:
        time.sleep(repeat_break)
        i += repeat_break
        container.reload()
        logs = container.logs().decode("utf-8")
        if "Consolidating blocklists" in logs and "[services.d] done." in logs:
            return {
                "txt": "Pihole blocklist and service setup finished.",
                "cat": "success",
            }

    return {
        "txt": f"Pihole blocklist setup exceeded {max_time} seconds. "
        "Please check 'pihole' logs for more information.",
        "cat": "warning",
        "fg": "red",
        "err": True,
    }


@process_func_output
def pihole_password_check(container: Container) -> Dict[str, Union[str, bool]]:
    """Password check for 'pihole' container

    :param container: Docker container instance to work with
    :returns: If error and output for 'helpers.echo_wr'
    """
    #: Try extracting password from logs for 10s
    i = 0
    password = None
    while not password and i < 10:
        logs = container.logs().decode("utf-8")
        password = re.search(r"Setting password: (.+)", logs)
        if not password:
            password = re.search(r"Pre existing WEBPASSWORD found", logs)

        i += 1
        time.sleep(1)

    #: Output
    if password and password.groups():
        return {
            "txt": f"Random password was set for 'pihole': {password.group(1)}.\n"
            "Please don't forget to set a secure password for your pihole "
            "dashboard.\nRun 'docker exec pihole pihole -a -p <NEW PASSWORD>' to "
            "change it.",
            "cat": "attention",
            "fg": "bright_yellow",
        }

    if password:
        return {"txt": "Given WEBPASSWORD was set for 'pihole'.", "cat": "success"}

    return {
        "txt": "Failed to retrieve password information from 'pihole' logs.",
        "cat": "warning",
        "err": True,
    }
