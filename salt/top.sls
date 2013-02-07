#pillar_roots:
#  base:
#    - /srv/pillar

base:
  '*':
#    - uwsgi
#    - utils
    - mytardis

  'os:Ubuntu':
    - match: grain
    - uwsgi

  'master-host':
    - nginx

  'roles:db':
    - match: grain
    - postgresql
