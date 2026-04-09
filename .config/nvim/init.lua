require "lsp"

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
  tab = "__";
  trail = "_";
  precedes = "<";
  extends = ">";
}
opt.laststatus = 2
opt.statusline = [[%F\ %m%r%h%w%y%{'['.&fileencoding.']['.&fileformat.']'}%=[%l,%c][U+%04B]]

opt.hlsearch = true
opt.ignorecase = true
opt.incsearch = true
opt.smartcase = true
opt.autowrite = true

opt.debug = "msg"
opt.clipboard = "unnamed"
opt.modeline = true
opt.modelines = 5
opt.wildmode = { "list", "longest" }

vim.cmd "packadd! matchit"
vim.cmd "syntax enable"
vim.cmd "filetype plugin on"

vim.cmd "colorscheme darkblue"
vim.api.nvim_set_hl(0, "Normal", { ctermbg = "NONE" })
vim.api.nvim_set_hl(0, "Underlined", { ctermfg = "LightBlue" })

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "j", "gj", opts)
vim.keymap.set("n", "k", "gk", opts)
vim.keymap.set("n", "<C-p>", "<Cmd>bprev<CR>", opts)
vim.keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", opts)
