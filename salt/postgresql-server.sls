postgresql-server:
  pkg.installed:
    - names:
    {% if grains['os_family'] == "RedHat" %}
      - postgresql-server
    {% elif grains['os_family'] == 'Debian' %}
      - postgresql
    {% endif %}

{% if grains['os_family'] == 'Debian' %}
  file.managed:
    - name: /etc/postgresql/9.1/main/pg_hba.conf
    - source: salt://templates/pg_hba.conf
    - mode: 644
    - template: jinja
    - require:
        - pkg.installed: postgresql
{% endif %}

  service:
    - running
    - name: postgresql
    - require:
        - pkg: postgresql-server
{% if grains['os_family'] == 'Debian' %}
        - file: postgresql-server
{% endif %}
    - require_in:
        - postgres_database: mytardis_db
        - postgres_user: mytardis_db_user

{% if grains['os_family'] == 'Debian' %}
  cmd.run:
    - name: service postgresql restart
    - require:
      - file: postgresql-server
    - require_in:
        - postgres_database: mytardis_db
        - postgres_user: mytardis_db_user
{% endif %}

{% if grains['os_family'] == "RedHat" %}
  cmd.run:
    - name: service postgresql initdb
    - unless: ls /var/lib/pgsql/data/base
    - require_in:
        - service: postgresql-server
{% endif %}
