# ---------------------
# MyData: app install
# ---------------------
{% set mytardis_inst_dir =
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

mydata-git:
  file.directory:
    - name: {{ mytardis_inst_dir }}/tardis/apps/mydata
    - mode: 755
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - file: {{ pillar['mytardis_base_dir'] }}
      - user: mytardis-user
      - git:  mytardis-git

mydata-latest:
  git.latest:
    - name: "{{ pillar['mydata_repo'] }}"
    - rev: {{ pillar.get('mydata_branch', 'master') }}
    - target: {{ mytardis_inst_dir }}/tardis/apps/mydata
    - force_clone: true
    - force_checkout: true
    - submodules: true
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - git: set_git_email
      - git: set_git_user_name
      - cmd: git reset --hard HEAD

mydata-requirements:
  pip.installed:
    - user:    {{ pillar['mytardis_user'] }}
    - bin_env: {{ mytardis_inst_dir }}
    - cwd:     {{ mytardis_inst_dir }}
    - requirements: '{{ mytardis_inst_dir }}/tardis/apps/mydata/requirements.txt'
    - upgrade:  False
    - no_chown: True
    - require:
      - file: django-version
      - cmd: pip-upgrade
      - git: mydata-latest

mydata-settings:
  file.append:
    - name: {{ mytardis_inst_dir }}/tardis/settings.py
    - text: INSTALLED_APPS += ('tardis.apps.mydata',)
    - require:
      - pip: mydata-requirements 
 
mydata-migrations:
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py migrate mydata
    - cwd:  {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - file: mydata-settings
{% if 'mysql-client' in pillar['roles'] %}
      - sls: mytardis.mysql-client
{% endif %}
{% if 'mysql-server' in pillar['roles'] %}
      - sls: mysql-server
{% endif %}

mydata-schema:
  cmd.run:
    - name: {{ mytardis_inst_dir }}/bin/python mytardis.py loaddata {{ mytardis_inst_dir }}/tardis/apps/mydata/fixtures/default_experiment_schema.json
    - cwd:  {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
      - cmd: mydata-migrations

# ---------------------
# MyData: end of file
# ---------------------
