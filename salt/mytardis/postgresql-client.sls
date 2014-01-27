mytardis_db_user:
  postgres_user.present:
    - name: {{ pillar['mytardis_db_user'] }}
    - password: {{ pillar['mytardis_db_pass'] }}
    - require:
        - pkg: postgresql-client

mytardis_db:
  postgres_database.present:
    - name: {{ pillar['mytardis_db'] }}
    - owner: {{ pillar['mytardis_db_user'] }}
    - require:
        - postgres_user: {{ pillar['mytardis_db_user'] }}

postgresql-client:
  pkg.installed:
{% if grains['os_family'] == "Debian" %}
    - name: postgresql-client
{% else %}
    - name: postgresql
{% endif %}
