{% if grains['os'] == 'RedHat' %}
git: git
{% elif grains['os'] == 'Ubuntu' %}
git: git-core
{% endif %}