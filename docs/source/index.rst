.. This file 'index.rst' created 2020-01-24 is part of the project/program 'DoTH-DNS'.
.. Copyright (c) 2019-2020 Christian Riedel, see LICENSE for more details
.. DoTH-DNS documentation master file

====================================
Welcome to DoTH-DNS's documentation!
====================================

**Your server doth DNS the safe way if you use DoTH-DNS.**

.. include:: badges.rst

Utilizes the power of `pi-hole <https://pi-hole.net>`_ and
`unbound <https://www.nlnetlabs.nl/projects/unbound/about>`_
to create a DNS server under your own authority but with the ability to use
DoH (`DNS over HTTPS <https://en.wikipedia.org/wiki/DNS_over_HTTPS>`_) and
DoT (`DNS over TLS <https://en.wikipedia.org/wiki/DNS_over_TLS>`_).


Description
-----------
This project's goal is setup a DNS server inside docker with the option to connect via DoH or DoT.
Therefor pi-hole, unbound, traefik and a `DoH-server <https://github.com/m13253/dns-over-https>`__ are utilized.

You may ask 'Why use DoH or DoT for an local DNS server?'. Good question! I set this up
because firefox needs you to use DoH if you want to use `ESNI
<https://en.wikipedia.org/wiki/Server_Name_Indication>`__. The DoT support was just some lines
of code more so I did it also.

The docker-compose file creates a bridge network and the following containers:
``pi-hole/pi-hole``, ``mvance/unbound``, ``traefik``, ``goofball222/dns-over-https``.

Query forwarding:

* Normal DNS query: port 53 -> pihole -> unbound
* DoT query: port 853 -> traefik -> pihole -> unbound
* DoH query: port 443 -> traefik -> DoH-server -> pihole -> unbound
* pihole dashboard query: port 80/443 -> traefik -> pihole
* traefik dashboard query: port 80/443 -> traefik


Project name origin
-------------------
Firstly the name ``DoTH-DNS`` is a word construct resulting from the ability to
use `DoT` and `DoH` for `DNS` queries.

Secondly `doth` is an `archaic word for third person singular present tense of do
<https://www.lexico.com/definition/doth>`__, which matches the name perfectly well,
because it `does DNS` (see slogan at top).


Acknowledgements
----------------
Thanks to the creators of docker, pi-hole, unbound, traefik and 'dns-over-https' for their awesome software.
Also thanks you to the maintainers of the images.

Thanks to the creator of this `docker-pihole-unbound <https://github.com/chriscrowe/docker-pihole-unbound>`__
project which inspired me.


.. toctree::
   :maxdepth: 2
   :caption: Contents:

   installation
   usage


.. toctree::
   :maxdepth: 2
   :caption: API Reference:

   api


.. toctree::
   :maxdepth: 2
   :caption: Miscellaneous:

   external_help
   changelog
   license
