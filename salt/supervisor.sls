supervisor:
  pkg.installed: []

/etc/supervisord.conf:
  file.managed:
    - source: salt://templates/supervisord.conf
    - require:
        - pkg: supervisor

service supervisord restart:
  cmd.run:
    - require:
        - file: /etc/supervisord.conf
        - file: /var/run/uwsgi/app/mytardis/socket
        - file: {{ mytardis_inst_dir }}/wsgi.py
