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
local shell = require "dromozoa.commons.shell"

program_description = "(no program description)"

util.this_program = function ()
  return "luarocks"
end

local printout_buffer
util.printout = function (...)
  printout_buffer[#printout_buffer + 1] = table.concat({...}, "\t")
end

local deps_modes = {}

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

local function each_option(opts)
  local names = {}
  for name in pairs(opts) do
    names[#names + 1] = name
  end
  table.sort(names)
  return coroutine.wrap(function ()
    for i = 1, #names do
      coroutine.yield(opts[names[i]])
    end
  end)
end

local function make_option(opt)
  local name = opt.name
  local arg = opt.arg
  local desc = opt.desc

  local option = "--" .. opt.name
  if arg ~= true then
    arg = arg:gsub([[^"(.-)"$]], "%1")
    arg = arg:gsub([[^%<(.-)%>$]], "%1")
    option = option .. "="
  end
  if desc then
    assert(not desc:find "]")
    option = option .. "[" .. desc .. "]"
  end
  if arg ~= true then
    option = option .. ":" .. arg
  end
  if arg == "mode" then
    assert(name == "deps-mode")
    option = option .. ":(("
    for i = 1, #deps_modes do
      local deps_mode = deps_modes[i]
      local mode = deps_mode.mode
      local desc = deps_mode.desc
      if i > 1 then
        option = option .. " "
      end
      assert(not desc:find [["]])
      option = option .. mode .. [[\:"]] .. desc .. [["]]
    end
    option = option .. "))"
  elseif arg == "file" or arg == "path" then
    option = option .. ":_files"
  elseif arg == "server" then
    option = option .. ":_hosts"
  elseif arg == "url" then
    option = option .. ":_urls"
  end
  return option
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

local general_opts = {}

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
      general_opts[name] = {
        name = name;
        arg = assert(supported_flags[name]);
        desc = desc;
      }
    end
  end
end

for i = 1, #names do
  local name = names[i]
  local module = modules[name]
  local arguments = module.help_arguments
  if arguments == nil then
    arguments = "<argument>"
  end
  local help = module.help

  local opts = {}
  local args = {}
  module.opts = opts
  module.args = args

  for item in arguments:gmatch "[%w%-<=>_]+" do
    local name = item:match "^%-%-([%w%-]+)"
    if name then
      opts[name] = {
        name = name;
        arg = assert(supported_flags[name]);
      }
    else
      args[#args + 1] = assert(item:match "^<([^>]*)>$")
    end
  end

  local paragraphs = parse_help(help)
  for j = 1, #paragraphs do
    local paragraph = paragraphs[j]
    paragraph = paragraph:gsub("^(%-%-deps%-mode.-%.).*", "%1")
    local name, desc = paragraph:match "^%-%-(%S+)%s+(.*)$"
    name = name:gsub("=.*", "")
    opts[name] = {
      name = name;
      arg = assert(supported_flags[name]);
      desc = desc;
    }
  end
end

local indent
for line in util.deps_mode_help():gmatch "[^\n]*" do
  local sp, mode, desc = line:match "^( +)%* (%w+) %- (.*)"
  if sp then
    indent = #sp + 2
    deps_modes[#deps_modes + 1] = {
      mode = mode;
      desc = desc;
    }
  else
    local sp, desc = line:match "^( +)(.*)"
    if sp and #sp == indent then
      local deps_mode = deps_modes[#deps_modes]
      deps_mode.desc = deps_mode.desc .. " " .. desc
    end
  end
end

local out = assert(io.open("zshfuncs/_dromozoa_luarocks_options", "w"))
out:write [[
#autoload
_dromozoa_luarocks_options() {
  options=(
    $options
]]

for opt in each_option(general_opts) do
  out:write(([[
    %s
]]):format(shell.quote(make_option(opt))))
end

out:write [[
  )

  case x$1 in
]]

for i = 1, #names do
  local name = names[i]
  local module = modules[name]
  local opts = module.opts
  if next(opts) ~= nil then
    out:write(([[
    x%s)
      options=(
        $options
]]):format(name))

    for opt in each_option(opts) do
      out:write(([[
        %s
]]):format(shell.quote(make_option(opt))))
    end

      out:write [[
      )
      ;;
]]
  end
end

out:write [[
  esac
}
]]

out:close()

local out = assert(io.open("zshfuncs/_dromozoa_luarocks_commands", "w"))
out:write [[
#autoload
_dromozoa_luarocks_commands() {
  arguments=(
    $arguments
]]

for i = 1, #names do
  local name = names[i]
  local module = modules[name]
  local summary = assert(module.help_summary)
  out:write(([[
    %s
]]):format(shell.quote(name .. ":" .. summary)))
end

out:write [[
  )
}
]]

out:close()

local out = assert(io.open("zshfuncs/_dromozoa_luarocks_arguments", "w"))
out:write [[
#autoload
_dromozoa_luarocks_arguments() {
  case x$1 in
]]

for i = 1, #names do
  local name = names[i]
  local module = modules[name]
  local args = module.args
  if next(args) ~= nil then
    out:write(([[
    x%s)
      arguments=($arguments %s);;
]]):format(name, shell.quote(": :_luarocks_arguments " .. table.concat(args, " "))))
  end
end

out:write [[
  esac
}
]]

out:close()
