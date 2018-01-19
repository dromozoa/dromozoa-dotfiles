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

bindkey -v

umask 022

PATH=\
$HOME/dromozoa-dotfiles/bin:\
/opt/dromozoa53/bin:\
/opt/dromozoa/bin:\
/usr/local/bin:\
/usr/bin:\
/bin:\
/usr/sbin:\
/sbin

MANPATH=\
/opt/dromozoa53/share/man:\
/opt/dromozoa/share/man:\
/usr/local/share/man:\
/usr/share/man

CPPFLAGS=-I/opt/dromozoa/include
LDFLAGS=-L/opt/dromozoa/lib

if (locale -a | grep -iE 'ja_JP\.UTF-?8') >/dev/null 2>&1
then
  LANG=ja_JP.UTF-8
else
  LANG=C.UTF-8
fi

EDITOR=vim

for i in PATH MANPATH CPPFLAGS LDFLAGS LANG EDITOR
do
  export "$i"
done

autoload -U colors
colors

autoload -U compinit
compinit

PROMPT="%{$fg[red]%}%n@%m:%~%#%{$reset_color%} "
PROMPT2="%{$fg[red]%}>%{$reset_color%} "
SPROMPT="%{$fg[red]%}correct '%R' to '%r' [nyae]?%{$reset_color%} "

setopt auto_cd
setopt autopushd
setopt correct
setopt extended_glob
setopt extended_history
setopt hist_expand
setopt hist_ignore_dups
setopt hist_verify
setopt inc_append_history
setopt noautoremoveslash
setopt share_history

HISTFILE=~/.zsh_history
HISTSIZE=65536
SAVEHIST=65536

alias c=clear
alias e=exit
alias h='fc -l -i 1 | grep'
alias o='cd "$OLDPWD"'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias rmfr='\rm -fr'

uname=`uname`
case x$uname in
  xDarwin)
    alias ls='ls -F -G'
    export LSCOLORS=gxcxheheDxagadabagacad;;
  *)
    alias ls='ls -F --color=auto';;
esac
