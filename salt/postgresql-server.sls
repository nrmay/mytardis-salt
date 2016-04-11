postgresql-server:
  pkg.installed:
    - names:
    {% if grains['os_family'] == "RedHat" %}
      - postgresql-server
      - postgresql-contrib
    {% elif grains['os_family'] == 'Debian' %}
      - postgresql
    {% endif %}
    
{% if grains['os_family'] == "RedHat" %}
postgresql-initdb:
  cmd.run:
{% if grains['osrelease'] < "7" %}
    - name: service postgresql initdb
{% else %}
    - name: postgresql-setup initdb
{% endif %}
    - unless: ls /var/lib/pgsql/data/base
    - require_in:
        - service: postgresql-service
{% endif %}
       
postgresql-service:
  service:
    - running
    - name: postgresql
    - require:
        - pkg: postgresql-server
    - require_in:
        - postgres_database: mytardis_db
        - postgres_user: mytardis_db_user

postgresql-conf:
  file.managed:
{% if grains['os_family'] == 'Debian' %}
    - name: /etc/postgresql/9.1/main/pg_hba.conf
{% else %}
    - name: /var/lib/pgsql/data/pg_hba.conf
{% endif %}
    - source: salt://templates/pg_hba.conf
    - mode: 644
    - template: jinja
    - require:
        - service: postgresql-service

postgresql-restart:
  cmd.run:
    - name: service postgresql restart
    - require:
      - file: postgresql-conf
    - require_in:
        - postgres_database: mytardis_db
        - postgres_user: mytardis_db_user
