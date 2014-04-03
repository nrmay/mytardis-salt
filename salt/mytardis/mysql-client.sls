mysql-pkgs:
  pkg.installed:
    - names:
      - mysql
      - MySQL-python
      
mysql-db:
  mysql_database.present:
    - name: mysql
    - connection_user: {{ pillar['mysql_user'] }}
    - connection_pass: {{ pillar['mysql_pass'] }}
    - connection_host: {{ pillar['mytardis_db_host'] }}
    - connection_port: {{ pillar['mytardis_db_port'] }}
    - requires:
      - pkg: mysql-pkgs
{% if pillar['mytardis_db_host'] == 'localhost' %} 
#    - watch:
#      - cmd: mysql-root
{% endif %}
      

mytardis-db-user:
  mysql_user.present:
    - name: {{ pillar['mytardis_db_user'] }}
    - host: '%'
    - password: {{ pillar['mytardis_db_pass'] }}
    - require:
      - pkg: mysql-pkgs

mytardis-db-database:
  mysql_database.present:
    - name: {{ pillar['mytardis_db'] }}
    - require:
      - pkg: mysql-pkgs
      
mytardis-db-grants:
  mysql_grants.present:
    - grant: all
    - database: {{ pillar['mytardis_db'] }}.*
    - user:     {{ pillar['mytardis_db_user'] }}
    - host:     '%'
    - password: {{ pillar['mytardis_db_pass'] }}
    - require:
      - mysql_user: {{ pillar['mytardis_db_user'] }}
      - mysql_database: {{ pillar['mytardis_db'] }}  
