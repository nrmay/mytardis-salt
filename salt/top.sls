base:
  'roles:mytardis':
    - match: grain
    - mytardis
    - gunicorn
    - supervisor
    - postgresql-client

  'roles:master-host':
    - match: grain
    - nginx

  'roles:db-server':
    - match: grain
    - postgresql-server

  'roles:exampledata':
    - match: grain
    - exampledata

  'roles:redis':
    - match: grain
    - redis
