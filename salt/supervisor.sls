{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

supervisor:
  pkg.installed: []

/etc/supervisord.conf:
  file.managed:
    - source: salt://templates/supervisord.conf
    - template: jinja
    - require:
        - pkg: supervisor

service supervisord restart:
  cmd.run:
    - require:
        - file: /etc/supervisord.conf
        - file: {{ mytardis_inst_dir }}/wsgi.py
