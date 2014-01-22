{% for mount_point, args in salt['pillar.get']('nfs-servers').items() %}
{{ mount_point }}:
  mount.mounted:
    - device: {{ args['mount_path'] }}
    - fstype: nfs
    - mkmnt: True
    - opts: {{ args['mount_options'] }}
    - persist: True
{% if 'nfs-client' in salt['pillar.get']('roles') and grains['os_family'] != 'RedHat' %}
    - require:
        - service: stunnel4-service-for-nfs
{% endif %}
{% endfor %}
