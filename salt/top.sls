base:
  '*':
    - mytardis

  'os:Ubuntu':
    - match: grain
    - uwsgi-ubuntu

  'os:CentOS':
    - match: grain
    - uwsgi-centos

  'master-host':
    - nginx

  'roles:db':
    - match: grain
    - postgresql

  'roles:exampledata':
    - match: grain
    - exampledata
