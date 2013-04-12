{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

python-pip:
  pkg.installed      

supervisor:
  pip.installed:
    - name: supervisor==3.0a12
    - require:
        - pkg: python-pip

/etc/init.d/supervisord:
  file.managed:
    - source: salt://templates/init-d-supervisord
    - mode: 750
    - require:
        - file: /etc/sysconfig/supervisord

/etc/sysconfig/supervisord:
  file.managed:
    - source: salt://templates/sysconfig-supervisord

chkconfig --add supervisord:
  cmd.run:
    - require:
        - pip: supervisor
        - file: /etc/init.d/supervisord

supervisord.conf:
  file.managed:
    - name: /etc/supervisord.conf
    - source: salt://templates/supervisord.conf
    - template: jinja
    - require:
        - pip: supervisor

supervisor-service-restart:
  cmd.run:
    - name: service supervisord restart
    - require:
        - file: /etc/supervisord.conf
        - file: {{ mytardis_inst_dir }}/wsgi.py
        - cmd: supervisorctl stop all

supervisorctl stop all:
  cmd.run:
    - require:
        - pip: supervisor
        - file: supervisord.conf

supervisorctl start all:
  cmd.run:
    - require:
        - cmd: supervisor-service-restart
