postgresql-server:
  pkg.installed:
    - names:
    {% if grains['os'] == 'CentOS' or grains['os'] == "RedHat" %}
      - postgresql-server
    {% elif grains['os'] == 'Ubuntu' %}
      - postgresql
    {% endif %}

{% if grains['os'] == 'Ubuntu' %}
  file.patch:
    - name: /etc/postgresql/9.1/main/pg_hba.conf
    - source: salt://patches/pg_hba.conf.patch
    - hash: md5=4d196a766c9695233cf15070a2e1b255
    - require:
        - pkg.installed: postgresql
{% endif %}

  service:
    - running
    - require:
      - pkg: postgresql
{% if grains['os'] == 'Ubuntu' %}
      - file: postgresql
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
  cmd.run:
    - name: service postgresql restart
    - require:
      - file: postgresql
{% endif %}

{% if grains['os'] == 'CentOS' or grains['os'] == "RedHat" %}
  cmd.run:
    - name: service postgresql initdb
    - unless: ls /var/lib/pgsql/data/base
    - require_in:
        - service: postgresql
{% endif %}

  postgres_user:
    - present
    - name: mytardis
    - password: mytardis
    - host: localhost
    - runas: postgres
    - require:
        - service: postgresql
  postgres_database:
    - present
    - name: mytardis
    - runas: postgres
    - owner: mytardis
    - require:
      - postgres_user.present: mytardis
