# installs redis from source

{% set redis_inst_dir = "/opt/redis" %}
{% set redis_port = "6379" %}
{% set redis_data_dir = "/var/lib/redis/"~redis_port %}
{% set redis_user_group = "redis" %}

{{ redis_user_group }}:
  group:
    - present
  user.present:
    - home: {{ redis_inst_dir }}
    - gid_from_name: True
    - require:
      - group: {{ redis_user_group }}

{{ redis_inst_dir }}:
  file.directory:
    - user: {{ redis_user_group }}
    - group: {{ redis_user_group }}
    - require:
      - user: {{ redis_user_group }}
      - group: {{ redis_user_group }}

redis-git:
  git.latest:
    - name: "https://github.com/antirez/redis"
    - target: {{ redis_inst_dir }}/redis-git
    - rev: "2.6"
    - force: true
    - require:
      - pkg: {{ pillar['git'] }}
      - file: {{ redis_inst_dir }}

build-redis:
  cmd.wait:
    - name: "make && make PREFIX={{ redis_inst_dir }} install"
    - cwd: {{ redis_inst_dir }}/redis-git
    - watch:
      - git: redis-git

/etc/redis:
  file:
    - directory

/etc/redis/{{ redis_port }}.conf:
  file.managed:
    - source: salt://templates/redis.conf
    - template: jinja
    - context:
        redis_data_dir: {{ redis_data_dir }}
        redis_port: {{ redis_port }}
        redis_log_file: /var/log/redis_{{ redis_port }}.log
    - require:
      - file: /etc/redis

{{ redis_data_dir }}:
  file:
    - directory
    - makedirs: true

/etc/init.d/redis_{{ redis_port }}:
  file.managed:
    - source: salt://templates/redis-server.service
    - template: jinja
    - context:
        redis_port: {{ redis_port }}
        redis_inst_dir: {{ redis_inst_dir }}
    - mode: 755

enable-service:
  cmd.run:
{% if grains['os_family'] == "Debian" %}
    - name: update-rc.d redis_{{ redis_port }} defaults
    - watch:
      - file: /etc/init.d/redis_{{ redis_port }}
{% elif grains['os_family'] == "RedHat" %}
    - name: chkconfig --add redis_{{ redis_port }}
    - watch:
      - file: /etc/init.d/redis_{{ redis_port }}
chkconfig --level 345 redis_{{ redis_port }} on:
  cmd.run:
    - require:
      - cmd: chkconfig --add redis_{{ redis_port }}
{% endif %}

redis_{{ redis_port }}:
  service:
    - running
    - require:
      - file: {{ redis_data_dir }}
    - watch:
      - file: /etc/redis/{{ redis_port }}.conf
      - cmd: build-redis
      - cmd: enable-service
