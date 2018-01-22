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

local format = require "dromozoa.vim.format"
local mock = require "dromozoa.vim.mock"
local buffer = require "dromozoa.vim.mock.buffer"

local b = buffer [[
あいうえお
　かきくけこかきくけこ
　さしすせそさしすせそさしすせそ
たちつてとたちつてとたちつてとたちつてと
なにぬねのなにぬねのなにぬねのなにぬねのなにぬねの


あいうえお    
    あいうえおかきくけこ	
    あいうえおかきくけこさしすせそ
    あいうえおかきくけこさしすせそたちつてと
    あいうえおかきくけこさしすせそたちつてとなにぬねの

   Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
   tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim
   veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea
   commodo consequat. Duis aute irure dolor in reprehenderit in voluptate
   velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
   cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id
   est laborum.

This is a pen.
This is a pen.
This is a pen.

      foo baaaaaaaaaaaaaaaaaaaaaaaaaaaaaar baz

あいうえおかきくけこさしすせそ、
たちつてとなにぬねのはひふへほ。

あいうえおかきくけこさしす「『【せそ】』」たちつてとなにぬねの。

かきくけこかきくけこさしすせ……そたちつてとなにぬねの。


  あいうえお
かきくけこかきくけこ
さしすせそさしすせそさしすせそ
たちつてとたちつてとたちつてとたちつてと
なにぬねのなにぬねのなにぬねのなにぬねのなにぬねの
]]

local vim = mock(b, {}, {
  ["v:lnum"] = 2;
  ["v:count"] = b:size() - 2;
  ["v:char"] = "";
  ["&filetype"] = "text";
  ["&textwidth"] = 30;
})

format(vim)

io.write(b:text())

for i = 1, b:size() do
  assert(not b[i]:find "%s$")
end

local b = buffer [[
あ
い
う
え
お
か
き
く
け
こ
]]

local vim = mock(b, {}, {
  ["v:lnum"] = 3;
  ["v:count"] = b:size() - 4;
  ["v:char"] = "";
  ["&filetype"] = "text";
  ["&textwidth"] = 30;
})

format(vim)

assert(b:text() == [[
あ
い
うえおかきく
け
こ
]])

local b = buffer [[
あいうえ『 「
おかきくけこ
]]

local vim = mock(b, {}, {
  ["v:lnum"] = 1;
  ["v:count"] = b:size();
  ["v:char"] = "";
  ["&filetype"] = "text";
  ["&textwidth"] = 10;
})

format(vim)

assert(b:text() == [[
あいうえ
『 「おか
きくけこ
]])
