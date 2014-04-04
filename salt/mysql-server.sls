# --------------------
# mysql server install
# --------------------

# install packages
# ----------------
mysql-server-pkgs:
  pkg.installed:
    - names: 
{% if grains['os_family'] == 'Debian' %}
    - name: python-mysqldb
{% else %}
    - mysql
    - MySQL-python
{% endif %}
      - mysql-server
      
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
  
# update root password
# --------------------      
mysql-root:
  cmd.run:
    - name: /usr/bin/mysqladmin -u {{ pillar['mysql_user'] }} password '{{ pillar['mysql_pass'] }}'
    - require:
      - service: mysql-service
   
# --- end of file --- #