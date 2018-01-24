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

fpath=("$HOME/dromozoa-dotfiles/zshfuncs" $fpath)

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

alias h='history -E -i 1 | grep'

setopt noflowcontrol
bindkey "^Q" push-line-or-edit

ps_start="%F{9}"
ps_reset="%f"
case x$TERM in
  xscreen*) ps_start="%F{10}";;
esac
PS1="$ps_start%n@%m:%~%#$ps_reset "
PS2="$ps_start>$ps_reset "
RPROMPT=
SPROMPT="${ps_start}correct '%R' to '%r' [nyae]?$ps_reset "

autoload -U compinit
compinit
zstyle ':completion:*:default' menu select=2

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

if test -f "$HOME/.zshrc.local"
then
  . "$HOME/.zshrc.local"
fi
