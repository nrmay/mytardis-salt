mytardis:
  'roles:mytardis':
    - match: pillar
    - mytardis
    - gunicorn
    - supervisor
    - postgresql-client

  'roles:master-host':
    - match: pillar
    - nginx

  'roles:db-server':
    - match: pillar
    - postgresql-server

  'roles:exampledata':
    - match: pillar
    - exampledata

  'roles:redis':
    - match: pillar
    - redis
