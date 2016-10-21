{% set mytardis_inst_dir = 
                   pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}
{% set static_inst_dir = pillar('static_file_storage_path') %}

style_settings:
  file.managed:
    - name: {{ mytardis_inst_dir }}/tardis/style_settings.py
    - source: salt://mytardis/branding/rmit_style_settings.py
    - user: {{ pillar['mytardis_user'] }}
    - mode: 644    
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - file: settings.py 
        
{{ static_inst_dir }}/favicon.ico:
  file.managed:
    - source: salt://mytardis/branding/favicon.ico
    - user: {{ pillar['mytardis_user'] }}
    - mode: 644
    - require:
      - user: {{ pillar['mytardis_user'] }}
      - file: {{ static_inst_dir }}  

{{ static_inst_dir }}/fonts:
  file.recurse:
    - source: salt://mytardis/branding/fonts
    - user: {{ pillar['mytardis_user'] }}
    - mkdirs: True
    - dir_mode: 755
    - file_mode: 644
     - require:
      - user: {{ pillar['mytardis_user'] }}
      - file: {{ static_inst_dir }}  


# --- end of branding.sls --- #