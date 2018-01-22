#! /usr/bin/env lua

local handle = assert(io.popen("luarocks help"))

local state
local commands = {}

io.write [[
  local -a luarocks_commands
  luarocsk_commands=(
]]
for line in handle:lines() do
  if line:find "^%a" then
    state = line
  elseif state == "COMMANDS" then
    local head, body = line:match "^(\t+)(.*)"
    if head then
      if #head == 1 then
        commands[#commands + 1] = { body }
      else
        assert(#head == 2)
        local command = commands[#commands]
        assert(#command == 1)
        command[2] = body:match ".-%."
        io.write(("    '%s:%s'\n"):format(command[1], command[2]))
      end
    end
  end
end
io.write [[
  )
]]
