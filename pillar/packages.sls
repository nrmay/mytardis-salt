{% if grains['os_family'] == 'RedHat' %}
git: git
stunnel_pkg: stunnel
{% elif grains['os_family'] == 'Debian' %}
git: git-core
stunnel_pkg: stunnel4
{% endif %}
