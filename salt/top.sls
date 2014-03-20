# alphabetially sorted role configuration
base:
  '*':
    - roles-as-grains
    - minion-config

  'roles:master-host':
    - match: pillar
    - nginx

  'roles:mytardis':
    - match: pillar
    - mytardis
    - mytardis.gunicorn
    - mytardis.supervisor
    
  'roles:mysql-client':
    - match: pillar
    - mytardis.mysql-client
    
  'roles:postgresql-client':
    - match: pillar
    - mytardis.postgresql-client

  'roles:nfs-client':
    - match: pillar
    - nfs-client

  'roles:nfs-mount':
    - match: pillar
    - nfs-mount

  'roles:nfs-server':
    - match: pillar
    - nfs-server

  'roles:rabbitmq':
    - match: pillar
    - rabbitmq

  'roles:db-server':
    - match: pillar
    - postgresql-server
