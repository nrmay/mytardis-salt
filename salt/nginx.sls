{% set mytardis_inst_dir =
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

nginx:
  pkg:
    - installed
  service:
    - running

{% if grains['os_family'] == "RedHat" %}
/etc/nginx/nginx.conf:
  file.sed:
    - before: "worker_processes  1"
    - after: "worker_processes  5"
    - backup: '.dist'
    - require:
        - pkg: nginx
    - require_in:
        - cmd: service nginx restart
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
    - require:
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
      mytardis_dir: "{{ mytardis_inst_dir }}"
    - require:
      - pkg.installed: nginx

service nginx restart:
  cmd.run:
    - require:
{% if grains['os_family'] == "Debian" %}
      - file.symlink: /etc/nginx/sites-enabled/mytardis.conf
      - file.absent: /etc/nginx/sites-enabled/default
{% elif grains['os_family'] == "RedHat" %}
      - file: /etc/nginx/conf.d/mytardis.conf
      - file.absent: /etc/nginx/conf.d/default.conf
{% endif %}

# open firewall
{% if grains['os_family'] == "RedHat" %}
lokkit -s http -s https:
  cmd.run: []
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
    - source: salt://templates/pillarfilledfile
    - template: jinja
    - context:
        pillarcontent: sslcert
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
