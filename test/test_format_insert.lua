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

local format = require "dromozoa.vim.format"
local mock = require "dromozoa.vim.mock"
local buffer = require "dromozoa.vim.mock.buffer"

local b = buffer [[
12345678901234567890
foo bar baz XXXX foo 
vim: set textwidth=20:
]]

local vim = mock(b, {
  line = 2;
  col = 22;
}, {
  ["v:lnum"] = 2;
  ["v:count"] = 1;
  ["v:char"] = "a";
  ["&filetype"] = "text";
  ["&textwidth"] = 20;
})

format(vim)

assert(b:text() == [[
12345678901234567890
foo bar baz XXXX foo

vim: set textwidth=20:
]])

local b = buffer [[
「ほ」と「ま」の間に「ア」を挿入するテストを行う

あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめも

]]

local w = {
  line = 3;
  col = 91;
}

local vim = mock(b, w, {
  ["v:lnum"] = 3;
  ["v:count"] = 1;
  ["v:char"] = "ア";
  ["&filetype"] = "text";
  ["&textwidth"] = 60;
})

format(vim)
print(w.line, w.col)
assert(w.col == 1)
