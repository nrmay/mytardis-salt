mysql-server-pkgs:
  pkg.installed:
    - names: 
      - mysql
      - MySQL-python
      - mysql-server

mysqld:
  service.running:
    - require:
      - pkg: mysql-server
            
mysql-root:
  cmd.run:
    - name: /usr/bin/mysqladmin -u {{ pillar['mysql_user'] }} password '{{ pillar['mysql_pass'] }}'
    - require:
      - service: mysqld
   
     