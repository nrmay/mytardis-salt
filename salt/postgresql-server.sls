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
    - name: postgresql
    - require:
      - pkg: postgresql-server
{% if grains['os'] == 'Ubuntu' %}
      - file: postgresql-server
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
  cmd.run:
    - name: service postgresql restart
    - require:
      - file: postgresql-server
{% endif %}

{% if grains['os'] == 'CentOS' or grains['os'] == "RedHat" %}
  cmd.run:
    - name: service postgresql initdb
    - unless: ls /var/lib/pgsql/data/base
    - require_in:
        - service: postgresql-server
{% endif %}

