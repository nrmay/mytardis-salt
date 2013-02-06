pillar_roots:
  base:
    - /srv/pillar

base:
  '*':
    - uwsgi
    - networking
#    - utils

  'master-host':
    - nginx
    - mytardis

  'roles:db':
    - match: grain
    - postgresql

