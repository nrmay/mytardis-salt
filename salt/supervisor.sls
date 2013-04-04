{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

supervisor:
  pkg.installed: []

supervisord.conf:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/supervisor/supervisord.conf
{% else %}
    - name: /etc/supervisord.conf
{% endif %}
    - source: salt://templates/supervisord.conf
    - template: jinja
    - require:
        - pkg: supervisor

{% if grains['os'] == 'Ubuntu' %}
service supervisor restart:
{% else %}
service supervisord restart:
{% endif %}
  cmd.run:
    - require:
{% if grains['os'] == 'Ubuntu' %}
        - file: /etc/supervisor/supervisord.conf
{% else %}
        - file: /etc/supervisord.conf
{% endif %}
        - file: {{ mytardis_inst_dir }}/wsgi.py
