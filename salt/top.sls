base:
  '*':
    - mytardis

  'os_family:Debian':
    - match: grain
    - uwsgi-debian
    - supervisor-debian

  'os_family:RedHat':
    - match: grain
    - uwsgi-centos
    - supervisor-centos

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

  'roles:redis':
    - match: grain
    - redis
