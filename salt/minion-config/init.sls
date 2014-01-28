# keeps minions up to date. version should be specified in global settings
salt-pip-prereqs:
  pkg.latest:
    - pkgs:
        - python-pip
        - swig
{% if grains['os_family'] == 'Debian' %}
        - python-dev
        - libssl-dev
        - g++
{% else %}
        - python-devel
{% endif %}

{% if grains['os_family'] != 'RedHat' %}
salt:
  pip.installed:
{% if pillar.get('salt_install_type', 'stable') == 'git' %}
    - name: salt
    - editable: "git+https://github.com/saltstack/salt.git@{{ pillar.get('salt_version', '0.17.4') }}#egg=salt"
{% else %}
    - name: salt=={{ salt['pillar.get']('salt_version', '0.17.4') }}
{% endif %}
    - upgrade: True
    - require:
        - pkg: salt-pip-prereqs
{% endif %}

{% if salt['pillar.get']('new_salt_master', False) %}
new-master-key:
  cmd.wait:
    - name: rm /etc/salt/pki/minion/minion_master.pub
    - watch:
        - file: /etc/salt/minion
    - watch_in:
        - service: salt-minion
{% endif %}

/etc/salt/minion:
  file.managed:
    - source: salt://minion-config/minion-etc
    - template: jinja
    - context:
      master_address: {{ salt['pillar.get']('salt_master_address', 'salt') }}

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
        - pip: salt
{% endif %}
