{% for role in salt['pillar.get']('roles', []) %}
{% if loop.first %}
roles:
  grains:
    - present
    - force: True
    - value:
{% endif %}
      - {{role}}
{% endfor %}
