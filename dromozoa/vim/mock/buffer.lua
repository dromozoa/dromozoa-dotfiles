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

-- http://vim-jp.org/vimdoc-ja/if_lua.html#lua-buffer

local private_impl = function () end

local class = {}
local metatable = {}

function class:insert(newline, pos)
  local impl = self[private_impl]
  if pos == nil then
    pos = #impl
  end
  table.insert(impl, pos + 1, newline)
end

function metatable:__len(newline, pos)
  local impl = self[private_impl]
  return #impl
end

function metatable:__index(key)
  local impl = self[private_impl]
  local value = impl[key]
  if value == nil then
    return class[key]
  else
    return value
  end
end

function metatable:__newindex(key, value)
  local impl = self[private_impl]
  if value == nil then
    table.remove(impl, key)
  else
    impl[key] = value
  end
end

return setmetatable(class, {
  __call = function (_, text)
    local impl = {}
    if text ~= nil and text ~= "" then
      if not text:find "\n$" then
        text = text .. "\n"
      end
      for line in text:gmatch "(.-)\n" do
        impl[#impl + 1] = line
      end
    end
    return setmetatable({ [private_impl] = impl }, metatable)
  end;
})
