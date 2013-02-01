mytardis:
  user.present:
    - fullname: My Tardis
    - shell: /bin/bash
    - home: /opt/mytardis

git:
  pkg.installed:
    - names:
    {% if grains['os'] == 'RedHat' %}
      - git
    {% elif grains['os'] == 'Ubuntu' %}
      - git-core
    {% endif %}

mytardis-git:
  git.latest:
    - name: git://github.com/mytardis/mytardis.git
    - rev: "3.0"
    - target: /opt/mytardis/current
    - force: true
    - submodules: true
    - runas: mytardis
    - require:
      - user: mytardis
      - pkg: git

requirements:
  pkg.installed:
    - names:
      - python-dev
#      - libldap2-dev
      - libsasl2-dev
      - libxml2-dev
      - libxslt1-dev
      - libmagickwand4

buildout-cfg:
  file.managed:
    - name: /opt/mytardis/current/buildout-salt.cfg
    - source: salt://templates/buildout-salt.cfg
    - owner: mytardis
    - require:
        - user: mytardis
    - watch:
        - git: mytardis-git

settings.py:
  file.managed:
    - name: /opt/mytardis/current/tardis/settings.py
    - source: salt://templates/settings.py
    - owner: mytardis
    - require:
        - git: mytardis-git
        - user: mytardis

bootstrap:
  file.managed:
    - name: /opt/mytardis/current/bootstrap.sh
    - source: salt://helpers/bootstrap.sh
    - mode: 755
    - owner: mytardis
    - require:
        - user: mytardis
        - git: mytardis-git
    - watch:
        - git: mytardis-git
  cmd.run:
    - name: /opt/mytardis/current/bootstrap.sh > /srv/bootstrap.log 2>&1
    - cwd: /opt/mytardis/current
    - runas: mytardis
    - unless: /opt/mytardis/current/bin/django --version
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
        - cmd.run: postgres_reload_conf