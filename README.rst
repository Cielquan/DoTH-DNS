DoTH-DNS
========

**Your server doth DNS the safe way if you use DoTH-DNS.**

| |license| |black|
|
| |travis|
| |docs|
|
| |py_versions| |implementations|
| |pypi| |status| |format| |wheel| |downloads|
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

.. |black| image:: https://img.shields.io/badge/code%20style-black-000000.svg?style=for-the-badge
    :alt: Code Style: Black
    :target: https://github.com/psf/black


.. tests block
.. |travis| image:: https://img.shields.io/travis/com/Cielquan/DoTH-DNS/master.svg?style=for-the-badge&logo=travis-ci&logoColor=FBE072
    :alt: Travis - Build Status
    :target: https://travis-ci.com/Cielquan/DoTH-DNS

.. |docs| image:: https://img.shields.io/readthedocs/doth-dns/latest.svg?style=for-the-badge&logo=read-the-docs&logoColor=white
    :alt: Read the Docs (latest) - Status
    :target: https://doth-dns.readthedocs.io/en/latest/?badge=latest


.. PyPI block
.. |py_versions| image:: https://img.shields.io/pypi/pyversions/doth-dns.svg?style=for-the-badge&logo=python&logoColor=FBE072
    :alt: PyPI - Python versions supported
    :target: https://pypi.org/project/doth-dns/

.. |implementations| image:: https://img.shields.io/pypi/implementation/doth-dns.svg?style=for-the-badge&logo=python&logoColor=FBE072
    :alt: PyPI - Implementations supported
    :target: https://pypi.org/project/doth-dns/

.. |pypi| image:: https://img.shields.io/pypi/v/doth-dns.svg?style=for-the-badge&logo=pypi&logoColor=FBE072
    :alt: PyPI - Package latest release
    :target: https://pypi.org/project/doth-dns/

.. |status| image:: https://img.shields.io/pypi/status/doth-dns.svg?style=for-the-badge&logo=pypi&logoColor=FBE072
    :alt: PyPI - Package stability
    :target: https://pypi.org/project/doth-dns/

.. |format| image:: https://img.shields.io/pypi/format/doth-dns.svg?style=for-the-badge&logo=pypi&logoColor=FBE072
    :alt: PyPI - Format
    :target: https://pypi.org/project/doth-dns/

.. |wheel| image:: https://img.shields.io/pypi/wheel/doth-dns.svg?style=for-the-badge&logo=pypi&logoColor=FBE072
    :alt: PyPI - Wheel
    :target: https://pypi.org/project/doth-dns/

.. |downloads| image:: https://img.shields.io/pypi/dm/doth-dns.svg?style=for-the-badge&logo=pypi&logoColor=FBE072
    :target: https://pypi.org/project/doth-dns/
    :alt: PyPI - Monthly downloads


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
