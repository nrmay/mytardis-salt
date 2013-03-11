mytardis_repo: "https://github.com/mytardis/mytardis.git"
mytardis_branch: "3.0"
mytardis_base_dir: "/opt/mytardis"

mytardis_user: "mytardis"
mytardis_group: "mytardis"

# auth-fix for postgres on centos not implemented
# in the meantime, use the same username as mytardis_user for this
mytardis_db_user: "mytardis"
mytardis_db_pass: "mytardis"

# localhost requires this to be postgres, remote host the db user
postgres.user: "postgres"
postgres.db: "mytardisdb"
# the host has to be not set for local deployment as
# any string, even "None" is used as hostname otherwise
#postgres.host: []

secret_key: "8)-9b0kcaj89%2#4j$80q*p1@=93j=@$(+nq7-br6&w4%!#-ku"  
# please change!
# this key is hosted publicly and if you do not change it will make it much
# easier to compromise the security of your system
# suggestion:
# from django.utils.crypto import get_random_string
# chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'
# print get_random_string(50, chars)


# optional:
django_settings:
  - "SQUASHFS_ENABLED = False"
  - "LANGUAGE_CODE = 'en-au'"

#file_store_path: "/var/store"
#staging_path: "/var/staging"
#sync_temp_path: "/var/sync_temp"

