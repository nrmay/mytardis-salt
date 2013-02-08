{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

uwsgi:
  pkg.installed:
    - names:
        - uwsgi
        - uwsgi-plugin-python

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
