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

local buffer = require "dromozoa.vim.mock.buffer"

local b = buffer()

b:insert "foo"
b:insert "bar"
b:insert "baz"
b:insert "qux"

b:insert("INSERT 1")
b:insert("INSERT 2")
b:insert("INSERT 3")

b:insert("INSERT 4", 0)
b:insert("INSERT 5", 0)
b:insert("INSERT 6", 0)

local n = b:size() - 3
b:insert("INSERT 7", n)
b:insert("INSERT 8", n + 1)
b:insert("INSERT 9", n + 2)

assert(b:text() == [[
INSERT 6
INSERT 5
INSERT 4
foo
bar
baz
qux
INSERT 7
INSERT 8
INSERT 9
INSERT 1
INSERT 2
INSERT 3
]])

b[1] = nil
b[2] = nil
b[3] = nil

assert(b:text() == [[
INSERT 5
foo
baz
qux
INSERT 7
INSERT 8
INSERT 9
INSERT 1
INSERT 2
INSERT 3
]])

for i = 1, b:size(), 2 do
  b[i] = b[i] .. " " .. b[i]
end

assert(b:text() == [[
INSERT 5 INSERT 5
foo
baz baz
qux
INSERT 7 INSERT 7
INSERT 8
INSERT 9 INSERT 9
INSERT 1
INSERT 2 INSERT 2
INSERT 3
]])
