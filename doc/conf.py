# SPDX-FileCopyrightText: 2022 CERN (home.cern)
#
# SPDX-License-Identifier: CC-BY-SA-4.0+

# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.

import os
import sys
sys.path.append(os.path.abspath('../lib/PyFmcTdc'))
sys.path.append(os.path.abspath('../lib'))


# -- Project information -----------------------------------------------------

project = 'FMC-TDC 1ns 5cha'
copyright = u'2022, CERN, documentation released under CC-BY-SA-4.0'
author = 'Federico Vaga <federico.vaga@cern.ch>'

import re

release = os.popen('git describe --tags').read().strip()
version = re.sub('^v', '', release.split('-')[0])

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
#
# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The master toctree document.
master_doc = 'index'

# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = ['sphinx.ext.autodoc',
              'sphinx.ext.todo',
              'sphinx.ext.coverage',
              'sphinx.ext.graphviz',
              'breathe'
]

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = ['build_env', '_build', 'Thumbs.db', '.DS_Store']


# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#
html_theme = 'sphinx_rtd_theme'

# If true, links to the reST sources are added to the pages.
#
html_show_sourcelink = False

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
#
html_show_sphinx = False

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# -- Options for LaTeX output ---------------------------------------------

# Grouping the document tree into LaTeX files. List of tuples
# (source start file, target name, title,
#  author, documentclass [howto, manual, or own class]).
latex_documents = [
    (master_doc,
     'FMCTDC1ns5cha.tex',
     'FMC TDC 1ns 5 Channel Documentation',
     'Federico Vaga \\textless{}federico.vaga@cern.ch\\textgreater{}\\\\'
     'Adam Wujek \\textless{}dev\_public@wujek.eu\\textgreater{}'
     ,
     'manual'),
]

latex_elements = {
    'passoptionstopackages': r'\PassOptionsToPackage{table}{xcolor}',
    'preamble' : r'\definecolor{RoyalPurple}{cmyk}{1, 0.50, 0, 0}',
}


breathe_projects = {
    "fmctdc-lib":"doxygen-lib-output/xml/",
}

breathe_projects_source = {
     "fmctdc-lib" : ( "../software/lib/", ["fmctdc-lib.h",
                                           "fmctdc-lib.c",
                                           "fmctdc-lib-math.c"
                                           ])
}

breathe_default_project = "fmctdc-lib"

# Will be appended to every rst source file in order to provide a reference to the latest version
rst_epilog = '.. |latest_release| replace:: %s' % version
