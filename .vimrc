" Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
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
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with dromozoa-dotfiles.  If not, see <http://www.gnu.org/licenses/>.

set runtimepath+=~/dromozoa-dotfiles/vimfiles

set ambiwidth=double
set fileformats=unix,dos,mac
set fileencodings=ucs-bom,utf-8,utf-16,sjis,euc-jp

set autoindent
set expandtab
set shiftwidth=2
set softtabstop=2

set nowrap
set formatoptions+=nmM
if exists("&breakindent")
  set breakindent
endif

set clipboard=unnamed
set modelines=5
set wildmode=list:longest

set hlsearch
set ignorecase
set incsearch
set smartcase

set number
set list
set listchars=tab:__,trail:_,precedes:<,extends:>
set laststatus=2
set statusline=%F\ %m%r%h%w%y%{'['.&fileencoding.']['.&fileformat.']'}%=[%l,%c][U+%04B]

set autowrite
set updatetime=1000

syntax enable
colorscheme darkblue
filetype plugin on

nnoremap j gj
nnoremap k gk

autocmd InsertLeave * wall
autocmd CursorHold * wall

autocmd FileType html setlocal wrap
autocmd FileType text setlocal textwidth=60

if has("lua")
  let $LUA_PATH=$HOME."/dromozoa-dotfiles/?.lua;;"
  autocmd FileType text setlocal formatexpr=dromozoa#format()
endif
