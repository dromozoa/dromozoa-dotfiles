-- Copyright (C) 2018,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
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

local byte = string.byte
local concat = table.concat

local encode_table = {
  [62] = "+";
  [63] = "/";
}

for i = 0, 25 do
  encode_table[i] = string.char(i + 65)
end
for i = 26, 51 do
  encode_table[i] = string.char(i + 71)
end
for i = 52, 61 do
  encode_table[i] = string.char(i - 4)
end

return function (source)
  local n = #source
  local i = 1
  local buffer = {}

  for j = 3, n, 3 do
    local a, b, c = byte(source, j - 2, j)
    local a = a * 65536 + b * 256 + c
    local d = a % 64
    local a = (a - d) / 64
    local c = a % 64
    local a = (a - c) / 64
    local b = a % 64
    local a = (a - b) / 64
    buffer[i] = encode_table[a]
    buffer[i + 1] = encode_table[b]
    buffer[i + 2] = encode_table[c]
    buffer[i + 3] = encode_table[d]
    i = i + 4
  end

  local j = n % 3
  if j > 0 then
    local a, b = byte(source, n + 1 - j, n)
    if b then
      local a = a * 1024 + b * 4
      local c = a % 64
      local a = (a - c) / 64
      local b = a % 64
      local a = (a - b) / 64
      buffer[i] = encode_table[a]
      buffer[i + 1] = encode_table[b]
      buffer[i + 2] = encode_table[c]
      buffer[i + 3] = "="
    else
      local a = a * 16
      local b = a % 64
      local a = (a - b) / 64
      buffer[i] = encode_table[a]
      buffer[i + 1] = encode_table[b]
      buffer[i + 2] = "=="
    end
  end

  return concat(buffer)
end
