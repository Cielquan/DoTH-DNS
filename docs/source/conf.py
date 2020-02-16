# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'conf.py' created 2020-01-24 is part of the project/program 'DoTH-DNS'.
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
    docs.source.conf
    ~~~~~~~~~~~~~~~~

    Configuration file for the Sphinx documentation builder.

    :copyright: 2019-2020 (c) Christian Riedel
    :license: GPLv3, see LICENSE.rst for more details
"""
#: pylint: disable=C0103
import os
import sys

from datetime import datetime
from pathlib import Path
from typing import List

import sphinx_rtd_theme  # type: ignore

from dothdns import __version__


#: Add Repo to path
sys.path.insert(0, os.path.abspath("../.."))

#: Vars
CONF_DIR = Path(__file__)
TODAY = datetime.today()
YEAR = f"{TODAY.year}"


#: -- PROJECT INFORMATION --------------------------------------------------------------

project = "DoTH-DNS"
author = "Christian Riedel"
release_year = "2019"
copyright = (  #: pylint: disable=W0622
    f"{release_year}{('-' + YEAR) if YEAR != release_year else ''}, " + author
)
#: The full version, including alpha/beta/rc tags
release = __version__
#: Major version like (X.Y)
version = ".".join(__version__.split(".")[0:2])
#: Release date
release_date = f"{TODAY}"  #: CHANGEME


#: -- SPHINX CONFIG --------------------------------------------------------------------

#: Add any Sphinx extension module names here, as strings.
extensions = [
    "sphinx_rtd_theme",
    "sphinx.ext.intersphinx",
    "sphinx_click.ext",
]

intersphinx_mapping = {"python": ("https://docs.python.org/3/", None)}


#: -- FILES ----------------------------------------------------------------------------

# source_suffix = ['.rst', '.md']
source_suffix = ".rst"

#: Index source file
master_doc = "index"

#: Files to exclude for source of doc
exclude_patterns: List[str] = []

#: Folder for static files, if folder exists
html_static_path = []
if Path(CONF_DIR, "_static").exists():
    html_static_path = ["_static"]

#: Folder for template files, if folder exists
templates_path = []
if Path(CONF_DIR, "_templates").exists():
    templates_path = ["_templates"]


#: -- HTML OUTPUT ----------------------------------------------------------------------

#: Theme
html_theme = "sphinx_rtd_theme"
html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]
html_last_updated_fmt = TODAY.isoformat()

#: Add links to *.rst source files on HTML pages
html_show_sourcelink = True

#: Pygments syntax highlighting style
pygments_style = "sphinx"

# rst_epilog = """
# """.format()
