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

python-pip-pkg:
  pkg.installed:
    - pkgs:
{% if grains['os_family'] == 'RedHat' and grains['osrelease'] > 7 %}
      - python27-pip
{% else %}
      - python-pip
{% endif %}

supervisor:
  pip.installed:
    - name: "supervisor>=3.0a12"
    - require:
        - pkg: python-pip-pkg
        
supervisor.sock:
  file.managed:
    - name: /var/tmp/supervisor.sock
    - mode: 750

/etc/init.d/supervisord:
  file.managed:
    - source: salt://mytardis/templates/init-d-supervisord
    - mode: 750
    - require:
        - file: /etc/sysconfig/supervisord

/etc/sysconfig/supervisord:
  file.managed:
    - source: salt://mytardis/templates/sysconfig-supervisord

chkconfig --add supervisord:
  cmd.run:
    - require:
        - pip: supervisor
        - file: /etc/init.d/supervisord

supervisord.conf:
  file.managed:
    - name: /etc/supervisord.conf
    - source: salt://mytardis/templates/supervisord.conf
    - template: jinja
    - require:
        - pip: supervisor

supervisor-service-start:
  cmd.run:
    - name: service supervisord restart
    - require:
        - file: /etc/supervisord.conf
        - file: {{ mytardis_inst_dir }}/wsgi.py
        - file: supervisor.sock
        - cmd: supervisorctl stop all
        - cmd: chkconfig --add supervisord

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
