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

local names = {
  "black",
  "red",
  "green",
  "yellow",
  "blue",
  "magenta",
  "cyan",
  "white"
}

local function SGR(n)
  return "\27[" .. n .. "m"
end

io.write [[
ESC[<n>m
|         | FG BG 8 |             | FG  BG  8 |             |
|---------|---------|-------------|-----------|-------------|
]]
for i = 1, #names do
  local x = 29 + i
  local y = 89 + i
  local s = "foo bar baz"
  io.write(("| %-7s | %d %d %d | %s%s%s | %d %d %2d | %s%s%s |\n"):format(
      names[i],
      x, x + 10, i - 1, SGR(x), s, SGR(0),
      y, y + 10, i + 7, SGR(y), s, SGR(0)))
end

io.write [[

FG=ESC[38;5;<n>m
BG=ESC[48;5;<n>m
]]

for i = 0, 2 do
  io.write [[
|     |   0   1   2   3   4   5 |     |   0   1   2   3   4   5 |
|-----|-------------------------|-----|-------------------------|
]]
  for g = 0, 5 do
    local r = i
    io.write(("| %3d |"):format(16 + 36 * r + 6 * g))
    for b = 0, 5 do
      local x = 16 + 36 * r + 6 * g + b
      local s = "A"
      io.write((" %s%s%s"):format(SGR("38;5;" .. x), "foo", SGR(0)))
    end
    local r = i + 3
    io.write((" | %3d |"):format(16 + 36 * r + 6 * g))
    for b = 0, 5 do
      local x = 16 + 36 * r + 6 * g + b
      local s = "A"
      io.write((" %s%s%s"):format(SGR("38;5;" .. x), "foo", SGR(0)))
    end
    io.write " |\n"
  end
end
