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
local length = require "dromozoa.vim.length"
local mock = require "dromozoa.vim.mock"
local buffer = require "dromozoa.vim.mock.buffer"

local b = buffer [[
あいうえお
あいうえおかきくけこ
あいうえおかきくけこさしすせそ
あいうえおかきくけこさしすせそたちつてと
あいうえおかきくけこさしすせそたちつてとなにぬねの


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

  あいうえお
あいうえおかきくけこ
あいうえおかきくけこさしすせそ
あいうえおかきくけこさしすせそたちつてと
あいうえおかきくけこさしすせそたちつてとなにぬねの
]]

local vim = mock(b, {
  ["v:lnum"] = 2;
  ["v:count"] = length(b) - 1;
  ["&textwidth"] = 20;
})

format(vim)

io.write(tostring(vim.buffer()))
