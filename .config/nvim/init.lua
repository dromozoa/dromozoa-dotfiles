-- 旧: set runtimepath^=~/dromozoa-dotfiles/vimfiles
-- vim.opt.runtimepath:prepend(vim.fn.expand("~/dromozoa-dotfiles/vimfiles"))

-- 旧: let g:netrw_home="~/.vim"
-- vim.g.netrw_home = vim.fn.expand("~/.vim")

-- 自作Luaモジュールを置くなら、将来的には
-- ~/.config/nvim/lua/ 以下へ寄せるほうが自然。
-- 旧互換で外部ディレクトリを使うなら package.path を調整する。
-- package.path = table.concat({
--   vim.fn.expand("~/dromozoa-dotfiles/?.lua"),
--   package.path,
-- }, ";")

-- -------------------------------------------------------------------
-- options
-- -------------------------------------------------------------------

local opt = vim.opt

opt.ambiwidth = "double"
opt.fileformats = { "unix", "dos", "mac" }
opt.fileencodings = { "ucs-bom", "utf-8", "sjis", "euc-jp", "utf-16" }

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

opt.autowrite = true
opt.updatetime = 200

opt.debug = "msg"
opt.clipboard = "unnamed"
opt.modeline = true
opt.modelines = 5
opt.wildmode = { "list", "longest" }

-- -------------------------------------------------------------------
-- runtime features
-- -------------------------------------------------------------------

vim.cmd "packadd! matchit"
vim.cmd "syntax enable"
vim.cmd "filetype plugin on"

-- -------------------------------------------------------------------
-- colors / highlight
-- -------------------------------------------------------------------

vim.cmd "colorscheme darkblue"
vim.api.nvim_set_hl(0, "Normal", { ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "Underlined", { ctermfg = "LightBlue" })

-- -------------------------------------------------------------------
-- autocommands
-- -------------------------------------------------------------------

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

local ft_group = vim.api.nvim_create_augroup("filetype_local_options", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "html",
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "text",
  callback = function()
    vim.opt_local.textwidth = 60
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = ft_group,
  pattern = "lua",
  callback = function()
    vim.cmd("syntax sync minlines=500 maxlines=1000")
  end,
})

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "j", "gj", opts)
map("n", "k", "gk", opts)
map("n", "<C-p>", "<Cmd>bprev<CR>", opts)
map("n", "<C-n>", "<Cmd>bnext<CR>", opts)
