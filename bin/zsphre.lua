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

local function create_db(db_file)
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
end

local commands = {}

function commands.zsh_hook_preexec(db_file, line, full, cwd, tty, host)
  local result = sqlite3(db_file, ([[
    pragma synchronous=NORMAL;

    insert into commands (started_at, line, full, cwd, tty, host)
    values (strftime(%s), %s, %s, %s, %s, %s);

    select last_insert_rowid();
  ]]):format(
    sqlite3_quote "%Y-%m-%dT%H:%M:%fZ",
    sqlite3_quote(line),
    sqlite3_quote(full),
    sqlite3_quote(cwd),
    sqlite3_quote(tty),
    sqlite3_quote(host)))
  io.write(result:match "^(%d*)", "\n")
end

function commands.zsh_hook_precmd(db_file, id, status, pipe_status)
  sqlite3(db_file, ([[
    pragma synchronous=NORMAL;

    update commands
    set finished_at = strftime(%s), status = %d, pipe_status = %s
    where id = %d;
  ]]):format(
    sqlite3_quote "%Y-%m-%dT%H:%M:%fZ",
    status,
    sqlite3_quote(pipe_status),
    id))
end

local help = [[
Usage:
  zshphre zsh_hook_preexec line full cwd tty host
  zshphre zsh_hook_precmd id status pipe_status
]]

local i = 1
while i <= #arg do
  local opt = arg[i]
  i = i + 1
  if opt == "-h" or opt == "--help" then
    io.stderr:write(help)
    os.exit()
  elseif opt == "--" then
    break
  else
    i = i - 1
    break
  end
end
local command = assert(commands[arg[i]])

local db_file = os.getenv "XDG_STATE_HOME" .. "/zsphre.db"
create_db(db_file)
command(db_file, (table.unpack or unpack)(arg, i + 1))
