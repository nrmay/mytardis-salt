# ---------------------------
# mysql - mytardis db install
# ---------------------------

# install packages
# ----------------
mysql-pkgs:
  pkg.installed:
    - names:
{% if grains['os_family'] == 'Debian' %}
      - python-mysqldb
{% else %}
      - MySQL-python
  {% if grains['os_family'] == 'RedHat' and grains['osrelease'] < '7' %}
      - mysql
  {% else %}
      - mariadb
  {% endif %}
{% endif %}


# create user
# -----------
mytardis-db-user:
  mysql_user.present:
    - name: {{ pillar['mytardis_db_user'] }}
    - password: {{ pillar['mytardis_db_pass'] }}
    - connection_user: {{ pillar['mysql_user'] }}
    - connection_pass: {{ pillar['mysql_pass'] }}
    - connection_host: {{ pillar['mytardis_db_host'] }}
    - connection_port: {{ pillar['mytardis_db_port'] }}
    - connection_socket: {{ pillar['mysql_socket'] }}
{% if pillar['mytardis_db_host'] == 'localhost' %} 
    - host: 'localhost'
{% else %}
    - host: '%'  
{% endif %}
    - require:
      - pkg: mysql-pkgs
{% if 'mysql-server' in pillar['roles'] %}
      - mysql_user: mysql-root
{% endif %}


# create database
# ---------------
mytardis-db-database:
  mysql_database.present:
    - name: {{ pillar['mytardis_db'] }}
    - connection_user: {{ pillar['mysql_user'] }}
    - connection_pass: {{ pillar['mysql_pass'] }}
    - connection_host: {{ pillar['mytardis_db_host'] }}
    - connection_port: {{ pillar['mytardis_db_port'] }}
    - connection_socket: {{ pillar['mysql_socket'] }}
    - require:
      - pkg: mysql-pkgs    
{% if 'mysql-server' in pillar['roles'] %}
      - mysql_user: mysql-root
{% endif %}
  
      
# create grants
# -------------
mytardis-db-grants:
  mysql_grants.present:
    - grant: all
    - database: {{ pillar['mytardis_db'] }}.*
    - user: {{ pillar['mytardis_db_user'] }}
    - password: {{ pillar['mytardis_db_pass'] }}
{% if pillar['mytardis_db_host'] == 'localhost' %} 
    - host: 'localhost'
{% else %}
    - host: '%'  
{% endif %}
    - connection_user: {{ pillar['mysql_user'] }}
    - connection_pass: {{ pillar['mysql_pass'] }}
    - connection_host: {{ pillar['mytardis_db_host'] }}
    - connection_port: {{ pillar['mytardis_db_port'] }}
    - connection_socket: {{ pillar['mysql_socket'] }}
    - require:
      - mysql_user: {{ pillar['mytardis_db_user'] }}
      - mysql_database: {{ pillar['mytardis_db'] }}  


# --- end of file --- # 
