nginx:
  pkg:
    - installed
  service:
    - running
    - required:
        - file: nginx
  file.managed:
    - name: /etc/nginx/sites-available/mytardis.conf
    - source: salt://templates/nginx_site.conf
