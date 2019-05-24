# keeps minions up to date. version should be specified in global settings
salt-pip-prereqs:
  pkg.latest:
    - pkgs:
        - swig
{% if grains['os_family'] == 'RedHat' %}
        - python2-pip
        - python-devel
        - openssl-devel
{% else %}
        - python-pip
        - python-dev
        - libssl-dev
        - g++
{% endif %}

# {% if grains['os_family'] != 'RedHat' %}
# salt:
#   pip.installed:
# {% if pillar.get('salt_install_type', 'stable') == 'git' %}
#     - name: salt
#     - editable: "git+https://github.com/saltstack/salt.git@{{ pillar.get('salt_version', '0.17.4') }}#egg=salt"
# {% else %}
#     - name: salt=={{ salt['pillar.get']('salt_version', '0.17.4') }}
# {% endif %}
#     - upgrade: True
#     - require:
#         - pkg: salt-pip-prereqs
# {% endif %}

{% if salt['pillar.get']('new_salt_master', False) %}
new-master-key:
  cmd.wait:
    - name: rm /etc/salt/pki/minion/minion_master.pub
    - watch:
        - file: /etc/salt/minion
    - watch_in:
        - service: salt-minion
{% endif %}

/var/log/salt:
  file.directory: []

/etc/salt:
  file.directory: []

/etc/salt/minion:
  file.managed:
    - source: salt://minion-config/minion-etc
    - template: jinja
    - context:
      master_address: {{ salt['pillar.get']('salt_master_address', 'salt') }}
    - require:
      - file: /etc/salt

/etc/init.d/salt-minion:
  file.managed:
    - source: salt://init-scripts/salt-minion
    - mode: 755

{% if grains['os_family'] != 'RedHat' %}
salt-minion:
  service:
    - running
    - watch:
        - file: /etc/salt/minion
        - file: /etc/init.d/salt-minion
#        - pip: salt

{% endif %}
