.. This file 'usage.rst' created 2020-01-25 is part of the project/program 'DoTH-DNS'.
.. Copyright (c) 2019-2020 Christian Riedel, see LICENSE for more details

.. highlight:: console

.. _usage:

Usage
=====


Very Quick setup
----------------
DoTH-DNS can be setup very quick by just running one command ::

        $ dothdns run

How ever it is not recommended. Because the important encryption part will not work properly.
Better is to take some time and configure your local copy a bit.


Quick Setup
-----------
A quick but secure setup.

1. Initialize config directory

  Create a local copy of the configuration files. The directory will be created in your home directory. ::

    $ dothdns config

2. Add TLS certificate

  To use proper encryption you need to add a certificate and corresponding key to '~/DoTH-DNS/certificates/'.
  The certificate needs to be named ``cert.crt`` and the key ``key.key`` unless you modify the configs.

  Alternatively you can setup `Let's Encrypt`_ with traefik.

3. Add ``.htpasswd`` file [optional/recommended]

  To secure your traefik dashboard add a `.htpasswd`_ file to '~/DoTH-DNS/traefik-docker/shared/'
  containing a user-password-string following htpasswd standard. ::

    $ htpasswd -c ~/DoTH-DNS/traefik-docker/shared/.htpasswd <YOUR USERNAME>

4. Start DoTH-DNS

  Now you are ready to start the stack and call ::

    $ dothdns run

5. Secure your pihole dashboard

  If you have not set the WEBPASSWORD environment variable for the pi-hole docker it will generate
  a random password for you which will be shown in the output of ``dothdns run``.
  You should now set a secure password for your pihole dashboard (or deactivate it). ::

    $ docker exec pihole pihole -a -p <PASSWORD>

6. Activate DNSSEC [optional/recommended]

  Now you can log into your pihole dashboard and activate DNSSEC to validate DNS results.
  If DNSSEC runs you can check `here <https://www.cloudflare.com/ssl/encrypted-sni/>`__
  or more verbose `here <https://www.rootcanary.org/test.html>`__.


After setup
-----------
After setting DoTH-DNS up you need to setup your clients to use the new DNS server.
If you use self-signed certificates you should install the root CA certificate on your devices.


Configuration
-------------
Configuration is guessed by DoTH-DNS if not set by the user.
For setting configuration parameters you have three options.
The shown order is also their ranking:

    #. commandline options / flags
    #. environment variables
    #. configuration file (dothdns.ini)

1. Commandline options / flags
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
There are several options and flag you can set when interacting with DoTH-DNS on the commandline.
See :ref:`api` for more information.

2. Environment variables
^^^^^^^^^^^^^^^^^^^^^^^^
The following configuration you can set via EnvVars:

* ``TRAEFIK_AUTH``  [true|false]
* ``TRAEFIK_NETWORK`` <CUSTOM NETWORK>
* ``ARCHITECTURE`` [x86|arm]
* ``HOST_IP``  <IP ADDRESS>
* ``HOST_NAME``  <HOST NAME>
* ``TIMEZONE``  <TZ IN OLSON FORMAT>
* ``DOMAIN``  <CUSTOM DOMAIN>
* ``PROXY``  [true|false]

See :ref:`api` for more information to single options.

3. Configuration file
^^^^^^^^^^^^^^^^^^^^^
You can also write the EnvVars to a 'dothdns.ini' or '.dothdns.ini' file.
The file must be either in your home directory or inside the 'DoTH-DNS' directory.


Additional Configuration
------------------------
You are free to change configuration files in the DoTH-DNS directory. But beware that
this can mess up the whole configuration. To reset the configs you can use the
``dothdns init`` command (see :ref:`api`).


Logging
-------
All containers are logging by default. Pihole's logs are accessible via the dashboard.
For the logs of the other containers call ::

    $ docker logs <CONTAINER>

But there are some handicaps with logging. The DoH-Server only shows Traefik as client
because traefik terminates the TLS connection. Pihole has a similar problem.
It shows the DoH-Server as client for all DNS queries incoming via DoH.


.. highlight:: default


.. _.htpasswd: https://en.wikipedia.org/wiki/.htpasswd
.. _Let's Encrypt: https://letsencrypt.org/
