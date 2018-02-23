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

local json = require "dromozoa.commons.json"
local read_file = require "dromozoa.commons.read_file"
local builder = require "dromozoa.ucd.builder"

local source_filename = "docs/jlreq.json"

local check = {}

local source = assert(json.decode(assert(read_file(source_filename))))
for i = 1, #source do
  local class = source[i]
  local id = tonumber(class.id:match "^cl%-(%d+)", 10)
  local name = class.name
  local data = class.data

  local code_filename = ("dromozoa/vim/jlreq/is_cl%02d.lua"):format(id)
  local _ = builder(false)

  for j = 1, #data do
    local item = data[j]
    local code = item.code

    if code:find "^%x+$" then
      local code = tonumber(code, 16)
      _:range(code, code, true)
    else
      -- ignore combining character
    end
  end

  local out = assert(io.open(code_filename, "w"))
  _.compile(out, _:build()):close()
end
