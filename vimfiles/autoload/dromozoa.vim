function! dromozoa#format()
  if has("lua")
    return luaeval('require "dromozoa.vim.format" ()')
  else
    return 1
  endif
endfunction
