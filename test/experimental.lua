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

local length = require "dromozoa.vim.length"

local function test_buffer(out)
  local b = vim.buffer()
  out:write(([[
============================================================
#b = %d
------------------------------------------------------------
%s
]]):format(#b, table.concat(b, "\n")))

  b:insert("INSERT 1")
  b:insert("INSERT 2")
  b:insert("INSERT 3")

  b:insert("INSERT 4", 0)
  b:insert("INSERT 5", 0)
  b:insert("INSERT 6", 0)

  local n = #b - 3
  b:insert("INSERT 7", n)
  b:insert("INSERT 8", n + 1)
  b:insert("INSERT 9", n + 2)

  out:write(([[
============================================================
#b = %d
------------------------------------------------------------
%s
]]):format(#b, table.concat(b, "\n")))

  b[1] = nil
  b[2] = nil
  b[3] = nil

  out:write(([[
============================================================
#b = %d
------------------------------------------------------------
%s
]]):format(#b, table.concat(b, "\n")))

  for i = 1, #b, 2 do
    b[i] = b[i] .. " " .. b[i]
  end

  out:write(([[
============================================================
#b = %d
------------------------------------------------------------
%s
]]):format(#b, table.concat(b, "\n")))

end

local function test_eval(out)
  local options = {
    vim.eval "&autoindent";
    vim.eval "&wrap";
    vim.eval "&formatoptions";
    vim.eval "&shiftwidth";
    vim.eval "&textwidth";
  }

  out:write([[
============================================================
]])
  for i = 1, #options do
    local option = options[i]
    out:write(("%s %s %s\n"):format(type(option), vim.type(option), option))
  end
end

local function test_length(out)
  out:write(([[
============================================================
buffer length = %d
]]):format(length(vim.buffer())))
end

return function ()
  local out = io.open("/tmp/test.log", "a")
  -- test_buffer(out)
  -- test_eval(out)
  test_length(out)
  out:close()
end
