postgresql-client:
  postgres_user:
    - present
    - name: {{ pillar['postgres-user'] }}
    - password: {{ pillar['postgres-password'] }}
    - host: {{ pillar['postgres-host'] }}
{% if 'db-server' in grains['roles'] %}
    - runas: postgres
{% endif %}

  postgres_database:
    - present
    - name: {{ pillar['postgres-db'] }}
{% if 'db-server' in grains['roles'] %}
    - runas: postgres
{% endif %}
    - owner: {{ pillar['postgres-user'] }}
    - require:
      - postgres_user.present: {{ pillar['postgres-user'] }}
