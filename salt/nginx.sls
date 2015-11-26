{% if grains['os_family'] == "RedHat" %}
nginx-user:
  group.present:
    - name: nginx
  user.present:
    - name: nginx
    - gid: nginx
    - system: True
{% endif %}

nginx:
  pkg:
    - installed
  service:
    - running
{% if grains['os_family'] == "RedHat" %}
    - require:
      - user: nginx
{% endif %}
      

{% if grains['os_family'] == "RedHat" %}
/etc/nginx/nginx.conf:
{% if grains['os'] == 'CentOS' and grains['osrelease'] >= '7' %}
  file.managed:
    - source: salt://templates/nginx_base.conf
    - user:   nginx
    - group:  nginx
{% else %}
  file.replace:
    - pattern: "worker_processes  1"
    - repl: "worker_processes  3"
    - backup: '.dist'
{% endif %}
    - require:
        - pkg: nginx
    - require_in:
        - cmd: service nginx reload
{% endif %}

# nginx configuration for mytardis. removes default nginx site
{% if grains['os_family'] == "Debian" %}
/etc/nginx/sites-enabled/default:
  file.absent: []

/etc/nginx/sites-enabled:
  file.directory:
    - require:
        - pkg: nginx

/etc/nginx/sites-enabled/mytardis.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/mytardis.conf
    - watch:
        - file: /etc/nginx/sites-enabled
        - file: /etc/nginx/sites-available/mytardis.conf
{% elif grains['os_family'] == "RedHat" %}
/etc/nginx/conf.d/default.conf:
  file.absent:
    - require:
        - pkg: nginx
{% endif %}

{% if grains['os_family'] == "Debian" %}
/etc/nginx/sites-available/mytardis.conf:
{% elif grains['os_family'] == "RedHat" %}
/etc/nginx/conf.d/mytardis.conf:
{% endif %}
  file.managed:
    - source: salt://templates/nginx_site.conf
    - template: jinja
    - context:
      static_files_dir: "{{ pillar['nginx_static_file_path'] }}"
    - require:
      - pkg: nginx

service nginx reload:
  cmd.run:
    - watch:
{% if grains['os_family'] == "Debian" %}
      - file: /etc/nginx/sites-enabled/mytardis.conf
      - file: /etc/nginx/sites-enabled/default
{% elif grains['os_family'] == "RedHat" %}
      - file: /etc/nginx/conf.d/mytardis.conf
      - file: /etc/nginx/conf.d/default.conf
{% endif %}

# open firewall
{% if grains['os_family'] == "RedHat" %}
open_firewall:
  cmd.run: 
{% if grains['osrelease'] < '7' %}
    - name: lokkit -s http -s https:
{% else %}
    - name: firewall-cmd --zone=public --add-service=http --add-service=https --permanent; firewall-cmd --reload;
{% endif %}
    - onlyif: service status firewalld
{% endif %}

{% if salt['pillar.get']("nginx_ssl", False) %}
{% set ssldir = salt['pillar.get']('nginx_ssl_dir', "/etc/ssl") %}
{% set servername = salt['pillar.get']('nginx_server_name') %}
ssldir:
  file.directory:
    - name: {{ ssldir }}

ssl-cert:
  file.managed:
    - name: {{ ssldir }}/{{ servername }}.crt
    - source: salt://templates/cert-chain.template
    - template: jinja
    - context:
        server_cert: sslcert
        cert_chain: sslcert_chain
    - require:
        - file: ssldir

ssl-key:
  file.managed:
    - name: {{ ssldir }}/{{ servername }}.key
    - source: salt://templates/pillarfilledfile
    - template: jinja
    - context:
        pillarcontent: sslkey
    - require:
        - file: ssldir
{% endif %}
