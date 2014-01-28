mytardis-salt
=============

MyTardis server configuration using Saltstack

It can be used as is, or included in a bigger installation.

Quickstart:

.. code-block::
   :linenos:

  wget -O - http://bootstrap.saltstack.org | sudo sh -s -- git develop
  sudo git clone https://github.com/grischa/mytardis-salt.git /srv
  sudo salt-call --local state.highstate


Pillars contain the configuration and need to be edited for production use.

In particular the secret key needs to be changed.
