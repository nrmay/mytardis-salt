base:
  '*':
    - mytardis

  'os:Ubuntu':
    - match: grain
    - uwsgi-ubuntu

  'os:CentOS':
    - match: grain
    - uwsgi-centos

  'os:RedHat':
    - match: grain
    - uwsgi-centos

  'roles:master-host':
    - match: grain
    - nginx

  'roles:db':
    - match: grain
    - postgresql

  'roles:exampledata':
    - match: grain
    - exampledata
