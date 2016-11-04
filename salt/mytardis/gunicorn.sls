{% set mytardis_inst_dir =
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}
{% set socketdir = pillar['socket_dir'] %}

{% if grains['os_family'] == 'Debian' %}
{% set nginx_group = "www-data" %}
{% else %}
{% set nginx_group = "nginx" %}
{% endif %}

{{ socketdir }}:
  file.directory:
    - user: {{ pillar['mytardis_user'] }}
    - group: {{ nginx_group }}
    - mode: 770
    - makedirs: True
    - require_in:
        - cmd: supervisorctl start gunicorn

{% if pillar.get('gunicorn_ssl', False) %}
{% set ca_name = salt['pillar.get']('proxy_ca_name', 'nginx-gunicorn-ca') %}
{% set cert_path = '/etc/pki/' + ca_name + '/' + ca_name + '_ca_cert' %}
# this cert needs to be created manually before using tcp sockets
{{ cert_path }}.crt:
  file.managed:
    - source: salt://certs/{{ca_name}}_ca_cert.crt

{{ cert_path }}.key:
  file.managed:
    - source: salt://certs/{{ca_name}}_ca_cert.key

tls.create_ca_signed_cert:
  module.run:
    - ca_name: '{{ca_name}}'
    - CN: '{{ salt['pillar.get']('nginx_server_name', 'localhost') }}'
    - require:
        - module: tls.create_csr

tls.create_csr:
  module.run:
    - ca_name: '{{ca_name}}'
    - CN: '{{ salt['pillar.get']('nginx_server_name', 'localhost') }}'
    - C: 'AU'
    - ST: 'Victoria'
    - L: 'Melbourne'
    - O: 'MyTardis'
    - emailAddress: '{{ salt['pillar.get']('admin_email_address', 'admin@localhost') }}'
{% endif %}

gunicorn-supervisor:
  file.accumulated:
    - name: supervisord
{% if grains['os_family'] == 'Debian' %}
    - filename: /etc/supervisor/supervisord.conf
{% else %}
    - filename: /etc/supervisord.conf
{% endif %}
    - text:
        - "\n\
[program:gunicorn]\n\
command={{ mytardis_inst_dir}}/bin/gunicorn\n
 -c {{mytardis_inst_dir}}/gunicorn_settings.py\n
 -u {{ pillar['mytardis_user'] }} -g {{ nginx_group }}\n
{% if pillar['gunicorn_tcp_socket'] is sameas false %} -b unix:{{ socketdir }}/socket\n{% endif %}
{% if pillar['gunicorn_tcp_socket'] %}{% for ipaddr in salt['network.ip_addrs']() %} -b {{ ipaddr }}:8000\n{% endfor %}
{% if pillar.get('gunicorn_ssl', False) %} --certfile {{ cert_path }}.crt\n
 --keyfile {{ cert_path }}.key\n{% endif %}{% endif %} wsgi:application\n\
stdout_logfile=/var/log/gunicorn.log\n\
redirect_stderr=true\n\
"
    - require:
        - file: {{ socketdir }}
    - require_in:
        - file: supervisord.conf

supervisorctl start gunicorn:
  cmd.run:
    - require:
      - file: supervisord.conf
      - cmd: supervisor-service-start
