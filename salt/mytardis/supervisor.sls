{% set mytardis_inst_dir =
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

{% if grains['os_family'] == 'Debian' %}
supervisor:
  pkg.installed: []

supervisord.conf:
  file.managed:
    - name: /etc/supervisor/supervisord.conf
    - source: salt://mytardis/templates/supervisord.conf
    - template: jinja
    - require:
        - pkg: supervisor

supervisor-service-start:
  cmd.run:
    - name: service supervisor start
    - require:
        - cmd: supervisor-service-stop

supervisor-service-stop:
  cmd.run:
    - name: service supervisor stop
    - require:
        - file: /etc/supervisor/supervisord.conf
        - file: {{ mytardis_inst_dir }}/wsgi.py
        - cmd: supervisorctl stop all

supervisorctl stop all:
  cmd.run:
    - require:
        - pkg: supervisor
        - file: supervisord.conf
{% else %}

python-pip:
  pkg.installed

supervisor:
  pip.installed:
    - name: "supervisor>=3.0a12"
    - require:
        - pkg: python-pip

/etc/init.d/supervisord:
  file.managed:
    - source: salt://mytardis/templates/init-d-supervisord
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

supervisor-service-start:
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
        - cmd: supervisor-service-start
{% endif %}
