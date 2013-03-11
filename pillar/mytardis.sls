mytardis_repo: "https://github.com/mytardis/mytardis.git"
mytardis_branch: "3.0"
mytardis_base_dir: "/opt/mytardis"

mytardis_user: "mytardis"

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
