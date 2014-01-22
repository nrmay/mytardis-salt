roles:
  - master-host
  - mytardis
  - rabbitmq
  - production

{% set static_file_storage_path = '/srv/mytardis/static' %}
{% set rabbitmq_pw = "asfdalkh42z" %}

nginx_static_file_path: {{ static_file_storage_path }}

nginx_server_name: localhost

{% set nginx_ssl = False %}
nginx_ssl: {{ nginx_ssl }}

mytardis_repo: "https://github.com/grischa/mytardis.git"
mytardis_branch: "master"
mytardis_base_dir: "/opt/mytardis"

mytardis_user: "mytardis"
mytardis_group: "mytardis"

mytardis_db_user: "mytardis_db_user"
mytardis_db_pass: "mytardis_db_pass"
mytardis_db: "mytardis_db"

postgres.user: "mytardis_db_user"
postgres.pass: "mytardis_db_pass"
postgres.host: "localhost"
postgres.maintenance_db: 'postgres'

apps:
  - tardis.apps.slideshow_view
  - tardis.apps.deep_storage_download_mapper

static_file_storage_path: {{ static_file_storage_path }}

django_settings:
  - "LANGUAGE_CODE = 'en-au'"
  - "DEFAULT_INSTITUTION = 'Monash University'"
  - "DEEP_DATASET_STORAGE = True"
  - 'DATASET_VIEWS = [("http://www.tardis.edu.au/schemas/trdDataset/2",
                       "tardis.apps.slideshow_view.views.view_full_dataset"),'
  - '                 ("http://synchrotron.org.au/mx/indexed/1",
                       "tardis.apps.slideshow_view.views.view_full_dataset"),]'
  - "from celery.schedules import crontab"
  - "from datetime import timedelta"
  - "CELERYBEAT_SCHEDULE = {"
  - "    'verify-files': {"
  - "        'task': 'tardis_portal.verify_files',"
  - "        'schedule': timedelta(seconds=120),"
  - "    },"
  - "}"
  - "djcelery.setup_loader()"
{% if nginx_ssl %}
  - "SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTOCOL', 'https')"
  - "SESSION_COOKIE_SECURE = True"
  - "CSRF_COOKIE_SECURE = True"
{% endif %}
  - "DEFAULT_ARCHIVE_FORMATS = ['tar']"
{% for hostid, ipaddrs in salt['mine.get']('roles:rabbitmq', 'network.ip_addrs', 'grain').items() %}
   {% if hostid in salt['mine.get']('roles:production', 'network.ip_addrs', 'grain') %}
  - "BROKER_URL = 'amqp://myt-celery-produser:{{ rabbitmq_pw }}@{{ ipaddrs[0] }}:5672/myt-celery-prod'"
   {% endif %}
{% endfor %}
  - "CELERY_RESULT_BACKEND = 'amqp'"
  - "REDIS_VERIFY_MANAGER = False"
  - "ALLOWED_HOSTS = ['*',]"
  - "STATIC_ROOT = '{{ static_file_storage_path }}'"
  - "REGISTRATION_OPEN = False"
  - "SITE_TITLE = 'MyTardis Salt Example Site'"
  - "SPONSORED_TEXT = 'Deployed using SaltStack. Please customise for your site.'"

secret_key: 'bv$2h+s#&718g2&-e18m-i1qf*5%%^-_34x0l640ryfw9$x$la'

gunicorn_tcp_socket: false
gunicorn_ssl: false

running_services:
  celeryd: true
  celerybeat: true

provide_staticfiles: True

rabbitmq-user: myt-celery-produser
rabbitmq-pw: {{ rabbitmq_pw }}
rabbitmq-vhost: myt-celery-prod

rabbitmq-ssl: false
