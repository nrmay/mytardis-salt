{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

/var/run/uwsgi/app/mytardis/socket:
  file.touch:
    - user: {{ pillar['mytardis_user'] }}
    - group: nginx
    - mode: 660
    - makedirs: True

/etc/supervisord.conf:
  file.append:
    - text: |
      [program:uwsgi]
      command={{ mytardis_inst_dir}}/bin/uwsgi
      --xml {{ mytardis_inst_dir}}/parts/uwsgi/uwsgi.xml
      ;          --logto {{ mytardis_inst_dir }}/uwsgi.log
      ; supervisor version <3 needs stdout, cannot let uwsgi do the logging
      logfile=/var/log/supervisor/uwsgi.log
      log_stdout=true
      log_stderr=true
    - require:
        - file.managed: /etc/supervisord.conf
        - file.touch: /var/run/uwsgi/app/mytardis/socket
    - require_in:
        - cmd.run: service supervisord restart



