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
{% if pillar.get('mytardis_uid', False) %}
    - uid: {{ pillar['mytardis_uid'] }}
{% endif %}
{% if pillar.get('mytardis_gid', False) %}
    - gid: {{ pillar['mytardis_gid'] }}
{% endif %}
    - require:
        - group: mytardis-group

mytardis-group:
  group.present:
    - name: {{ pillar['mytardis_group'] }}
{% if pillar.get('mytardis_gid', False) %}
    - gid: {{ pillar['mytardis_gid'] }}
{% endif %}

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

set_git_email:
  git.config_set:
    - name: user.email
    - value: "mytardis@mytardis.org"
    - user: {{ pillar['mytardis_user'] }}
    - global: True
    - require:
      - user: mytardis-user
      - file: {{ pillar['mytardis_base_dir'] }}
      - pkg: {{ pillar['git'] }}

set_git_user_name:
  git.config_set:
    - name: user.name
    - value: "mytardis"
    - user: {{ pillar['mytardis_user'] }}
    - global: True
    - require:
      - user: mytardis-user
      - file: {{ pillar['mytardis_base_dir'] }}
      - pkg: {{ pillar['git'] }}

git reset --hard HEAD:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - onlyif: ls .git
    - require:
      - file: mytardis-git

mytardis-git:
  file.directory:
    - name: {{ mytardis_inst_dir }}
    - mode: 755
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - file: {{ pillar['mytardis_base_dir'] }}
      - user: mytardis-user

  git.latest:
    - name: "{{ pillar['mytardis_repo'] }}"
    - rev: {{ pillar.get('mytardis_branch', 'master') }}
    - target: {{ mytardis_inst_dir }}
    - force_clone: true
    - force_checkout: true
    - submodules: true
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - git: set_git_email
      - git: set_git_user_name
      - cmd: git reset --hard HEAD

force-branch-update:
  cmd.run:
{% if pillar.get('mytardis_branch', 'master') != "develop" %}
{% set other_branch = "develop" %}
{% else %}
{% set other_branch = "master" %}
{% endif %}
    - name: git checkout {{ other_branch }} && git branch -D {{ pillar.get('mytardis_branch', 'master') }} ; git fetch && git checkout -f {{ pillar.get('mytardis_branch', 'master') }}
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - git: mytardis-git

{% if grains['os_family'] == "RedHat" %}
# only available in newest salt version
devtools:
  module.run:
    - name: pkg.group_install
    - m_name: 'Development Tools'
{% endif %}

locations-fixture:
  file.managed:
    - name: {{ mytardis_inst_dir }}/tardis/tardis_portal/fixtures/locations.json
    - source: salt://mytardis/templates/locations.json
    - template: jinja
    - context:
        default_fs_path: {{ mytardis_inst_dir }}/var/store
        default_st_path: {{ mytardis_inst_dir }}/var/staging
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - cmd: force-branch-update

# create settings.py
settings.py:
  file.managed:
    - name: {{ mytardis_inst_dir }}/tardis/settings.py
    - source: salt://mytardis/templates/settings.py
    - template: jinja
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - user: mytardis-user
        - cmd: force-branch-update

# ------------------
# install mytardis
#
{% if pillar.get('mytardis_buildout', True) == False %}
# use pre-built version
pip-pkgs:
  pkg.latest:
    - pkgs:
      - python-devel
      - python-pip
      - python-virtualenv
{% if grains['os_family'] == 'RedHat' %}
      - openldap-devel
      - libxml2-devel
      - libxslt-devel
      - ImageMagick
      - ImageMagick-devel
      - libffi-devel
      - xmlsec1
{% endif %}
    - require:
      - module: devtools

myvirtenv:
  virtualenv.managed:
    - name:  {{ mytardis_inst_dir }}
    - cwd:   {{ mytardis_inst_dir }}
    - user:  {{ pillar['mytardis_user'] }}
    - system_site_packages: True
    - require:
      - cmd: force-branch-update
      - pkg: pip-pkgs

myvirtenv_activate:
  cmd.run: 
    - name: source {{ mytardis_inst_dir }}/bin/activate
    - require:
      - virtualenv: myvirtenv

pip-upgrade:
  cmd.run:
    - name:    {{ mytardis_inst_dir }}/bin/pip install -U pip
    - cwd:     {{ mytardis_inst_dir }}
    - bin_env: {{ mytardis_inst_dir }}
    - require:
      - cmd: myvirtenv_activate

django-version:
  file.replace:
    - name:    '{{ mytardis_inst_dir }}/requirements.txt'
    - pattern: 'Django\>=1.8,\<1.9'
    - repl:    'Django==1.8.5'
    - backup:  False
    - require:
      - virtualenv: myvirtenv

requirements.txt:
  pip.installed:
    - user:    {{ pillar['mytardis_user'] }}
    - bin_env: {{ mytardis_inst_dir }}
    - cwd:     {{ mytardis_inst_dir }}
    - requirements: '{{ mytardis_inst_dir }}/requirements.txt'
    - upgrade:  False
    - no_chown: True
    - require:
      - file: django-version
      - cmd: pip-upgrade

{% if grains['os_family'] == 'RedHat' %}
requirements-centos.txt:
  pip.installed:
    - user:    {{ pillar['mytardis_user'] }}
    - bin_env: {{ mytardis_inst_dir }}
    - cwd:     {{ mytardis_inst_dir }}
    - requirements: '{{ mytardis_inst_dir }}/requirements-centos.txt'
    - upgrade:  False
    - no_chown: True
    - require:
      - cmd: pip-upgrade
{% endif %}

{{ mytardis_inst_dir }}/tardis/settings.py:
  file.replace:
    - pattern: INSTALLED_APPS \+= \('south',\)
    - repl:    "#INSTALLED_APPS += ('south',)"
    - backup:  False
    - require:
      - file: settings.py

make-migrations:
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py makemigrations
    - cwd:  {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - file: {{ mytardis_inst_dir }}/tardis/settings.py
      - pip:  requirements.txt
      - file: style_settings
{% if grains['os_family'] == 'RedHat' %}
      - pip:  requirements-centos.txt
{% endif %}
{% if 'mysql-client' in pillar['roles'] %}
      - sls: mytardis.mysql-client
{% endif %}
{% if 'mysql-server' in pillar['roles'] %}
      - sls: mysql-server
{% endif %}
{% if 'postgresql-client' in pillar['roles'] %}
      - sls: mytardis.postgresql-client
{% endif %}
{% if 'postgresql-server' in pillar['roles'] %}
      - sls: postgresql-server
{% endif %}

migrate:
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py migrate
    - cwd:  {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - cmd: make-migrations

create-cache:
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py createcachetable default_cache
    - cwd:  {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - cmd: migrate

#load-fixtures:
#  cmd.run:
#    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py loaddata locations.json
#    - cwd:  {{ mytardis_inst_dir }}
#    - user: {{ pillar['mytardis_user'] }}
#    - require:
#        - cmd: migrate
#        - cmd: pip-upgrade
#    - watch:
#        - file: locations-fixture

#update-permissions:
#  cmd.run:
#    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py update_permissions
#    - cwd:  {{ mytardis_inst_dir }}
#    - user: {{ pillar['mytardis_user'] }}
#    - watch:
#        - cmd: migrate
#        - cmd: pip-upgrade
#    - require_in:
#        - file: {{ mytardis_inst_dir }}/wsgi.py

{% if salt['pillar.get']('provide_staticfiles', False) %}
static-files-directory:
  file.directory:
    - name: "{{ salt['pillar.get']('static_file_storage_path') }}"
    - mode: 755
    - makedirs: true
    - user: {{ pillar['mytardis_user'] }}
    - require:
       - user: mytardis-user

collect-static:
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py collectstatic --noinput
    - cwd:  {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - file: settings.py
    - require:
        - file: static-files-directory
        - cmd: pip-upgrade
        - cmd: create-cache
{% if 'nfs-mount' in salt['pillar.get']('roles', []) and '/srv/public_data' in salt['pillar.get']('nfs-servers', []) %}
        - mount: '/srv/public_data'
{% endif %}

{% endif %}

# load licenses
load-licenses:
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py loaddata tardis/tardis_portal/fixtures/cc_licenses.json || true
    - cwd:  {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - cmd: migrate
        - cmd: pip-upgrade

{% else %}
# -----------------------------------
# install packages and run  buildout.
requirements:
  pkg.installed:
    - names:
      - pkg-config
      - libgraphviz-dev
      - libevent-dev
{% if grains['os_family'] == "Debian" %}
      - python-dev
      - libsasl2-dev
      - libxml2-dev
      - libxslt1-dev
      - make
{% if grains['os'] == 'Debian' and grains['osrelease'] <= '6.0.6' %}
      - libmagickwand3
{% elif grains['os'] == 'Ubuntu' and grains['osrelease'] <= '12.04' %}
      - libmagickwand4
{% else %}      
      - libmagickwand5{
{% endif %}
{% if grains['os'] == 'Debian' and grains['osrelease'] <= '6.0.6' %}
      - libpq-dev
{% else %}      
      - postgresql-server-dev-all
{% endif %}
{% endif %}
{% if grains['os_family'] == "RedHat" %}
      - python-devel
      - libgsasl-devel
      - libxml2-devel
      - libxslt-devel
      - ImageMagick
      - postgresql-devel
      - graphviz-devel
{% if grains['os'] == "RedHat" and grains['osrelease'] < '6.5' %}
      - compat-libevent14-devel
{% else %}
      - libevent-devel
{% endif %}
{% endif %}

buildout-cfg:
  file.managed:
    - name: {{ mytardis_inst_dir }}/buildout-salt.cfg
    - source: salt://mytardis/templates/buildout-salt.cfg
    - template: jinja
    - context:
        mytardis_dir: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - user: mytardis-user
        - file: {{ pillar['mytardis_base_dir'] }}
    - watch:
        - cmd: force-branch-update

# run shell script that builds mytardis with buildout and populates the db
bootstrap:
  cmd.run:
    - name: python bootstrap.py -v 1.7.0 -c buildout-salt.cfg
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - unless: ls {{ mytardis_inst_dir }}/bin/buildout
    - require:
        - file: buildout-cfg
        - cmd: force-branch-update
        - pkg: requirements
        - file: {{ pillar['mytardis_base_dir'] }}

django-sync-migrate:
  cmd.run:
    - name: bin/django syncdb --noinput --migrate
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
{% if pillar['mytardis_db_engine'] == 'django.db.backends.mysql' %}
    - connection_user: {{ pillar['mysql_user'] }}
    - connection_pass: {{ pillar['mysql_pass'] }}
    - connection_host: {{ pillar['mytardis_db_host'] }}
    - connection_port: {{ pillar['mytardis_db_port'] }}
{% endif %}    
    - watch:
        - file: settings.py
        - cmd: force-branch-update
        - git: mytardis-git
        - cmd: buildout
    - require:
{% if pillar['mytardis_db_engine'] == 'django.db.backends.mysql' %}
        - mysql_database: {{ pillar['mytardis_db'] }}
        - mysql_grants: mytardis-db-grants
{% else %}
        - postgres_database: {{ pillar['mytardis_db'] }}
{% endif %}

buildout:
  cmd.run:
    - name: bin/buildout -N -c buildout-salt.cfg
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - cmd: force-branch-update
        - git: mytardis-git
        - file: buildout-cfg
        - cmd: bootstrapi
        - module: devtools

load-fixtures:
  cmd.run:
    - name: bin/django loaddata locations.json
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - cmd: django-sync-migrate
    - watch:
        - file: locations-fixture


bin/django update_permissions:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - cmd: django-sync-migrate
    - require_in:
        - file: {{ mytardis_inst_dir }}/wsgi.py

{% if salt['pillar.get']('provide_staticfiles', False) %}
static_files_directory:
  file.directory:
    - name: "{{ salt['pillar.get']('static_file_storage_path') }}"
    - mode: 755
    - makedirs: true
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - user: mytardis-user

bin/django collectstatic --noinput:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - watch:
        - file: settings.py
        - cmd: buildout
    - require:
        - file: static_files_directory
{% if 'nfs-mount' in salt['pillar.get']('roles', []) and '/srv/public_data' in salt['pillar.get']('nfs-servers', []) %}
        - mount: '/srv/public_data'
{% endif %}
{% endif %}

# load licenses
bin/django loaddata tardis/tardis_portal/fixtures/cc_licenses.json || true:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - cmd: buildout

{% endif %}

# end of build process
# ---------------------


# common uwsgi configuration
{{ mytardis_inst_dir }}/wsgi.py:
  file.managed:
    - user: {{ pillar['mytardis_user'] }}
    - source: salt://mytardis/templates/wsgi.py
    - require:
{% if pillar.get('mytardis_buildout', True) == False %}
        - cmd: migrate
{% else %}
        - cmd: buildout
{% endif %}

celery-supervisor:
  file.accumulated:
    - name: supervisord
{% if grains['os_family'] == 'Debian' %}
    - filename: /etc/supervisor/supervisord.conf
{% else %}
    - filename: /etc/supervisord.conf
{% endif %}
    - text:
        - "[program:celeryd]\n\
directory={{ mytardis_inst_dir }}\n\
{% if pillar.get('mytardis_buildout', True) == False %}
command={{ mytardis_inst_dir}}/bin/python mytardis.py celeryd --concurrency 5\n\
{% else %}
command={{ mytardis_inst_dir}}/bin/django celeryd --concurrency 5\n\
{% endif %}
user={{ pillar['mytardis_user'] }}\n\
stdout_logfile={{ mytardis_inst_dir }}/celeryd.log\n\
redirect_stderr=true\n\
\n\
[program:celerybeat]\n\
directory={{ mytardis_inst_dir }}\n\
{% if pillar.get('mytardis_buildout', True) == False %}
command={{ mytardis_inst_dir}}/bin/python mytardis.py celerybeat\n\
{% else %}
command={{ mytardis_inst_dir}}/bin/django celerybeat\n\
{% endif %}
user={{ pillar['mytardis_user'] }}\n\
stdout_logfile={{ mytardis_inst_dir }}/celerybeat.log\n\
redirect_stderr=true\n\
"
    - require:
{% if pillar.get('mytardis_buildout', True) == False %}
        - cmd: migrate
{% else %}
        - cmd: buildout
{% endif %}
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
        - cmd: supervisor-service-start

celerybeat:
  supervisord:
{% if salt['pillar.get']('running_services:celerybeat', true) %}
    - running
{% else %}
    - dead
{% endif %}
    - require:
        - cmd: supervisor-service-start

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

{% if "rsync_store_path" in pillar %}
{{ pillar['rsync_store_path'] }}:
  file.directory:
    - mode: 775
    - user: {{ pillar['mytardis_user'] }}
    - group: {{ pillar['mytardis_group'] }}
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - group: mytardis-group
{% endif %}
