{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

/var/run/uwsgi/app/mytardis/socket:
  file.touch:
    - user: {{ pillar['mytardis_user'] }}
    - group: nginx
    - mode: 660
    - makedirs: True
    - require_in:
        - cmd: supervisorctl start all

uwsgi-supervisor:
  file.accumulated:
    - name: supervisord
    - filename: /etc/supervisord.conf
    - text:
        - "[program:uwsgi]"
        - command={{ mytardis_inst_dir}}/bin/uwsgi
        - "    --xml {{ mytardis_inst_dir}}/parts/uwsgi/uwsgi.xml"
        - ;          --logto {{ mytardis_inst_dir }}/uwsgi.log
        - ; supervisor version <3 needs stdout, cannot let uwsgi do the logging
        - stdout_logfile=/var/log/uwsgi.log
        - redirect_stderr=true
    - require:
        - file.touch: /var/run/uwsgi/app/mytardis/socket
    - require_in:
        - file: supervisord.conf



