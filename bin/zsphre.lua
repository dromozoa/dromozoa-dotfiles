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

local function sqlite3(db_file, sql, suppress_stderr)
  local out_file = os.tmpname()

  local command = {
    "sqlite3",
    "-header",
    "-csv",
    shell.quote(db_file),
    ">",
    shell.quote(out_file),
  }

  if suppress_stderr then
    table.insert(command, "2>/dev/null")
  end

  local handle = assert(io.popen(table.concat(command, " "), "w"))
  handle:write(sql)
  handle:close()

  local handle = assert(io.open(out_file))
  local result = handle:read "*a"
  handle:close()

  os.remove(out_file)
  return result
end

local function sqlite3_parse_csv(source)
  local source_records = parse_csv(source:gsub("\n\r", "\n"):gsub("\r\n?", "\n"))
  local result_records = {}

  local source_header = source_records[1]
  for i = 2, #source_records do
    local source_record = source_records[i]
    local result_record = {}
    for j, k in ipairs(source_header) do
      result_record[k] = source_record[j]
    end
    table.insert(result_records, result_record)
  end

  return result_records
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
    sqlite3(db_file, [[.timeout 1000
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
        user text not null,
        host text not null,
        status integer,
        pipe_status text,
        on_finish text
      );
    ]])
  end

  sqlite3(db_file, [[.timeout 1000
    alter table commands add column user text not null default '';
  ]], true)
end

local commands = {}

function commands.zsh_hook_preexec(db_file, hist, line, full, cwd, tty, user, host)
  -- userの追加のための移行措置
  if not host then
    host = user
    user = shell.eval "id -u -n" or ""
  end

  local result = sqlite3(db_file, ([[.timeout 1000
    begin immediate transaction;

    insert into commands (started_at, hist, line, full, cwd, tty, user, host)
    values (strftime(%s), %s, %s, %s, %s, %s, %s, %s);

    select last_insert_rowid() as id;

    commit transaction;
  ]]):format(
    sqlite3_quote "%Y-%m-%dT%H:%M:%fZ",
    sqlite3_quote(hist),
    sqlite3_quote(line),
    sqlite3_quote(full),
    sqlite3_quote(cwd),
    sqlite3_quote(tty),
    sqlite3_quote(user),
    sqlite3_quote(host)))
  local records = sqlite3_parse_csv(result)
  io.write(records[1].id, "\n")
end

function commands.zsh_hook_precmd(db_file, id, status, pipe_status)
  local result = sqlite3(db_file, ([[.timeout 1000
    begin immediate transaction;

    update commands
    set finished_at = strftime(%s), status = %d, pipe_status = %s
    where id = %d;

    select
      strftime(%s, started_at, 'localtime') as started_at,
      strftime(%s, finished_at, 'localtime') as finished_at,
      strftime(%s, finished_at) - strftime(%s, started_at) as elapsed,
      hist,
      line,
      full,
      cwd,
      tty,
      user,
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

  local records = sqlite3_parse_csv(result)
  local record = assert(records[1])
  record.elapsed = assert(tonumber(record.elapsed))
  record.status = assert(tonumber(record.status))

  if record.on_finish ~= "" then
    local handle = assert(io.popen(record.on_finish, "w"))
    handle:write(json.encode(record, { pretty = true, stable = true }), "\n")
    handle:close()
  end
end

function commands.list_runnings(db_file)
  local result = sqlite3(db_file, ([[
    select
      id,
      strftime(%s, started_at, 'localtime') as started_at,
      strftime(%s) - strftime(%s, started_at) as elapsed,
      line
    from commands
    where finished_at is null
    order by id;
  ]]):format(
    sqlite3_quote "%Y/%m/%d %H:%M:%S",
    sqlite3_quote "%s",
    sqlite3_quote "%s"))

  local records = sqlite3_parse_csv(result)
  for _, record in ipairs(records) do
    io.write(("%d\t%s\t%d\t%s\n"):format(
      assert(tonumber(record.id)),
      record.started_at,
      assert(tonumber(record.elapsed)),
      record.line))
  end
end

function commands.on_finish(db_file, ids, hook)
  local condition = nil
  if ids == "all" then
    condition = "1"
  elseif ids:find "^%d+$" then
    condition = "id = " .. ids
  elseif ids:find "^%d[%d,]+%d$" then
    condition = "id in (" .. ids .. ")"
  end
  assert(condition)

  sqlite3(db_file, ([[
    update commands
    set on_finish = %s
    where finished_at is null and %s;
  ]]):format(
    sqlite3_quote(hook),
    condition))
end

local help = [[
Usage:
  zsphre zsh_hook_preexec hist line full cwd tty user host
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
