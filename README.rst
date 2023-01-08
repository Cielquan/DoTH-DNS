INFO
====

- This project is **not** actively maintained.
- Therefore it currently still only supports pihole 4. If you wish to have DoTH-DNS support pihole 5 feel free to file a PR.
- You can leave an issue or PR but do not expect fast responses.
- There is an issue with ``alpine linux 1.13`` which breaks the build of the ``doh_server`` container on presumably arm hardware (e.g. Raspberry Pi).
  See `issue #8`__

__ https://github.com/Cielquan/DoTH-DNS/issues/8


DoTH-DNS
========

**Your server doth DNS the safe way if you use DoTH-DNS.**

| |license|
|
| |release| |commits_since|  |last_commit|
| |stars| |forks| |contributors|
|

Utilizes the power of the DNS sinkhole `pi-hole`_ and `unbound`_
to create a DNS server under your own authority but with the ability to connect via
Do53 (default, unencrypted), DoH (`DNS over HTTPS`__) and DoT (`DNS over TLS`__).

__ https://en.wikipedia.org/wiki/DNS_over_HTTPS
__ https://en.wikipedia.org/wiki/DNS_over_TLS
.. _pi-hole: https://pi-hole.net
.. _unbound: https://www.nlnetlabs.nl/projects/unbound/about


Documentation
-------------
Documentation is available at `doth-dns.readthedocs.io <https://doth-dns.readthedocs.io/>`_.


Disclaimer
----------
Use at own risk see the License.rst file for more details.

.. warning::
    This project was created for use in a local network. If you want to use it on a VPS or in
    an cloud environment be sure to properly secure your environment and know what you do.


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


.. .############################### LINKS ###############################

.. BADGES START

.. info block
.. |license| image:: https://img.shields.io/github/license/Cielquan/DoTH-DNS.svg?style=for-the-badge
    :alt: License
    :target: https://github.com/Cielquan/DoTH-DNS/blob/master/LICENSE.rst


.. Github block
.. |release| image:: https://img.shields.io/github/v/release/Cielquan/DoTH-DNS.svg?style=for-the-badge&logo=github
    :alt: Github Latest Release
    :target: https://github.com/Cielquan/DoTH-DNS/releases/latest

.. |commits_since| image:: https://img.shields.io/github/commits-since/Cielquan/DoTH-DNS/latest.svg?style=for-the-badge&logo=github
    :alt: GitHub commits since latest release
    :target: https://github.com/Cielquan/DoTH-DNS/commits/master

.. |last_commit| image:: https://img.shields.io/github/last-commit/Cielquan/DoTH-DNS.svg?style=for-the-badge&logo=github
    :alt: GitHub last commit
    :target: https://github.com/Cielquan/DoTH-DNS/commits/master

.. |stars| image:: https://img.shields.io/github/stars/Cielquan/DoTH-DNS.svg?style=for-the-badge&logo=github
    :alt: Github stars
    :target: https://github.com/Cielquan/DoTH-DNS/stargazers

.. |forks| image:: https://img.shields.io/github/forks/Cielquan/DoTH-DNS.svg?style=for-the-badge&logo=github
    :alt: Github forks
    :target: https://github.com/Cielquan/DoTH-DNS/network/members

.. |contributors| image:: https://img.shields.io/github/contributors/Cielquan/DoTH-DNS.svg?style=for-the-badge&logo=github
    :alt: Github Contributors
    :target: https://github.com/Cielquan/DoTH-DNS/graphs/contributors
