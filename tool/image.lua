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

local utf8 = require "dromozoa.utf8"
local png = require "dromozoa.png"

local mode = ...

--[[
for code = 0x2580, 0x259F do
  local char = utf8.char(code)
  io.write(("U+%04X %s%s%s%s\n"):format(code, char, char, char, char))
end
]]

--[[
local TL = utf8.char(0x2598)
local TR = utf8.char(0x259D)
local BL = utf8.char(0x2596)
local BR = utf8.char(0x2597)

local chars = { TL, TR, BL, BR }
for i = 1, #chars do
  local char = chars[i]
  io.write(char, char, char, char)
  if i == #chars then
    io.write "\n"
  else
    io.write "\27[4D"
  end
end

local UPPER_HALF_BLOCK = utf8.char(0x2580)
local LOWER_HALF_BLOCK = utf8.char(0x2584)
]]

local reader = assert(png.reader())
local handle = assert(io.open("docs/lena_std.png", "rb"))
assert(reader:set_read_fn(function (n)
  return handle:read(n)
end))

assert(reader:read_png(png.PNG_TRANSFORM_EXPAND + (png.PNG_TRANSFORM_SCALE_16 or png.PNG_TRANSFORM_STRIP_16)))

local width = assert(reader:get_image_width())
local height = assert(reader:get_image_height())

if mode == "24bit" then
  for y = 1, height do
    local row = assert(reader:get_row(y))
    for i = 1, width * 4, 4 do
      local r, g, b = row:byte(i, i + 2)
      io.write(("\27[48;2;%d;%d;%dm  "):format(r, g, b))
    end
    io.write "\27[0m\n"
  end
end

if mode == "8bit" then
  for y = 1, height do
    local row = assert(reader:get_row(y))
    for i = 1, width * 4, 4 do
      local r, g, b = row:byte(i, i + 2)
      r = math.floor(r * 6 / 256)
      g = math.floor(g * 6 / 256)
      b = math.floor(b * 6 / 256)
      io.write("\27[48;5;", 16 + r * 36 + 6 * g + b, "m  ")
    end
    io.write "\27[0m\n"
  end
end
