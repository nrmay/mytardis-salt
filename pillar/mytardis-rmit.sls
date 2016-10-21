roles:
  - master-host
  - mysql-server
  - mysql-client
  - mytardis
  - mydata
  - rabbitmq
#  - postgresql-server
#  - postgresql-client  
  

{% set static_file_storage_path = '/opt/mytardis/static' %}
{% set rabbitmq_pw = "asfdalkh42z" %}

nginx_static_file_path: {{ static_file_storage_path }}

nginx_server_name: localhost
nginx_strict_name_checking: False

{% set nginx_ssl = False %}
nginx_ssl: {{ nginx_ssl }}

# needed for master-less deployments
nginx_upstream_servers:
  - address: unix:/var/run/gunicorn/mytardis/socket
    parameters: ""

mytardis_repo: "https://github.com/nrmay/mytardis.git"
mytardis_branch: ""
mytardis_base_dir: "/opt/mytardis"
mytardis_buildout: False

mydata_repo: "https://github.com/nrmay/mytardis-app-mydata.git"
mydata_branch: "master"

mytardis_user: 'mytardis'
mytardis_group: 'mytardis'

mytardis_db: 'mytardis'
mytardis_db_user: 'mytardis'
mytardis_db_engine: 'django.db.backends.mysql'
mytardis_db_port: 3306
mytardis_db_pass: ''
mytardis_db_host: 'localhost'

mysql_user: 'root'
mysql_pass: ''
mysql_socket: '/var/lib/mysql/mysql.sock'

# mysql
# engine: 'django.db.backends.mysql'
# port: '3306'

# postgresql
# port: '5432'
# engine: 'django.db.backends.postgresql_psycopg2'

apps:
  - tardis.apps.slideshow_view
  - tardis.apps.deep_storage_download_mapper

static_file_storage_path: {{ static_file_storage_path }}

#file_store_path: '/vol/mnrf/mnrfdata/dev'

django_settings:
  - "from tardis.style_settings import *"
  - "DEBUG = True"
  - "SYSTEM_LOG_LEVEL = 'DEBUG'"
  - "MODULE_LOG_LEVEL = 'DEBUG'"
  - "SITE_TITLE = 'MyTardis'"
  - "SITE_ID = 1"
  - "from tardis.rmit_style_settings import *"
  - "SPONSORED_TEXT = 'Deployed using <a href=\"https://saltstack.com/\">SaltStack</a>.'"
  - "DEFAULT_INSTITUTION = 'RMIT University'"
  - "NEW_USER_INITIAL_GROUPS = ['Users',]"
  - "LOGIN_URL = 'index'"
  - "LOGIN_FRONTEND_DEFAULT = 'local'"
  - "LOGIN_FRONTENDS['local']['enabled'] = True"
  - "LOGIN_FRONTENDS['cas']['enabled'] = False"
  - "LOGIN_FRONTENDS['aaf']['enabled'] = False"
  - "LOGIN_FRONTENDS['aafe']['enabled'] = False"
  - "LOGIN_HOME_ORGANIZATION = ''"
  - "CAS_SERVER_URL = 'https://sso-cas-ext-at.its.rmit.edu.au/rmitcas/'"
  - "CAS_SERVICE_URL = 'http://<url of the tardis instance>/'"
  - "RAPID_CONNECT_CONFIG['iss'] = 'https://rapid.test.aaf.edu.au'"
  - "RAPID_CONNECT_CONFIG['aud'] = 'https://<url of the tardis instance>/'"
  - "RAPID_CONNECT_CONFIG['secret'] = '<secret key>'"
  - "RAPID_CONNECT_CONFIG['authnrequest_url'] = '<url provided by AAF>'" 
  - "RAPID_CONNECT_CONFIG['entityID'] = '<url of auth provider>'" 
  - "LANGUAGE_CODE = 'en-au'"
  - "DEEP_DATASET_STORAGE = True"
  - 'DATASET_VIEWS = [("http://www.tardis.edu.au/schemas/trdDataset/2",
                       "tardis.apps.slideshow_view.views.view_full_dataset"),'
  - '                 ("http://synchrotron.org.au/mx/indexed/1",
                       "tardis.apps.slideshow_view.views.view_full_dataset"),]'
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

secret_key: 'ij!%7-el^^rptw$b=iol%78okl10ee7zql-()z1r6e)gbxd3gl'

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

# --- end of file mytardis-rmit.sls --- #