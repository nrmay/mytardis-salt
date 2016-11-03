# --------------------
# mysql server install
# --------------------

# install packages
# ----------------
mysql-server-pkgs:
  pkg.installed:
    - names: 
{% if grains['os_family'] == 'Debian' %}
      - mysql-server
      - python-mysqldb
{% else %}
      - MySQL-python
  {% if grains['os'] == 'CentOS' and grains['osrelease'] >= '7' %}
      - mariadb
      - mariadb-server
  {% else %}
      - mysql
      - mysql-server 
  {% endif %}
{% endif %}


# create user
# -----------
mysql-group:
  group.present:
    - name: mysql
  require:
    - pkg: mysql-server-pkgs  
      
mysql-user:
  user.present:
    - name: mysql
    - gid: mysql
    - system: True
  require:
    - group: mysql  


# check folder permissions
# ------------------------
{% if grains['os_family'] == 'RedHat' %}
server_directory:
  file.directory:
{% if grains['osrelease'] < '7' %}
    - name: /var/run/mysqld
{% else %}
    - name: /var/run/mariadb
{% endif %}
    - user: mysql
    - require:
      - user: mysql
{% endif %}
      
      
# run service
# -----------
mysql-service:
  service.running:
{% if grains['os_family'] == 'Debian' %}
    - name: mysql
{% else %}
{% if grains['osrelease'] < '7' %}
    - name: mysqld
{% else %}
    - name: mariadb
{% endif %}
{% endif %}
    - require:
      - pkg: mysql-server-pkgs
      - user: mysql-user
{% if grains['os_family'] == 'RedHat' %}
      - file: server_directory
{% endif %}
      
      
# set initial password  
# --------------------
{% if grains['os_family'] == 'RedHat' %}
mysql-root-pass:
  cmd.run:
    - name: mysqladmin -u {{ pillar['mysql_user'] }} password {{ pillar['mysql_pass'] }}
    - onlyif: mysqladmin -u {{ pillar['mysql_user'] }} flush-privileges
    - require:
      - service: mysql-service
{% endif %}
      
           
# create user
# -----------
mysql-root:
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
{% if grains['os_family'] == 'RedHat' %}
      - cmd: mysql-root-pass
{% endif %}
   
# --- end of file --- #
