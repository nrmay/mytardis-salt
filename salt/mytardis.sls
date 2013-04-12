{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

# create mytardis user under which to run the server
mytardis-user:
  user.present:
    - name: {{ pillar['mytardis_user'] }}
    - shell: /bin/bash
    - home: {{ pillar['mytardis_base_dir'] }}
    - groups:
        - {{ pillar['mytardis_group'] }}
    - require:
        - group: mytardis-group

mytardis-group:
  group.present:
    - name: {{ pillar['mytardis_group'] }}

{{ pillar['mytardis_base_dir'] }}:
  file.directory:
    - mode: 755
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - user: mytardis-user

# install git
{{ pillar['git'] }}:
  pkg:
    - installed

mytardis-git:
  git.latest:
    - name: {{ pillar['mytardis_repo'] }}
    - rev: "{{ pillar['mytardis_branch'] }}"
    - target: 
        {{ mytardis_inst_dir }}
    - force: true
    - submodules: true
    - runas: {{ pillar['mytardis_user'] }}
    - require:
      - user: mytardis-user
      - file.directory: {{ pillar['mytardis_base_dir'] }}
      - pkg: {{ pillar['git'] }}

# install required packages for buildout. This is Ubuntu only at the moment
requirements:
  pkg.installed:
    - names:
{% if grains['os'] == "Ubuntu" %}
      - python-dev
      - libsasl2-dev
      - libxml2-dev
      - libxslt1-dev
{% if grains['osrelease'] == "12.10" %}
      - libmagickwand5
{% else %}
      - libmagickwand4
{% endif %}
      - postgresql-server-dev-all
{% elif grains['os'] == "CentOS" or grains['os'] == "RedHat" %}
      - python-devel
      - libgsasl-devel
      - libxml2-devel
      - libxslt-devel
      - ImageMagick
      - postgresql-devel
{% endif %}

{% if grains['os'] == "CentOS" or grains['os'] == "RedHat" %}
# only available in newest salt version
devtools:
  module.run:
    - name: pkg.group_install
    - m_name: 'Development Tools'
    - require_in:
      - cmd: buildout
{% endif %}

buildout-cfg:
  file.managed:
    - name: {{ mytardis_inst_dir }}/buildout-salt.cfg
    - source: salt://templates/buildout-salt.cfg
    - template: jinja
    - context:
        mytardis_dir: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - user: mytardis-user
        - file.directory: {{ pillar['mytardis_base_dir'] }}
    - watch:
        - git: mytardis-git

# create settings.py
settings.py:
  file.managed:
    - name: {{ mytardis_inst_dir }}/tardis/settings.py
    - source: salt://templates/settings.py
    - template: jinja
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - git: mytardis-git
        - user: mytardis-user

# run shell script that builds mytardis with buildout and populates the db
bootstrap:
  cmd.run:
    - name: python bootstrap.py -v 1.7.0 -c buildout-salt.cfg
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - unless: ls {{ mytardis_inst_dir }}/bin/buildout
    - require:
        - file: buildout-cfg
        - git: mytardis-git
        - pkg: requirements
        - file.directory: {{ pillar['mytardis_base_dir'] }}

django-sync-migrate:
  cmd.run:
    - name: bin/django syncdb --noinput --migrate
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - file: settings.py
        - git: mytardis-git
        - cmd: buildout
    - require:
        - postgres_database: {{ pillar['mytardis_db'] }}

buildout:
  cmd.run:
    - name: bin/buildout -c buildout-salt.cfg
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - git: mytardis-git
        - file: buildout-cfg
        - cmd: bootstrap

bin/django collectstatic -l --noinput:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - file: settings.py
        - cmd: buildout

# common uwsgi configuration
{{ mytardis_inst_dir }}/wsgi.py:
  file.managed:
    - user: {{ pillar['mytardis_user'] }}
    - source: salt://templates/wsgi.py
    - require: 
        - cmd.run: bootstrap

celery-supervisor:
  file.accumulated:
    - name: supervisord
{% if grains['os'] == 'Ubuntu' %}
    - filename: /etc/supervisor/supervisord.conf
{% else %}
    - filename: /etc/supervisord.conf
{% endif %}
    - text: 
        - "[program:celeryd]\n\
directory={{ mytardis_inst_dir }}\n\
command={{ mytardis_inst_dir}}/bin/django celeryd --concurrency 5\n\
user={{ pillar['mytardis_user'] }}\n\
stdout_logfile={{ mytardis_inst_dir }}/celeryd.log\n\
redirect_stderr=true\n\
[program:celerybeat]\n\
directory={{ mytardis_inst_dir }}\n\
command={{ mytardis_inst_dir}}/bin/django celerybeat\n\
user={{ pillar['mytardis_user'] }}\n\
stdout_logfile={{ mytardis_inst_dir }}/celerybeat.log\n\
redirect_stderr=true\n\
"
    - require:
        - cmd: buildout
    - require_in:
        - file: supervisord.conf

celeryd:
  supervisord:
{% if salt['pillar.get']('running_services:celeryd', true) %}
    - running
{% else %}
    - dead
{% endif %}
    - require:
        - cmd: supervisor-service-restart

celerybeat:
  supervisord:
{% if salt['pillar.get']('running_services:celerybeat', true) %}
    - running
{% else %}
    - dead
{% endif %}
    - require:
        - cmd: supervisor-service-restart

# storage paths
{% if "file_store_path" in pillar %}
{{ pillar['file_store_path'] }}:
  file.directory:
    - mode: 775
    - user: {{ pillar['mytardis_user'] }}
    - group: {{ pillar['mytardis_group'] }}
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - group: mytardis-group
{% endif %}

{% if "staging_path" in pillar %}
{{ pillar['staging_path'] }}:
  file.directory:
    - mode: 775
    - user: {{ pillar['mytardis_user'] }}
    - group: {{ pillar['mytardis_group'] }}
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - group: mytardis-group
{% endif %}

{% if "sync_temp_path" in pillar %}
{{ pillar['sync_temp_path'] }}:
  file.directory:
    - mode: 775
    - user: {{ pillar['mytardis_user'] }}
    - group: {{ pillar['mytardis_group'] }}
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - group: mytardis-group
{% endif %}
