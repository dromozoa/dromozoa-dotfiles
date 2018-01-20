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

local mock = require "dromozoa.vim.mock"
local buffer = require "dromozoa.vim.mock.buffer"

local vim = mock(buffer [[
foo
bar
baz
qux
]], {
  line = 3;
  col = 2;
}, {
  ["&textwidth"] = 60;
})

local b = vim.buffer()
assert(b[1] == "foo")
assert(b[2] == "bar")
assert(b[3] == "baz")
assert(b[4] == "qux")
assert(vim.eval "&textwidth" == 60)
