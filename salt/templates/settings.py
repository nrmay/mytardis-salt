from tardis.settings_changeme import *

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': '{{ pillar['postgres.db'] }}',
        'USER': '{{ pillar['postgres.user'] }}',
        'PASSWORD': '{{ pillar['postgres.pass'] }}',
        'HOST': '{{ pillar['postgres.host'] }}',
        'PORT': '',
    }
}

# Disable faulty equipment app
INSTALLED_APPS = filter(lambda a: a != 'tardis.apps.equipment', INSTALLED_APPS)

INSTALLED_APPS += ('south',)
