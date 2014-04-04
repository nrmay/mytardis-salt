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
      - mysql
      - MySQL-python
{% endif %}


# create user
# -----------
mytardis-db-user:
  mysql_user.present:
    - name: {{ pillar['mytardis_db_user'] }}
    - password: {{ pillar['mytardis_db_pass'] }}
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
    - require:
      - pkg: mysql-pkgs
      
      
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
    - require:
      - mysql_user: {{ pillar['mytardis_db_user'] }}
      - mysql_database: {{ pillar['mytardis_db'] }}  


# --- end of file --- # 
