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
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-dotfiles. If not, see <https://www.gnu.org/licenses/>.

local json = require "dromozoa.commons.json"
local read_file = require "dromozoa.commons.read_file"
local builder = require "dromozoa.ucd.builder"

local source_filename = "docs/jlreq.json"

local names = {
  is_line_start_prohibited = { 2, 3, 4, 5, 6, 7, 9, 10, 11, 29 };
  is_line_end_prohibited = { 1, 28 };
  is_inseparable = { 8 };
  is_prefixed_abbreviation = { 12 };
  is_postfixed_abbreviation = { 13 };
}

local builders = {};
for k, v in pairs(names) do
  local _ = builder(false)
  v._ = _
  for i = 1, #v do
    builders[v[i]] = _
  end
end

local source = assert(json.decode(assert(read_file(source_filename))))
for i = 1, #source do
  local class = source[i]
  local id = tonumber(class.id:match "^cl%-(%d+)", 10)
  local _ = builders[id]
  if _ then
    local data = class.data
    for j = 1, #data do
      local item = data[j]
      local code = item.code
      if code:find "^%x+$" then
        local code = tonumber(code, 16)
        _:range(code, code, true)
      else
        io.write("ignore combining character sequence ", code, "\n")
      end
    end
  end
end

for k, v in pairs(names) do
  local _ = v._
  local result_filename = ("dromozoa/text/%s.lua"):format(k)
  local out = assert(io.open(result_filename, "w"))
  _.compile(out, _:build()):close()
end
