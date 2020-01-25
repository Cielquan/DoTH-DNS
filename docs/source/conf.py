# -*- coding: utf-8 -*-

# ======================================================================================
# Copyright (c) 2019-2020 Christian Riedel
#
# This file 'conf.py' created 2020-01-24 is part of the project/program 'DoTH-DNS'.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the MIT License as published by
# the Massachusetts Institute of Technology.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# MIT License for more details.
#
# You should have received a copy of the MIT License
# along with this program. If not, see <https://opensource.org/licenses/MIT>.
#
# Github: https://github.com/Cielquan/
# ======================================================================================
"""
    docs.source.conf
    ~~~~~~~~~~~~~~~~

    Configuration file for the Sphinx documentation builder.

    :copyright: 2019-2020 (c) Christian Riedel
    :license: MIT, see LICENSE.rst for more details
"""
import os
import sys

from pathlib import Path


# Paths
sys.path.insert(0, os.path.abspath("../.."))
conf_dir = Path(__file__)


# -- PROJECT INFORMATION ---------------------------------------------------------------

project = "DoTH-DNS"
author = "Christian Riedel"
copyright = "2019-2020, Christian Riedel"  #: CHANGEME
# The full version, including alpha/beta/rc tags
release = "5.4.0"  #: CHANGEME
# Major version like (X.Y)
version = "5.4"  #: CHANGEME
# Release date
release_date = "2020"  #: CHANGEME


# -- SPHINX CONFIG ---------------------------------------------------------------------

# Add any Sphinx extension module names here, as strings.
extensions = []

# intersphinx_mapping = {}


# -- FILES -----------------------------------------------------------------------------

# Index source file
master_doc = "index"

# Files to exclude for source of doc
exclude_patterns = []

# Folder for static files, if folder exists
html_static_path = []
if Path(conf_dir, "_static").exists():
    html_static_path = ["_static"]

# Folder for template files, if folder exists
templates_path = []
if Path(conf_dir, "_templates").exists():
    templates_path = ["_templates"]


# -- HTML OUTPUT -----------------------------------------------------------------------

# Add links to *.rst source files on HTML pages
html_show_sourcelink = True

# Pygments syntax highlighting style
pygments_style = "sphinx"

# Use RTD Theme if installed
try:
    import sphinx_rtd_theme
except ImportError:
    html_theme = "alabaster"
else:
    extensions.append("sphinx_rtd_theme")
    html_theme = "sphinx_rtd_theme"

# rst_epilog = """""".format()
