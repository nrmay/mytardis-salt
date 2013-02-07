{% if grains['os'] == 'RedHat' %}
git: git
{% elif grains['os'] == 'Ubuntu' %}
git: git-core
{% elif grains['os'] == 'CentOS' %}
git: git
{% endif %}