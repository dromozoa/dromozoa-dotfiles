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

local util = require "luarocks.util"

program_description = "(no program description)"

util.this_program = function ()
  return "luarocks"
end

local state = 1

local printout_buffer
util.printout = function (...)
  printout_buffer[#printout_buffer + 1] = table.concat({...}, "\t")
end

local function parse_help(content)
  local paragraphs = {}
  local paragraph
  local state = 1
  for line in content:gmatch "[^\n]*" do
    if line:find "^%s*%-%-" then
      state = 2
      paragraph = { (line:gsub("^%s*", "")) }
      paragraphs[#paragraphs + 1] = paragraph
    elseif state == 2 then
      if line:find "^%s*$" then
        state = 1
        paragraph = nil
      else
        paragraph[#paragraph + 1] = line:gsub("^%s*", "")
      end
    end
  end
  for i = 1, #paragraphs do
    paragraphs[i] = table.concat(paragraphs[i], " ")
  end
  return paragraphs
end

local filename = assert(package.searchpath("luarocks.util", package.path))
local handle = assert(io.open(filename))
local content = handle:read "*a"
handle:close()
local chunk = "return " .. assert(content:match "\nlocal supported_flags = ({.-})\n")
local supported_flags = assert(assert(load(chunk))())

for item in os.getenv "PATH":gmatch "[^:]*" do
  if item == "" then
    item = "./luarocks"
  else
    item = item .. "/luarocks"
  end
  local handle = io.open(item)
  if handle then
    local script
    for line in handle:lines() do
      script = line:match [[^exec .- '([^']+)' "%$@"$]]
      if script then
        break
      end
    end
    handle:close()
    assert(script)

    local handle = assert(io.open(script))
    local content = handle:read "*a"
    handle:close()
    local chunk = "return " .. assert(content:match "\ncommands = ({.-})\n")
    commands = assert(assert(load(chunk))())
    break
  end
end

local names = {}
local modules = {}
for name, module in pairs(commands) do
  names[#names + 1] = name
  modules[name] = require(module)
end
table.sort(names)

printout_buffer = {}
modules.help.command()

local general_options = {}

local state = 1
for i = 1, #printout_buffer do
  local buffer = printout_buffer[i]
  if buffer == "\nGENERAL OPTIONS" then
    state = 2
  elseif buffer == "\nVARIABLES" then
    state = 1
  elseif state >= 2 then
    local paragraphs = parse_help(buffer)
    for j = 1, #paragraphs do
      local paragraph = paragraphs[j]
      local name, desc = paragraph:match "^%-%-(%S+)%s+(.*)$"
      name = name:gsub("=.*", "")
      general_options[name] = {
        arg = assert(supported_flags[name]);
        desc = desc;
      }
    end
  end
end

for i = 1, #names do
  local name = names[i]
  local module = modules[name]
  local summary = assert(module.help_summary)
  local arguments = module.help_arguments
  if arguments == nil then
    arguments = "<argument>"
  end
  local help = module.help

  local options = {}
  module.options = options

  for name in arguments:gmatch "%-%-([%w%-]+)" do
    options[name] = {
      arg = assert(supported_flags[name]);
      desc = "(no description)";
    }
  end

  local paragraphs = parse_help(help)
  for j = 1, #paragraphs do
    local paragraph = paragraphs[j]
    paragraph = paragraph:gsub("^(%-%-deps%-mode.-%.).*", "%1")
    local name, desc = paragraph:match "^%-%-(%S+)%s+(.*)$"
    name = name:gsub("=.*", "")
    options[name] = {
      arg = assert(supported_flags[name]);
      desc = desc;
    }
  end
end
