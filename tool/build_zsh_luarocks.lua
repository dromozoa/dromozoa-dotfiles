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

local dumper = require "dromozoa.commons.dumper"
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

local function parse_help(command)
  local state
  local options = {}

  local handle = assert(io.popen(("%s help %s"):format(shell.quote(luarocks), shell.quote(command))))
  for line in handle:lines() do
    if line:find "^%a" then
      state = line
    elseif state == "DESCRIPTION" then
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
    end
  end
  handle:close()

  return options
end

local argument_map = {
  server = "_hosts";
}

local function write_options(function_name, options)
  local out = assert(io.open("zshfuncs/" .. function_name, "w"))
  out:write(([[
#autoload
%s() {
  options=(
    $options
]]):format(function_name))

  for i = 1, #options do
    local option = options[i]
    local text = normalize_text(option[2])
    local name, argument = option[1]:match "^(%-.-=)<(.-)>$"
    local spec
    if name then
      local action = argument_map[argument]
      if action then
        spec = ("%s[%s]:%s:%s"):format(name, text, argument, action)
      else
        spec = ("%s[%s]:%s"):format(name, text, argument)
      end
    else
      spec = ("%s[%s]"):format(option[1], text)
    end
    out:write("    ", shell.quote(spec), "\n")
  end

  out:write [[
  )
}
]]
end

local state
local general_options = {}
local commands = {}

local handle = assert(io.popen(("%s help"):format(shell.quote(luarocks))))
for line in handle:lines() do
  if line:find "^%a" then
    state = line
  elseif state == "GENERAL OPTIONS" then
    local option, text = line:match "^\t(%-.-) +(.*)"
    if option then
      general_options[#general_options + 1] = { option, text }
    else
      local text = line:match "^\t +(.*)"
      if text then
        local option = general_options[#general_options]
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

local name = "__dromozoa_luarocks_commands"
local out = assert(io.open("zshfuncs/" .. name, "w"))
out:write(([[
#autoload
%s() {
  commands=(
    $commands
]]):format(name))
for i = 1, #commands do
  local command = commands[i]
  out:write("    ", shell.quote(command[1] .. ":" .. normalize_text(command[2])), "\n")
end
out:write [[
  )
}
]]

write_options("__dromozoa_luarocks_general_options", general_options)

local list_options = parse_help "list"
write_options("__dromozoa_luarocks_list_options", list_options)

local remove_options = parse_help "remove"
write_options("__dromozoa_luarocks_remove_options", remove_options)
print(dumper.encode(remove_options, { pretty = true }))