#!pydsl

host = __pillar__.get('postgres.host', None)

# PG user
postgres_user_dict = {"password": __pillar__['mytardis_db_pass']}
if host:
    postgres_user_dict["host"] = host 
else:
    postgres_user_dict["runas"] = "postgres"
postgres_user = state(__pillar__['mytardis_db_user'])
postgres_user.postgres_user.present(**postgres_user_dict)
postgres_user.postgres_user.require_in(state(__pillar__['postgres.db']).postgres_database)  # seems redundant, but was only way to fix order
if not host:
    postgres_user.postgres_user.require(service="postgresql-server")

# PG database
pg_db_dict = {
    "owner": __pillar__['mytardis_db_user'],
}
if not host:
    pg_db_dict["runas"] = "postgres"
pg_db_reqs = {"postgres_user": __pillar__['mytardis_db_user'],}
if not host:
    pg_db_reqs["service"] = "postgresql-server"
postgres_db_exists = state(__pillar__['postgres.db'])
postgres_db_exists.postgres_database.present(
    **pg_db_dict).require(**pg_db_reqs)
