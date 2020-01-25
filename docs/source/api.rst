.. This file 'index.rst' created 2020-01-25 is part of the project/program 'DoTH-DNS'.
.. Copyright (c) 2019-2020 Christian Riedel, see LICENSE for more details

.. highlight:: console

.. _api:

API
===

The ``start_doth_dns.bash`` script has the following options and flag you can set when calling.

You can also call the script with the ``-h`` flag for the help page::

  $ ./start_doth_dns.bash -h

Options
-------

* ``-f``:

  If set then old configuration settings saved in ``.env`` file will not be loaded
  and a new ``root.hints`` file will be downloaded.

* ``-F``:

  Set to let the script fallback to next source for configuration variables.
  Order: `flag -> environment -> .env file -> self gather`

* ``-a``:

  Set Architecture of the processor ('arm' or 'x86') used by the server. Needed for
  determining the right docker images. If not set script will determine it.

* ``-c``:

  Set to force ``goofball222/dns-over-https`` docker image to be compiled. If not set
  then the ``ARCHITECTURE`` determines if the image will be compiled
  ('arm' -> yes; 'x86' -> no). Will only be compiled if non existing.

* ``-I``:

  Set the network interface used from the server. Needed for determining the right
  IP address. If not set script will determine it.

* ``-i``:

  Set the IP address used by the server. If not set script will determine it with
  determined oder given ``INTERFACE`` (via e.g. ``-I`` option).

* ``-n``:

  Set hostname of the host machine. If not set script will determine it.

* ``-t``:

  Set timezone the server is in. Used for e.g. daily resets. Format is like 'Europe/London'.
  If not set script will determine it.

* ``-d``:

  Set domain the server is reachable under. If not set created by script: '``HOST_NAME``.dns'.

* ``-N``:

  Set to deactivate ``traefik`` dashboard authorization when ``.htpasswd`` file is given.

* ``-h``:

  Show help page and exit.


Flags
-----

* ``-R``:

  Set to recreate all containers. Containers will load new config files if given.

* ``-U``:

  Set to recreate and update all containers.

* ``-P``:

  Set to start without reverse proxy ``traefik``.

* ``-D``:

  Set to shut DoTH-DNS down. It will remove all DoTH-DNS containers and networks.


.. highlight:: default
