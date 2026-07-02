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

local home = os.getenv "HOME"
package.path = home .. "/dromozoa-dotfiles/?.lua;"
    .. home .. "/dromozoa-dotfiles/modules/dromozoa-calendar/?.lua;"
    .. home .. "/dromozoa-dotfiles/modules/dromozoa-commons/?.lua;"
    .. home .. "/dromozoa-dotfiles/modules/dromozoa-utf8/?.lua;"
    .. package.path

local parse_csv = require "dromozoa.parse_csv"
local json = require "dromozoa.commons.json"
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
    ]])
  end
end

local commands = {}

function commands.zsh_hook_preexec(db_file, hist, line, full, cwd, tty, host)
  local result = sqlite3(db_file, ([[
    begin immediate transaction;

    insert into commands (started_at, hist, line, full, cwd, tty, host)
    values (strftime(%s), %s, %s, %s, %s, %s, %s);

    select last_insert_rowid();

    commit transaction;
  ]]):format(
    sqlite3_quote "%Y-%m-%dT%H:%M:%fZ",
    sqlite3_quote(hist),
    sqlite3_quote(line),
    sqlite3_quote(full),
    sqlite3_quote(cwd),
    sqlite3_quote(tty),
    sqlite3_quote(host)))
  local records = parse_csv(result)
  io.write(records[1][1], "\n")
end

function commands.zsh_hook_precmd(db_file, id, status, pipe_status)
  local result = sqlite3(db_file, ([[
    begin immediate transaction;

    update commands
    set finished_at = strftime(%s), status = %d, pipe_status = %s
    where id = %d;

    select
      strftime(%s, started_at, 'localtime'),
      strftime(%s, finished_at, 'localtime'),
      strftime(%s, finished_at) - strftime(%s, started_at),
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
    where id = %d;

    commit transaction;
  ]]):format(
    sqlite3_quote "%Y-%m-%dT%H:%M:%fZ",
    status,
    sqlite3_quote(pipe_status),
    id,
    sqlite3_quote "%Y/%m/%d %H:%M:%S",
    sqlite3_quote "%Y/%m/%d %H:%M:%S",
    sqlite3_quote "%s",
    sqlite3_quote "%s",
    id))

  local records = parse_csv(result)
  local record = assert(records[1])
  local data = {
    started_at = record[1],
    finished_at = record[2],
    elapsed = tonumber(record[3]),
    hist = record[4],
    line = record[5],
    full = record[6],
    cwd = record[7],
    tty = record[8],
    host = record[9],
    status = tonumber(record[10]),
    pipe_status = record[11],
    on_finish = record[12]
  }
  print(json.encode(data, { pretty = true, stable = true }))
end

function commands.list_runnings(db_file)
  local result = sqlite3(db_file, ([[
    select
      id,
      strftime(%s, started_at, 'localtime'),
      strftime(%s) - strftime(%s, started_at),
      line
    from commands
    where finished_at is null
    order by id;
  ]]):format(
    sqlite3_quote "%Y/%m/%d %H:%M:%S",
    sqlite3_quote "%s",
    sqlite3_quote "%s"))

  local records = parse_csv(result)
  for _, record in ipairs(records) do
    if #record == 1 then
      break
    end
    io.write(("| %d | %s | %d | %s\n"):format(
        tonumber(record[1]),
        record[2],
        tonumber(record[3]),
        record[4]))
  end
end

local help = [[
Usage:
  zsphre zsh_hook_preexec hist line full cwd tty host
  zsphre zsh_hook_precmd id status pipe_status
  zsphre list_runnings
  zsphre on_finish ids hook
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
