{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

download-example-files:
  cmd.run:
    - name: wget https://dl.dropbox.com/u/172498/code/store.tar.gz
    - unless: ls store.tar.gz
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - cmd: buildout

tar -xvzf store.tar.gz -C var/store:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - cmd: download-example-files


download-example-data:
  cmd.run:
    - name: wget https://dl.dropbox.com/u/172498/code/exampledata.json
    - unless: ls exampledata.json
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - cmd: buildout


bin/django loaddata exampledata.json:
  cmd.run:
    - cwd: {{ mytardis_inst_dir }}
    - user: {{ pillar['mytardis_user'] }}
    - require:
        - cmd: download-example-data
        - cmd: django-sync-migrate
