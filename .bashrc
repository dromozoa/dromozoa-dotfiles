# Copyright (C) 2018 Tomoyuki Fujimori <moyu@dromozoa.com>
#
# This file is part of dromozoa-dotfiles.
#
# dromozoa-dotfiles is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# dromozoa-dotfiles is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-dotfiles.  If not, see <http://www.gnu.org/licenses/>.

if test -f "$HOME/dromozoa-dotfiles/resource"
then
  . "$HOME/dromozoa-dotfiles/resource"
fi

PS1='\[\e[31m\]\u@\h:\W\$\[\e[m\] '
PS2='\[\e[31m\]>\[\e[m\] '

HISTCONTROL=ignoreboth
HISTSIZE=65536
HISTFILESIZE=65536
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "

alias h='history | grep'
