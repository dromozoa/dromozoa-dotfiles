pragma auto_vacuum=INCREMENTAL;
pragma journal_mode=WAL;

create table if not exists commands (
  id integer primary key,
  started_at text not null,
  finished_at text,
  hist text not null,
  line text not null,
  full text not null,
  cwd text not null,
  tty text not null,
  host text not null,
  status integer,
  pipe_status text,
  on_finish text
);
