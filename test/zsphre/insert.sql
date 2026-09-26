.timeout 1000
begin immediate transaction;

insert into commands (started_at, hist, line, full, cwd, tty, host)
values (strftime('%Y-%m-%dT%H:%M:%fZ'), 'hist', 'line', 'full', 'cwd', 'tty', 'host');

select last_insert_rowid() as id;

commit transaction;
