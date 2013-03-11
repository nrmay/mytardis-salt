from tardis.settings_changeme import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': '{{ pillar['postgres.db'] }}',
        'USER': '{{ pillar['mytardis_db_user'] }}',
        'PASSWORD': '{{ pillar['mytardis_db_pass'] }}',
{% if 'postgres.host' not in pillar %}
        'HOST': '',
{% else %}
        'HOST': '{{ pillar['postgres.host'] }}',
{% endif %}
        'PORT': '',
    }
}

# Disable faulty equipment app
INSTALLED_APPS = filter(lambda a: a != 'tardis.apps.equipment', INSTALLED_APPS)

INSTALLED_APPS += ('south',)

{% if "apps" in pillar %}
INSTALLED_APPS += (
{% for app in pillar['apps'] %}
    '{{ app }}',
{% endfor %}
    )
{% endif %}

{% if "django_settings" in pillar %}
{% for setting in pillar['django_settings'] %}
{{ setting }}
{% endfor %}
{% endif %}

