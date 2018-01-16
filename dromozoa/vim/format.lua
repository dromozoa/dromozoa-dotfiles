return function ()
  local out = io.open("/tmp/test.log", "a")
  local lnum = vim.eval "v:lnum"
  local count = vim.eval "v:count"
  local char = vim.eval "v:char"
  local v = vim.dict("v")
  out:write(([[
============================================================
firstline: %s
lastline: %s
lnum: %s
count: %s
char: %q
]]):format(vim.firstline, vim.lastline, lnum, count, char))
  out:close()
  return "0"
end
