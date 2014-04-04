# --------------------
# mysql server install
# --------------------

# install packages
# ----------------
mysql-server-pkgs:
  pkg.installed:
    - names: 
      - mysql-server
{% if grains['os_family'] == 'Debian' %}
      - python-mysqldb
{% else %}
      - mysql
      - MySQL-python
{% endif %}

      
# run service
# -----------
mysql-service:
  service.running:
{% if grains['os_family'] == 'Debian' %}
    - name: mysql
{% else %}
    - name: mysqld
{% endif %}
    - require:
      - pkg: mysql-server
   
      
# create user
# -----------
mysql-user:
  mysql_user.present:
    - name: {{ pillar['mysql_user'] }}
    - password: {{ pillar['mysql_pass'] }}
{% if pillar['mytardis_db_host'] == 'localhost' %} 
    - host: 'localhost'
{% else %}
    - host: '%'  
{% endif %}
    - require:
      - service: mysql-service
   
# --- end of file --- #