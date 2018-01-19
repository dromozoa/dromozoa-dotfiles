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

local map = {}
for i = 1, 19 do
  map[i] = require(("dromozoa.vim.jlreq.is_cl%02d"):format(i))
end
for i = 24, 29 do
  map[i] = require(("dromozoa.vim.jlreq.is_cl%02d"):format(i))
end

local class = {}

function class.is_class(char, ...)
  local ids = { ... }
  for i = 1, #ids do
    if map[ids[i]](char) then
      return true
    end
  end
  return false
end

function class.is_line_start_prohibited(char)
  return class.is_class(char, 2, 3, 4, 5, 6, 7, 9, 10, 11, 29)
end

function class.is_line_end_prohibited(char)
  return class.is_class(char, 1, 28)
end

return class
