" http://vim-jp.org/vimdoc-ja/options.html

set fileformats=unix,dos,mac
set fileencodings=ucs-bom,utf-8,utf-16,sjis,euc-jp

set autoindent
set expandtab
set shiftwidth=2
set softtabstop=2

set wildmode=list:longest

set nowrap
set formatoptions+=nmM
"set textwidth=60

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
set statusline=%F\ %m%r%h%w%y%q%{'['.&fileencoding.']['.&fileformat.']'}%=[%l,%c][U+%04B]

set list
set listchars=tab:__,trail:_,precedes:<,extends:>

" set modeline
set modelines=5

set clipboard=unnamed

syntax enable
colorscheme darkblue

nnoremap j gj
nnoremap k gk
