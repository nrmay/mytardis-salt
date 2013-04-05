base:
  '*':
    - mytardis

  'os:Ubuntu':
    - match: grain
    - uwsgi-ubuntu
    - supervisor-ubuntu

  'os:CentOS':
    - match: grain
    - uwsgi-centos
    - supervisor-centos

  'os:RedHat':
    - match: grain
    - uwsgi-centos

  'roles:master-host':
    - match: grain
    - nginx

  'roles:db-server':
    - match: grain
    - postgresql-server

  'roles:db-client':
    - match: grain
    - postgresql-client

  'roles:exampledata':
    - match: grain
    - exampledata
