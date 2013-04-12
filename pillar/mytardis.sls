mytardis_repo: "https://github.com/grischa/mytardis.git"
mytardis_branch: "synch-views"
mytardis_base_dir: "/opt/mytardis"

mytardis_user: "mytardis"
mytardis_group: "mytardis"

mytardis_db_user: "mytardis"
mytardis_db_pass: "mytardis"
mytardis_db: "mytardis"

secret_key: "8)-9b0kcaj89%2#4j$80q*p1@=93j=@$(+nq7-br6&w4%!#-ku"  
# please change!
# this key is hosted publicly and if you do not change it will make it much
# easier to compromise the security of your system
# suggestion:
# from django.utils.crypto import get_random_string
# chars = 'abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)'
# print get_random_string(50, chars)

apps:
  - tardis.apps.slideshow_view

# optional:
django_settings:
  - "SQUASHFS_ENABLED = False"
  - "LANGUAGE_CODE = 'en-au'"
  - 'DATASET_VIEWS = [("http://www.tardis.edu.au/schemas/trdDataset/2",
                       "tardis.apps.slideshow_view.views.view_full_dataset"),]'

#file_store_path: "/var/store"
#staging_path: "/var/staging"
#sync_temp_path: "/var/sync_temp"

running_services:
  celeryd: true
  celerybeat: false
