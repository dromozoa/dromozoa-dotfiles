# Copyright (C) 2018,2021,2023 Tomoyuki Fujimori <moyu@dromozoa.com>
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

case X$PS1 in
  X) . "$HOME/dromozoa-dotfiles/_environ";;
  *) . "$HOME/dromozoa-dotfiles/_bashrc";;
esac

_dromozoa_bashrc_d() {
  if test -d "$HOME/.bashrc.d"
  then
    for i in "$HOME/.bashrc.d/"*
    do
      if test -f "$i"
      then
        . "$i"
      fi
    done
  fi
}
_dromozoa_bashrc_d
