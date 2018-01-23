-- Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-dotfiles.  If not, see <http://www.gnu.org/licenses/>.

local shell = require "dromozoa.commons.shell"

local luarocks = ...
if not luarocks then
  luarocks = "luarocks"
end

local handle = assert(io.popen(("%s --version"):format(shell.quote(luarocks))))
local path, version = handle:read():match"^(.-/luarocks) (%d[%d%.]+)$"
handle:close()
local path_pattern = path:gsub("%W", "%%%1")

local function normalize_text(source)
  return source:gsub(path_pattern, "luarocks")
end

local state
local options = {}
local commands = {}

local handle = assert(io.popen("luarocks help"))
for line in handle:lines() do
  if line:find "^%a" then
    state = line
  elseif state == "GENERAL OPTIONS" then
    local option, text = line:match "^\t(%-.-) +(.*)"
    if option then
      options[#options + 1] = { option, text }
    else
      local text = line:match "^\t +(.*)"
      if text then
        local option = options[#options]
        option[2] = option[2] .. " " .. text
      end
    end
  elseif state == "COMMANDS" then
    local indent, text = line:match "^(\t+)(.*)"
    if indent then
      if #indent == 1 then
        commands[#commands + 1] = { text }
      else
        assert(#indent == 2)
        local command = commands[#commands]
        assert(#command == 1)
        command[2] = text
      end
    end
  end
end
handle:close()

io.write [[
  _arguments -C -S \
]]
for i = 1, #options do
  local option = options[i]
  local text = normalize_text(option[2])
  local opt, arg = option[1]:match "^(%-.-=)<(.-)>$"
  if opt then
    io.write("    ", shell.quote(opt .. "[" .. text .. "]:" .. arg), " \\\n")
  else
    io.write("    ", shell.quote(option[1] .. "[" .. text .. "]"), " \\\n")
  end
end
io.write [[
    ":command:->command"
]]

io.write [[
  local -a luarocks_commands
  luarocks_commands=(
]]
for i = 1, #commands do
  local command = commands[i]
  io.write("    ", shell.quote(command[1] .. ":" .. normalize_text(command[2])), "\n")
end
io.write [[
  )
]]
