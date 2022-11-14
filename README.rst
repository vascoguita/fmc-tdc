.. SPDX-FileCopyrightText: 2022 CERN (home.cern)
..
.. SPDX-License-Identifier: CC-BY-SA-4.0+

FMC TDC 1 ns 5 Channels
=======================

Documentation
-------------
For the documentation we use `Sphinx`_ and `Doxygen`_. You can build
it yourself using ``make`` and specifying the output target. For
example, to build an HTML website you can type the following command
from the project's top directory.

::

    make -C doc html

You will find the documentation in  ``doc/_build/html``.

If the build fails, you are probably missing some required
packages. Have a look at the requirements file
``doc/requirements.txt``. You can install them from your sidtribution
repository or them from `PyPI`_ using the following command.

::

    pip install -r doc/requirements.txt

Remember also to install `Doxygen`_ on your system.

.. _`Sphinx`: https://www.sphinx-doc.org/en/master/
.. _`Doxygen`: https://www.doxygen.nl/index.html
.. _`PyPI`: https://pypi.org/
