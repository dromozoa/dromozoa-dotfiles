# Copyright (C) 2018,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with dromozoa-dotfiles. If not, see <https://www.gnu.org/licenses/>.

. "$HOME/dromozoa-dotfiles/_resource"

fpath=("$HOME/dromozoa-dotfiles/zshfuncs" $fpath)

setopt auto_cd
setopt autopushd
setopt correct
setopt extended_glob
setopt extended_history
setopt hist_expand
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt noautoremoveslash
setopt noflowcontrol
setopt share_history

# zsh 5.0.2 (CentOS 7) does not have inc_append_history_time
if setopt inc_append_history_time >/dev/null 2>&1
then
  setopt inc_append_history
fi

_dromozoa_prompt() {
  local start='%{[91m%}'
  local reset="%{[0m%}"
  case X$TERM in
    Xscreen*) start="%{[92m%}";;
  esac
  PS1="$start%n@%m:%~%#$reset "
  PS2="$start>$reset "
  RPROMPT=
  SPROMPT="${start}correct '%R' to '%r' [nyae]?$reset "
}
_dromozoa_prompt
unfunction _dromozoa_prompt

HISTFILE=~/.zsh_history
HISTSIZE=65536
SAVEHIST=65536
CORRECT_IGNORE=_*

# 標準出力以外への出力は時間がかかるので一時ファイルを作成する。
alias h='history -E -i 1 >"$HOME/.zsh_history_cache"; cat "$HOME/.zsh_history_cache" | grep'

autoload -U compinit
compinit
zstyle ':completion:*:default' menu select=2

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey "^N" history-beginning-search-forward-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^Q" push-line-or-edit
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

_dromozoa_zshrc_d() {
  unsetopt local_options nomatch
  if test -d "$HOME/.zshrc.d"
  then
    for i in "$HOME/.zshrc.d/"*
    do
      if test -f "$i"
      then
        . "$i"
      fi
    done
  fi
}
_dromozoa_zshrc_d
unfunction _dromozoa_zshrc_d
