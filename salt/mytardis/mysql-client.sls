mysql_pkgs:
  pkg.installed:
    - names:
      - mysql
      - MySQL-python

mytardis-db-user:
  mysql_user.present:
    - name: {{ pillar['mytardis_db_user'] }}
    - host: '%'
    - password: {{ pillar['mytardis_db_pass'] }}
    - require:
      - pkg: MySQL-python  

mytardis-db-database:
  mysql_database.present:
    - name: {{ pillar['mytardis_db'] }}
    - require:
      - pkg: MySQL-python
      
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

 
