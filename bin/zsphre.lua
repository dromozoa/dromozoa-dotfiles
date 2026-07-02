#! /usr/bin/env lua

-- Copyright (C) 2026 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-dotfiles.
--
-- dromozoa-dotfiles is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-dotfiles is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-dotfiles. If not, see <https://www.gnu.org/licenses/>.

local shell = require "dromozoa.commons.shell"

local function sqlite3_quote(s)
  return "'" .. (s or ""):gsub("'", "''") .. "'"
end

local function sqlite3(db_file, sql)
  local out_file = os.tmpname()

  local command = table.concat({
    "sqlite3",
    "-csv",
    shell.quote(db_file),
    ">",
    shell.quote(out_file),
  }, " ")
  local handle = assert(io.popen(command, "w"))
  handle:write(sql)
  handle:close()

  local handle = assert(io.open(out_file))
  local result = handle:read "*a"
  handle:close()

  os.remove(out_file)
  return result
end

local function exists(file)
  local handle = io.open(file, "rb")
  if handle then
    handle:close()
    return true
  else
    return false
  end
end

local db_file = os.getenv "XDG_STATE_HOME" .. "/zsphre.db"
if not exists(db_file) then
  sqlite3(db_file, [[
    pragma auto_vacuum=INCREMENTAL;
    pragma journal_mode=WAL;
    pragma synchronous=NORMAL;

    begin immediate transaction;

    create table if not exists commands (
      id integer primary key,
      started_at text not null,
      finished_at text,
      line text not null,
      full text not null,
      cwd text not null,
      tty text not null,
      host text not null,
      status integer,
      pipe_status text,
      on_finish text,
      inserted_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ')),
      updated_at text not null default (strftime('%Y-%m-%dT%H:%M:%fZ'))
    );

    create trigger if not exists trigger_commands_update after update on commands
    for each row
    begin
      update commands set updated_at = strftime('%Y-%m-%dT%H:%M:%fZ') where rowid = new.rowid;
    end;

    commit transaction;
  ]])
end

if arg[1] == "--preexec" then
  local result = sqlite3(db_file, ([[
    pragma synchronous=NORMAL;

    insert into commands (started_at, line, full, cwd, tty, host)
    values (strftime(%s), %s, %s, %s, %s, %s);

    select last_insert_rowid();
  ]]):format(
    sqlite3_quote "%Y-%m-%dT%H:%M:%fZ",
    sqlite3_quote(arg[2]),
    sqlite3_quote(arg[4]),
    sqlite3_quote(shell.eval "pwd"),
    sqlite3_quote(shell.eval "tty"),
    sqlite3_quote(shell.eval "uname -n")))
  io.write(result:match "^(%d*)", "\n")
elseif arg[1] == "--precmd" then
  sqlite3(db_file, ([[
    pragma synchronous=NORMAL;

    update commands
    set finished_at = strftime(%s), status = %d, pipe_status = %s
    where id = %d;
  ]]):format(
    sqlite3_quote "%Y-%m-%dT%H:%M:%fZ",
    arg[3],
    sqlite3_quote(arg[4]),
    arg[2]))
end
