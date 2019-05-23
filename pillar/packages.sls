git: git
{% if grains['os_family'] == 'RedHat' %}
stunnel_pkg: stunnel
{% elif grains['os_family'] == 'Debian' %}
stunnel_pkg: stunnel4
{% endif %}
