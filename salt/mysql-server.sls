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
{% if grains['os'] == 'RedHat' %}
/var/run/mysqld:
  file.directory:
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
    - name: mysqld
{% endif %}
    - require:
      - pkg: mysql-server
      - user: mysql-user
{% if grains['os'] == 'RedHat' %}
      - file: /var/run/mysqld
{% endif %}
      
      
# set initial password  
# --------------------
{% if grains['os'] == 'RedHat' %}
mysql-root-pass:
  cmd.run:
    - name: mysqladmin -u {{ pillar['mysql_user'] }} password {{ pillar['mysql_pass'] }}
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
{% if grains['os'] == 'RedHat' %}
      - cmd: mysql-root-pass
{% endif %}
   
# --- end of file --- #