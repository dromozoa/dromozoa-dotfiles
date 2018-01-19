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

-- https://www.w3.org/TR/jlreq/
-- https://www.w3.org/TR/jlreq/ja/

local json = require "dromozoa.commons.json"
local read_file = require "dromozoa.commons.read_file"

local source_filename = "docs/jlreq.json"

local source = assert(json.decode(assert(read_file(source_filename))))
for i = 1, #source do
  local class = source[i]
  print(class.id)
end
