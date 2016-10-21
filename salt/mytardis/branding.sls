{% set mytardis_inst_dir = 
                   pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}
{% set static_inst_dir = pillar('static_file_storage_path') %}

{{ mytardis_inst_dir }}/tardis/style_settings.py:
  file.managed:
    - source: salt://mytardis/templates/rmit_style_settings.py
    - user: {{ pillar['mytardis_user'] }}
    - mode: 644    
    - require:
      - user: mytardis-user
      - file: {{ mytardis_inst_dir }}/tardis/  
        
{{ static_inst_dir }}/favicon.ico:
  file.managed:
    - source: salt://salt/mytardis/branding/favicon.ico
    - user: {{ pillar['mytardis_user'] }}
    - mode: 644
    - require:
      - user: mytardis-user
      - file: {{ static_inst_dir }}

{{ static_inst_dir }}/fonts:
  file.directory:
    - user: {{ pillar['mytardis_user'] }}
    - makedirs: True
    - recurse: True
    - mode: 755
    - require:
      - user: mytardis-user
      - file: {{ static_inst_dir }}
     

# --- end of branding.sls --- #