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

local ucd = require "dromozoa.ucd"
local utf8 = require "dromozoa.utf8"
local png = require "dromozoa.png"

local mode, filename = ...

if mode == "char" then
  io.write [[
| code   | eaw | chars    |
|--------|-----|----------|
]]
  for code = 0x2580, 0x259F do
    local char = utf8.char(code)
    local eaw = ucd.east_asian_width(code)
    assert(eaw == "A" or eaw == "N")
    local chars
    if eaw == "A" then
      chars = char:rep(4)
    else
      chars = char:rep(8)
    end
    io.write(("| U+%04X |  %-2s | %s |\n"):format(code, eaw, chars))
  end
  os.exit()
end

local reader = assert(png.reader())
local handle = assert(io.open(filename, "rb"))
assert(reader:set_read_fn(function (n)
  return handle:read(n)
end))

assert(reader:read_png(png.PNG_TRANSFORM_EXPAND + (png.PNG_TRANSFORM_SCALE_16 or png.PNG_TRANSFORM_STRIP_16)))

local width = assert(reader:get_image_width())
local height = assert(reader:get_image_height())

if mode == "24bit" then
  local pixel = " "
  if width == height then
    pixel = "  "
  end
  for y = 1, height do
    local row = assert(reader:get_row(y))
    for i = 1, width * 4, 4 do
      local r, g, b = row:byte(i, i + 2)
      io.write(("\27[48;2;%d;%d;%dm"):format(r, g, b), pixel)
    end
    io.write "\27[0m\n"
  end
elseif mode == "8bit" then
  local pixel = " "
  if width == height then
    pixel = "  "
  end
  local d = 256 / 6
  for y = 1, height do
    local row = assert(reader:get_row(y))
    for i = 1, width * 4, 4 do
      local r, g, b = row:byte(i, i + 2)
      r = math.floor(r / d)
      g = math.floor(g / d)
      b = math.floor(b / d)
      io.write("\27[48;5;", 16 + r * 36 + 6 * g + b, "m", pixel)
    end
    io.write "\27[0m\n"
  end
elseif mode == "8bit-tile" then
  local pixel = utf8.char(0x259A)
  if width == height then
    pixel = pixel .. pixel
  end
  local d = 256 / 6
  local function e(u, v)
    local a = u - v
    if a < -0.5 and v > 1 then
      return v - 1
    elseif a > 0.5 and v < 5 then
      return v + 1
    else
      return v
    end
  end
  for y = 1, height do
    local row = assert(reader:get_row(y))
    for i = 1, width * 4, 4 do
      local r, g, b = row:byte(i, i + 2)
      local r1 = math.floor(r / d)
      local g1 = math.floor(g / d)
      local b1 = math.floor(b / d)
      local fg = 16 + r1 * 36 + 6 * g1 + b1
      local r2 = e(r, r1)
      local g2 = e(g, g1)
      local b2 = e(b, b1)
      local bg = 16 + r2 * 36 + 6 * g2 + b2
      io.write("\27[38;5;", fg, ";48;5;", bg, "m", pixel)
    end
    io.write "\27[0m\n"
  end
end
