{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

# create mytardis user under which to run the server
mytardis:
  user.present:
    - fullname: My Tardis
    - shell: /bin/bash
    - home: {{ pillar['mytardis_base_dir'] }}

{{ pillar['mytardis_base_dir'] }}:
  file.directory:
    - mode: 755
    - require:
      - user: mytardis

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
    - runas: mytardis
    - require:
      - user: mytardis
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

{% if grains['os'] == "CentOS disabled" %}
# only available in newest salt version
devtools:
  module.run:
    - name: yumpkg.group_install
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
    - user: mytardis
    - require:
        - user: mytardis
    - watch:
        - git: mytardis-git

# create settings.py
settings.py:
  file.managed:
    - name: {{ mytardis_inst_dir }}/tardis/settings.py
    - source: salt://templates/settings.py
    - user: mytardis
    - require:
        - git: mytardis-git
        - user: mytardis

# run shell script that builds mytardis with buildout and populates the db
bootstrap:
  cmd.run:
    - name: python bootstrap.py -v 1.7.0 -c buildout-salt.cfg
    - cwd: {{ mytardis_inst_dir }}
    - user: mytardis
    - unless: ls {{ mytardis_inst_dir }}/bin/buildout
    - require:
        - file: buildout-cfg
        - git: mytardis-git
        - pkg: requirements

django-sync-migrate:
  cmd.run:
    - name: bin/django syncdb --noinput --migrate
    - cwd: {{ mytardis_inst_dir }}
    - user: mytardis
    - watch:
        - file: settings.py
        - git: mytardis-git
        - cmd: buildout
    - require:
        - postgres_database: mytardis

buildout:
  cmd.run:
    - name: bin/buildout -c buildout-salt.cfg
    - cwd: {{ mytardis_inst_dir }}
    - user: mytardis
    - watch:
        - git: mytardis-git
        - file: buildout-cfg
    - require:
        - cmd: bootstrap

bin/django collectstatic -l --noinput:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: mytardis
    - watch:
        - file: settings.py
        - cmd: buildout


# common uwsgi configuration
{{ mytardis_inst_dir }}/wsgi.py:
  file.managed:
    - user: mytardis
    - source: salt://templates/wsgi.py
    - require: 
        - cmd.run: bootstrap
