.. This file 'index.rst' created 2020-01-24 is part of the project/program 'DoTH-DNS'.
.. Copyright (c) 2019-2020 Christian Riedel, see LICENSE for more details
.. DoTH-DNS documentation master file

====================================
Welcome to DoTH-DNS's documentation!
====================================

**Your server doth DNS the safe way if you use DoTH-DNS.**

.. include:: badges.rst

Utilizes the power of the DNS sinkhole `pi-hole`_ and `unbound`_
to create a DNS server under your own authority but with the ability to connect via
Do53 (default, unencrypted), DoH (`DNS over HTTPS`__) and DoT (`DNS over TLS`__).

__ https://en.wikipedia.org/wiki/DNS_over_HTTPS
__ https://en.wikipedia.org/wiki/DNS_over_TLS


Description
-----------
This project's goal is setup a recursive DNS server inside docker with the option to also connect via DoH or DoT.
Therefor `pi-hole`_, `unbound`_, `traefik`__ and a `DoH-server`__ are utilized.

You may ask 'Why use DoH or DoT for an local DNS server?'. Good question! I set this up
because firefox needs you to use DoH if you want to use `ESNI`__. The DoT support was just some lines
of code more so I did it also.

You could also run the stack in a cloud (not tested) and connect there via DoH/DoT.

Query forwarding:

* Do53 query: port 53 -> pihole -> unbound
* DoT query: port 853 -> traefik -> pihole -> unbound
* DoH query: port 443 -> traefik -> DoH-server -> pihole -> unbound

__ https://docs.traefik.io/
__ https://github.com/m13253/dns-over-https
__ https://en.wikipedia.org/wiki/Server_Name_Indication


Project name origin
-------------------
Firstly the name ``DoTH-DNS`` is a word construct resulting from the ability to
use `DoT` and `DoH` for `DNS` queries.

Secondly `doth` is an `archaic word for third person singular present tense of do
<https://www.lexico.com/definition/doth>`__, which matches the name perfectly well,
because it `does DNS` (see slogan at top).


Acknowledgements
----------------

Thanks to the creators, maintainers and developers of the software used in this project.

Special thanks to:

- the `dns-over-https`__ project and its `docker version`__ as a base for my Dockerfile.
- the `docker-pihole-unbound`__ project for the inspiration.
- this `blog post`__ and this `blog post`__ being the first foundation of this project.

__ https://github.com/m13253/dns-over-https
__ https://github.com/goofball222/dns-over-https
__ https://github.com/chriscrowe/docker-pihole-unbound
__ https://www.aaflalo.me/2018/10/tutorial-setup-dns-over-https-server
__ https://www.bentasker.co.uk/documentation/linux/407-building-and-running-your-own-dns-over-https-server


.. _pi-hole: https://pi-hole.net
.. _unbound: https://www.nlnetlabs.nl/projects/unbound/about


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
