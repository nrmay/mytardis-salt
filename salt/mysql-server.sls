mysql:
  pkg:
    - installed
    - name: mysql-server
    - service:
      - running
 
mysql-settings:
  file.append:
    - name: /etc/salt/minion
    - text: "mysql.default_file: /etc/mysql/debian.cnf"

mysql_pkgs:
  pkg.installed:
    - names:
      - mysql
      - MySQL-python
      