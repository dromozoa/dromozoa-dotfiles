# vim: filetype=sh:

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

set -o vi
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

if (locale -a | grep -iE 'ja_JP\.UTF-?8') >/dev/null 2>&1
then
  LANG=ja_JP.UTF-8
else
  LANG=C.UTF-8
fi

EDITOR=vim
CPPFLAGS=-I/opt/dromozoa/include
LDFLAGS=-L/opt/dromozoa/lib

for i in PATH MANPATH LANG EDITOR CPPFLAGS LDFLAGS
do
  export "$i"
done

alias c=clear
alias e=exit
alias l='ls -al'
alias o='cd "$OLDPWD"'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias rmfr='\rm -fr'

alias git-checkout-master='git checkout master'
alias git-checkout-develop='__dromozoa-git-checkout develop master'
alias git-checkout-feature='__dromozoa-git-checkout feature develop'
alias git-checkout-release='__dromozoa-git-checkout release develop'
alias git-push-all-tags-dry-run='git-push-all-tags --dry-run'
alias git-clean='git clean -d -x'
alias git-status='git status'
alias git-tag='git tag -m "" -a'
alias tig-all='tig --all'

uname=`uname`
case x$uname in
  xDarwin)
    alias ls='ls -F -G'
    LSCOLORS=gxcxheheDxagadabagacad
    export LSCOLORS;;
  *)
    alias ls='ls -F --color=auto';;
esac
