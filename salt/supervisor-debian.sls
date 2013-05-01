{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

supervisor:
  pkg.installed: []

supervisord.conf:
  file.managed:
    - name: /etc/supervisor/supervisord.conf
    - source: salt://templates/supervisord.conf
    - template: jinja
    - require:
        - pkg: supervisor

supervisor-service-restart:
  cmd.run:
    - name: service supervisor restart
    - require:
        - file: /etc/supervisor/supervisord.conf
        - file: {{ mytardis_inst_dir }}/wsgi.py
        - cmd: supervisorctl stop all

supervisorctl stop all:
  cmd.run:
    - require:
        - pkg: supervisor
        - file: supervisord.conf

supervisorctl start all:
  cmd.run:
    - require:
        - cmd: supervisor-service-restart
