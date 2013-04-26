{% set mytardis_inst_dir = 
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}

nginx:
  pkg:
    - installed
  service:
    - running

# nginx configuration for mytardis. removes default nginx site
{% if grains['os'] == "Ubuntu" %}
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
{% elif grains['os'] == "CentOS" or grains['os'] == "RedHat" %}
/etc/nginx/conf.d/default.conf:
  file.absent:
    - require:
        - pkg: nginx
{% endif %}

{% if grains['os'] == "Ubuntu" %}
/etc/nginx/sites-available/mytardis.conf:
{% elif grains['os'] == "CentOS" or grains['os'] == "RedHat" %}
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
{% if grains['os'] == "Ubuntu" %}
      - file.symlink: /etc/nginx/sites-enabled/mytardis.conf
      - file.absent: /etc/nginx/sites-enabled/default
{% elif grains['os'] == "CentOS" or grains['os'] == "RedHat" %}
      - file: /etc/nginx/conf.d/mytardis.conf
      - file.absent: /etc/nginx/conf.d/default.conf
{% endif %}

# open firewall
{% if grains['os'] == "CentOS" or grains['os'] == "RedHat" %}
lokkit -s http -s https:
  cmd.run: []
{% endif %}

{% if salt['pillar.get']("nginx_ssl", False) %}
{% set ssldir = salt['pillar.get']('nginx_ssl_dir', "/etc/ssl") %}
{% set servername = salt['pillar.get']('nginx_ssl_server_name') %}
ssldir:
  file.directory:
    - name: {{ ssldir }}

ssl-cert:
  file.managed:
    - name: {{ ssldir }}/{{ servername }}.crt
    - source: salt://template/pillarfilledfile
    - context:
        pillarcontent: sslcert
    - require:
        - file: ssldir

ssl-key:
  file.managed:
    - name: {{ ssldir }}/{{ servername }}.key
    - source: salt://template/pillarfilledfile
    - context:
        pillarcontent: sslkey
    - require:
        - file: ssldir
{% endif %}