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
    - watch:
      - file: {{ ssldir }}/{{ servername }}.crt
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
{% set osarch = grains['osarch'] %}

ssldir:
  file.directory:
    - name: {{ ssldir }}

M2Crypto:
  pip.installed:
    - name: M2Crypto
{% if grains['os'] == "CentOS" and grains['osrelease'] >= '7' %}
    - env_vars: 
        SWIG_FEATURES: "-cpperraswarn -includeall 
          -D__{{ osarch }}__ -I/usr/include/openssl"
{% endif %}

{{ ssldir }}/{{ servername }}.key:
  x509.private_key_managed:
    - bits: 4096
    - backup: True
    - require:
      - file: ssldir
      - pip: M2Crypto
  file.managed:
    - user: nginx
    - require:
      - user: nginx-user

{{ ssldir }}/{{ servername }}.crt:
  x509.certificate_managed:
    - signing_private_key: {{ ssldir }}/{{ servername }}.key
    - CN: {{ servername }}
    - require:
      - x509: {{ ssldir }}/{{ servername }}.key
  file.managed:
    - user: nginx
    - require:
      - user: nginx-user

{% endif %}
