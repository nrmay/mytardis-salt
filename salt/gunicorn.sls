{% set mytardis_inst_dir =
        pillar['mytardis_base_dir']~"/"~pillar['mytardis_branch'] %}
{% set socketdir = "/var/run/gunicorn/mytardis" %}

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
        - cmd: supervisorctl start all

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
 -b unix:{{ socketdir }}/socket\n
{% if pillar['gunicorn_tcp_socket'] %}{% for ipaddr in salt['network.ip_addrs']() %} -b {{ ipaddr }}:8000\n{% endfor %}{% endif %}
 wsgi:application\n\
stdout_logfile=/var/log/gunicorn.log\n\
redirect_stderr=true\n\
"
    - require:
        - file: {{ socketdir }}
    - require_in:
        - file: supervisord.conf
