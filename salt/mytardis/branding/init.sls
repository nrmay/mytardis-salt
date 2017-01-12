{% set mytardis_inst_dir = 
                   pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}
{% set static_inst_dir = pillar['static_file_storage_path'] %}

style_settings:
  file.managed:
    - name: {{ mytardis_inst_dir }}/tardis/style_settings.py
    - source: salt://mytardis/branding/rmit_style_settings.py
    - user: {{ pillar['mytardis_user'] }}
    - mode: 640    
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - file: settings.py 

{{ mytardis_inst_dir }}/tardis/groups.py:
  file.managed:
    - source: salt://mytardis/branding/groups.py
    - user: {{ pillar['mytardis_user'] }}
    - mkdirs: True
    - mode: 640    
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - file: settings.py 

{{ static_inst_dir }}/favicon.ico:
  file.managed:
    - source: salt://mytardis/branding/favicon.ico
    - user: nginx
    - mode: 640
    - require:
      - user: nginx
      - file: {{ static_inst_dir }}  

{{ static_inst_dir }}/fonts:
  file.recurse:
    - source: salt://mytardis/branding/fonts
    - user: nginx
    - mkdirs: True
    - dir_mode: 750
    - file_mode: 640
    - require:
      - user: nginx
      - file: {{ static_inst_dir }}

# --- end of branding.sls --- #