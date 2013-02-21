{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

supervisor:
  pkg.installed: []

/var/run/uwsgi/app/mytardis/socket:
  file.touch:
    - user: {{ pillar['mytardis_user'] }}
    - group: nginx
    - mode: 660
    - makedirs: True

/etc/supervisord.conf:
  file.managed:
    - source: salt://templates/supervisord.conf
    - template: jinja
    - context:
        mytardis_dir: {{ mytardis_inst_dir }}
    - require:
        - pkg: supervisor

service supervisord restart:
  cmd.run:
    - require:
        - file: /etc/supervisord.conf
        - file: /var/run/uwsgi/app/mytardis/socket
        - file: {{ mytardis_inst_dir }}/wsgi.py

