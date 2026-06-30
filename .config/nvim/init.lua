-- Copyright (C) 2026 Tomoyuki Fujimori <moyu@dromozoa.com>
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

require "lsp"

local opt = vim.opt

opt.mouse = ""

opt.ambiwidth = "double"
opt.fileformats = { "unix", "dos", "mac" }
opt.fileencodings = { "ucs-bom", "utf-8", "cp932", "euc-jp", "utf-16" }

opt.autoindent = true
opt.expandtab = true
opt.shiftwidth = 2
opt.softtabstop = 2

opt.wrap = false
opt.formatoptions:append("nmM")
opt.breakindent = true

opt.number = true
opt.list = true
opt.listchars = {
  tab = "__",
  trail = "_",
  precedes = "<",
  extends = ">",
}
opt.laststatus = 2
opt.statusline = [[%F\ %m%r%h%w%y%{'['.&fileencoding.']['.&fileformat.']'}%=[%l,%c][U+%04B]]

opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.smartcase = true
opt.updatetime = 1000
opt.autowrite = true

opt.debug = "msg"
opt.clipboard = "unnamed"
opt.modeline = true
opt.modelines = 5
opt.wildmode = { "longest", "list" }

vim.cmd "packadd! matchit"
vim.cmd "syntax enable"
vim.cmd "filetype plugin on"

vim.cmd "colorscheme darkblue"
vim.api.nvim_set_hl(0, "Normal", { ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "Underlined", { ctermfg = "LightBlue" })
vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { link = "Normal" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", { underline = false })

local wall_group = vim.api.nvim_create_augroup("wall", { clear = true })
vim.api.nvim_create_autocmd("InsertLeave", {
  group = wall_group,
  pattern = "*",
  command = "silent! wall",
})
vim.api.nvim_create_autocmd("CursorHold", {
  group = wall_group,
  pattern = "*",
  command = "silent! wall",
})

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "j", "gj", opts)
vim.keymap.set("n", "k", "gk", opts)
vim.keymap.set("n", "<C-p>", "<Cmd>bprev<CR>", opts)
vim.keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", opts)

local inside_gnu_screen = (vim.env.STY or "") ~= "" or (vim.env.TERM or ""):find "^screen"
if inside_gnu_screen then
  local termfeatures = vim.g.termfeatures or {}
  termfeatures.osc52 = false
  vim.g.termfeatures = termfeatures
end

vim.api.nvim_create_user_command("EvalProcess", function(args)
  local result = vim.system(args.fargs, {
    stdin = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2, false),
    text = true,
  }):wait()
  if result.code == 0 then
    vim.cmd(result.stdout)
  else
    vim.notify(result.stderr, vim.log.levels.ERROR)
  end
end, {
  nargs = "+",
  range = "%",
  complete = "shellcmdline",
})

vim.api.nvim_create_user_command("CopenRight", function()
  local width = math.max(50, math.floor(vim.api.nvim_win_get_width(0) * 0.5))
  vim.cmd("botright vertical " .. width .. " copen")
end, {})
