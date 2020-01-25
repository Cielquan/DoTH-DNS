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
* Have git, docker and docker-compose installed
* Have valid SSL certificate (cert.crt) and matching key (key.key)


Installation
------------
A true installation is not directly supported yet.

You just need to download the `Git repository`__.
Then put your SSL certificate files
Afterwards you can just call ``start_doth_dns.bash`` script::

   $ git clone https://github.com/Cielquan/DoTH-DNS.git
   $ cd DoTH-DNS
   $ chmod +x start_doth_dns.bash menu_start_doth_dns.bash
   $ ./start_doth_dns.bash


.. highlight:: default

__ https://github.com/Cielquan/DoTH-DNS
