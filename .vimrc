" http://vim-jp.org/vimdoc-ja/options.html

set runtimepath+=~/dromozoa-dotfiles/vimfiles

set fileformats=unix,dos,mac
set fileencodings=ucs-bom,utf-8,utf-16,sjis,euc-jp

set autoindent
set expandtab
set shiftwidth=2
set softtabstop=2

set wildmode=list:longest

set nowrap
set formatoptions+=nmM

if exists("&breakindent")
  set breakindent
endif

set hlsearch
set incsearch
set ignorecase
set smartcase

set nobackup
set noswapfile

set number
set laststatus=2
set statusline=%F\ %m%r%h%w%y%{'['.&fileencoding.']['.&fileformat.']'}%=[%l,%c][U+%04B]

set list
set listchars=tab:__,trail:_,precedes:<,extends:>

set modelines=5

set clipboard=unnamed

" http://vim-jp.org/vimdoc-ja/syntax.html

syntax enable
colorscheme darkblue

" http://vim-jp.org/vimdoc-ja/filetype.html

filetype plugin on

nnoremap j gj
nnoremap k gk

autocmd FileType text setlocal textwidth=60 wrap formatexpr=dromozoa#format()

if has("lua")
  let $LUA_PATH = $HOME . "/dromozoa-dotfiles/?.lua;;"
endif
