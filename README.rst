mytardis-salt
=============

MyTardis server configuration using Saltstack

It can be used as is, or included in a bigger installation.

Configuration of nodes is done via roles.

It sets up a mytardis installation with the components selected via roles.

Available roles:

  - mytardis: basic web application
  - redis: redis server for queues and other uses
  - db-server: postgres server
  - exampledata: prefill the db, currently defunct

Pillars contain the configuration and need to be edited for production use.

In particular the secret key needs to be changed.
