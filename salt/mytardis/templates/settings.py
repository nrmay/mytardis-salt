from tardis.settings_changeme import *

DATABASES = {
    'default': {
        'ENGINE':   "{{ pillar['mytardis_db_engine'] }}",
        'NAME':     "{{ pillar['mytardis_db'] }}",
        'USER':     "{{ pillar['mytardis_db_user'] }}",
        'PASSWORD': "{{ pillar['mytardis_db_pass'] }}",
        'HOST':     "{{ pillar['mytardis_db_host'] }}",
        'PORT':     "{{ pillar['mytardis_db_port'] }}",
{% if pillar['mytardis_db_engine'] == 'django.db.backends.mysql' %} 
        'STORAGE_ENGINE': 'MyISAM',
        'OPTIONS': {
            'init_command': 'SET storage_engine=MyISAM',
            'charset':      'utf8mb4',
            'use_unicode':  True,
        },
{% endif %}
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

{% if "secret_key" in pillar %}
SECRET_KEY = "{{ pillar['secret_key'] }}"
{% else %}
SECRET_KEY = None
{% endif %}

{% if "file_store_path" in pillar %}
FILE_STORE_PATH = "{{ pillar['file_store_path'] }}"
{% endif %}

{% if "staging_path" in pillar %}
STAGING_PATH = "{{ pillar['staging_path'] }}"
{% endif %}

{% if "sync_temp_path" in pillar %}
SYNC_TEMP_PATH = "{{ pillar['sync_temp_path'] }}"
{% endif %}


{% if "django_settings" in pillar %}
{% for setting in pillar['django_settings'] %}
{{ setting }}
{% endfor %}
{% endif %}
