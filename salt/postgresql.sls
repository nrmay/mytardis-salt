postgresql:
  pkg.installed:
    - names:
    {% if grains['os'] == 'RedHat' %}
    {% elif grains['os'] == 'Ubuntu' %}
      - postgresql
      - postgresql-server-dev-all
    {% endif %}
  file.patch:
    - name: /etc/postgresql/9.1/main/pg_hba.conf
    - source: salt://patches/pg_hba.conf.patch
    - hash: md5=4d196a766c9695233cf15070a2e1b255
  service:
    - running
    - require:
      - pkg: postgresql
      - file: postgresql

postgres_reload_conf:
  cmd.run:
    - name: service postgresql restart
    - require:
      - file: postgresql

db-user:
  postgres_user:
    - present
    - name: mytardis
    - password: mytardis
#    - host: localhost
    - runas: postgres
    - require:
        - service: postgresql

db:
  postgres_database:
    - present
    - name: mytardis
    - runas: postgres
    - owner: mytardis
    - require:
      - postgres_user.present: mytardis
