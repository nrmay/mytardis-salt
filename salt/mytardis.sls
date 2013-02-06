{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

# create mytardis user under which to run the server
mytardis:
  user.present:
    - fullname: My Tardis
    - shell: /bin/bash
    - home: {{ pillar['mytardis_base_dir'] }}

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
      - python-dev
      - libsasl2-dev
      - libxml2-dev
      - libxslt1-dev
      - libmagickwand4

buildout-cfg:
  file.managed:
    - name: {{ mytardis_inst_dir }}/buildout-salt.cfg
    - source: salt://templates/buildout-salt.cfg
    - template: jinja
    - context:
        mytardis_dir: {{ mytardis_inst_dir }}
    - owner: mytardis
    - require:
        - user: mytardis
    - watch:
        - git: mytardis-git

# create settings.py
settings.py:
  file.managed:
    - name: {{ mytardis_inst_dir }}/tardis/settings.py
    - source: salt://templates/settings.py
    - owner: mytardis
    - require:
        - git: mytardis-git
        - user: mytardis

# run shell script that builds mytardis with buildout and populates the db
bootstrap:
  file.managed:
    - name: {{ mytardis_inst_dir }}/bootstrap.sh
    - source: salt://helpers/bootstrap.sh
    - mode: 755
    - owner: mytardis
    - require:
        - user: mytardis
        - git: mytardis-git
    - watch:
        - git: mytardis-git
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bootstrap.sh > {{ mytardis_inst_dir }}/bootstrap.log 2>&1
    - cwd: {{ mytardis_inst_dir }}
    - user: mytardis
    - unless: {{ mytardis_inst_dir }}/bin/django --version
    - watch:
      - git: mytardis-git
      - file: buildout-cfg
      - file: bootstrap
    - stateful: true
    - require:
        - file: buildout-cfg
        - file: bootstrap
        - file: settings.py
        - git: mytardis-git
        - pkg: requirements
        - postgres_database.present: mytardis
        - cmd.run: postgresql

# nginx configuration for mytardis. removes default nginx site
/etc/nginx/sites-enabled/default:
  file.absent: []

/etc/nginx/sites-available/mytardis.conf:
  file.managed:
    - source: salt://templates/nginx_site.conf
    - template: jinja
    - context: 
      mytardis_dir: "{{ mytardis_inst_dir }}"
    - require:
      - pkg.installed: nginx

/etc/nginx/sites-enabled/mytardis.conf:
  cmd.run:
    - name: service nginx restart
    - require:
      - file.symlink: /etc/nginx/sites-available/mytardis.conf
      - file.absent: /etc/nginx/sites-enabled/default
  file.symlink:
    - target: /etc/nginx/sites-available/mytardis.conf

# uwsgi configuration
{{ mytardis_inst_dir }}/wsgi.py:
  file.managed:
    - owner: mytardis
    - source: salt://templates/wsgi.py
    - require: 
        - cmd.run: bootstrap

/etc/uwsgi/apps-available/mytardis.xml:
  file.symlink:
    - target: {{ mytardis_inst_dir }}/parts/uwsgi/uwsgi.xml
    - require:
        - file.managed: {{ mytardis_inst_dir }}/wsgi.py
        - pkg.installed: uwsgi

/etc/uwsgi/apps-enabled/mytardis.xml:
  file.symlink:
    - target: /etc/uwsgi/apps-available/mytardis.xml
    - require:
        - file: /etc/uwsgi/apps-available/mytardis.xml

service uwsgi restart:
  cmd.run:
    - require:
        - file: /etc/uwsgi/apps-enabled/mytardis.xml

# fix for buggy Ubuntu 12.04 uwsgi
/usr/bin/uwsgi:
  file.rename: # managed files only work with off-client sources
    - source: {{ mytardis_inst_dir }}/bin/uwsgi
    - force: True
    - require:
        - cmd.run: service uwsgi stop
        - cmd.run: bootstrap

service uwsgi start:
  cmd.run:
    - require:
        - file.managed: /usr/bin/uwsgi

service uwsgi stop:
  cmd.run:
    - require:
        - cmd.run: service uwsgi restart
# end fix