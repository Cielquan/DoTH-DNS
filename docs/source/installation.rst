.. This file 'installation.rst' created 2020-01-25 is part of the project/program 'DoTH-DNS'.
.. Copyright (c) 2019-2020 Christian Riedel, see LICENSE for more details

.. highlight:: console

.. _installation:

Installation
============

Prerequisites
-------------
Your machine needs to match the following conditions:

* Have a static IP
* Have python >= 3.6 + pip and docker installed
* Have valid SSL certificate (cert.crt) and matching key (key.key)


Installation from PyPI
----------------------
DoTH-DNS is published on PyPI so you can simply install it with ::

    $ pip install doth-dns

But it is recommended to install it in a virtual environment.


Installation from source
------------------------
DoTH-DNS can be install directly from a clone of the `Git repository`__. You can either
clone the repo and install the local clone::

   $ git clone https://github.com/Cielquan/DoTH-DNS.git
   $ cd DoTH-DNS
   $ pip install .

or install it directly via :command:`git`::

   $ pip install git+https://github.com/Cielquan/DoTH-DNS.git

You can also grab the repo in either `tar.gz`__ or `zip`__ format.
After downloading and extracting you can install it with :command:`pip` like above.


.. highlight:: default


__ https://github.com/Cielquan/DoTH-DNS
__ https://github.com/Cielquan/DoTH-DNS/archive/master.tar.gz
__ https://github.com/Cielquan/DoTH-DNS/archive/master.zip
