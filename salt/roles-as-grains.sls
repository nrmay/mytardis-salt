{% for role in salt['pillar.get']('roles', []) %}
{% if loop.first %}
roles:
  grains:
    - present
    - value:
{% endif %}
      - {{role}}
{% endfor %}
