postgres.db_exists:
  module.run:
    - m_name: {{ pillar['postgres.db'] }}
{% if 'db-server' in grains['roles'] %}
#    - runas: postgres
{% endif %}
#    - owner: {{ pillar['postgres.user'] }}
    - require:
      - postgres_user.present: {{ pillar['postgres.user'] }}

{% if pillar['postgres.host'] == "localhost" %}
{{ pillar['postgres.user'] }}:
  postgres_user:
    - present
    - password: {{ pillar['postgres.pass'] }}
    - host: {{ pillar['postgres.host'] }}
{% if 'db-server' in grains['roles'] %}
    - runas: postgres
{% endif %}
{% endif %}