#! /bin/sh -e

db_file=test.db

if ! test -f "$db_file"
then
  sqlite3 -csv "$db_file" <create.sql >/dev/null
fi

id=$(sqlite3 -csv "$db_file" <insert.sql)

sqlite3 -csv "$db_file" <<EOH >/dev/null
.timeout 1000
begin immediate transaction;

update commands
set finished_at = strftime('%Y-%m-%dT%H:%M:%fZ'), status = 0, pipe_status = '0'
where id = $id;

select
  strftime('%Y/%m/%d %H:%M:%S', started_at, 'localtime') as started_at,
  strftime('%Y/%m/%d %H:%M:%S', finished_at, 'localtime') as finished_at,
  strftime('%s', finished_at) - strftime('%s', started_at) as elapsed,
  hist,
  line,
  full,
  cwd,
  tty,
  host,
  status,
  pipe_status,
  on_finish
from commands
where id = $id;

commit transaction;
EOH
