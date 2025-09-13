" Copyright (C) 2018,2019,2022-2025 Tomoyuki Fujimori <moyu@dromozoa.com>
"
" This file is part of dromozoa-dotfiles.
"
" dromozoa-dotfiles is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" dromozoa-dotfiles is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with dromozoa-dotfiles. If not, see <https://www.gnu.org/licenses/>.

set runtimepath^=~/dromozoa-dotfiles/vimfiles
let g:netrw_home="~/.vim"

set ambiwidth=double
set fileformats=unix,dos,mac
set fileencodings=ucs-bom,utf-8,sjis,euc-jp,utf-16

set autoindent
set expandtab
set shiftwidth=2
set softtabstop=2

set nowrap
set formatoptions+=nmM
if exists("&breakindent")
  set breakindent
endif

set number
set list
set listchars=tab:__,trail:_,precedes:<,extends:>
set laststatus=2
set statusline=%F\ %m%r%h%w%y%{'['.&fileencoding.']['.&fileformat.']'}%=[%l,%c][U+%04B]

set hlsearch
set ignorecase
set incsearch
set smartcase

set autowrite
set updatetime=200

augroup wall
  autocmd!
  autocmd InsertLeave * silent! wall
  autocmd CursorHold * silent! wall
augroup END

augroup update_markdown_syntax
  autocmd!
  autocmd BufNew,BufEnter * if &filetype == 'markdown' | syntax match markdownError '\w\@<=\w\@=' | endif
augroup END

set debug=msg
set clipboard=unnamed
set modeline
set modelines=5
set wildmode=list:longest

if exists(":packadd")
  packadd! matchit
endif

syntax enable
filetype plugin on

colorscheme darkblue
highlight Normal ctermbg=none
highlight Underlined ctermfg=LightBlue

autocmd FileType html setlocal wrap
autocmd FileType markdown setlocal wrap
autocmd FileType text setlocal textwidth=60
autocmd FileType lua syntax sync minlines=500 maxlines=1000
if has("lua")
  let $LUA_PATH=$HOME."/dromozoa-dotfiles/?.lua;;"
  autocmd FileType text setlocal formatexpr=dromozoa#format()
endif

nnoremap j gj
nnoremap k gk
nnoremap <C-p> :bprev<CR>
nnoremap <C-n> :bnext<CR>
