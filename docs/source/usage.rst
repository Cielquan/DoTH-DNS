.. This file 'usage.rst' created 2020-01-25 is part of the project/program 'DoTH-DNS'.
.. Copyright (c) 2019-2020 Christian Riedel, see LICENSE for more details

.. highlight:: console

.. _usage:

Usage
=====

Quick setup
-----------
Here I show my way of setting the server (RasPi) up via SSH. Your mileage may vary.
Given paths are relative to this repositories root.

1. First see :ref:`installation` and setup your copy on your server

2. Optionally add ``.htpasswd`` file

  To secure your traefik dashboard add a `.htpasswd`__ file to 'traefik-docker/shared/'
  containing a user-password-string following htpasswd standard. This is optional. ::

    $ htpasswd -c traefik-docker/shared/.htpasswd <YOUR USERNAME>

3. Run the start_doth_dns.bash script

  Call the start_doth_dns.bash script.
  Depending on the settings of your server you may need to start the script with sudo
  because for docker root privileges are needed. For supported options for the script see :ref:`api`. ::

    $ ./start_doth_dns.bash

4. Secure your pihole dashboard

  If you have not set the WEBPASSWORD environment variable you should now set a secure password
  for your pihole dashboard (or deactivate it). The script also reminds you if a random password
  was generated from pihole. ::

    $ docker exec pihole -a -p <PASSWORD>

5. Use the new DNS server

  Now you can setup your other devices to use the new DNS server. You should also install your
  CA certificate on your other devices, if you use self signed certificates.


Menu script
-----------
Instead of calling the setup script directly you can use the menu script as a wrapper.
This requires whiptail to be installed. ::

  $ ./menu_start_doth_dns.bash

But the menu only provides very basic options:

* Starting DoTH-DNS
* Restarting DoTH-DNS
* Updating DoTH-DNS
* Shutting down DoTH-DNS


Configuration
-------------
Configuration is guessed by the script automatically. Alternatively you can set options when
running the script. You can also set them in a '.env' file or the shell environment.
When setting them in the shell environment add ``DOTH_`` before the actual variable.
Else the .env file will overwrite them or if not set in .env file take the .env file as source.
You can set the following Variables:

* ARCHITECTURE
* INTERFACE
* HOST_IP
* HOST_NAME
* TIMEZONE
* DOMAIN

.. highlight:: default

__ https://en.wikipedia.org/wiki/.htpasswd
