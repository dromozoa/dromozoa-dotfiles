umask 022
set -o vi

PATH=/opt/dromozoa53/bin:/opt/dromozoa/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
MANPATH=/opt/dromozoa53/share/man:/opt/dromozoa/share/man:/usr/share/man
EDITOR=vim
LANG=ja_JP.UTF-8
CPPFLAGS=-I/opt/dromozoa/include
LDFLAGS=-L/opt/dromozoa/lib

for i in PATH MANPATH EDITOR LANG CPPFLAGS LDFLAGS
do
  export "$i"
done

if autoload -U compinit; then
  compinit
fi

if autoload -U colors; then
  colors
  PS1="%{$fg[red]%}%n@%m:%~%#%{$reset_color%} "
  PS2="%{$fg[red]%}>%{$reset_color%} "
fi

setopt hist_ignore_dups
setopt share_history

HISTFILE=~/.zsh_history
HISTSIZE=65536
SAVEHIST=65536

setopt extended_glob

alias c=clear
alias cp='cp -i'
alias e=exit
alias h='fc -l -i 1 | grep'
alias mv='mv -i'
alias o='cd "$OLDPWD"'
alias rm='rm -i'
alias rmfr='\rm -f -r'

alias git-checkout-branch-feature='git checkout -b feature'
alias git-checkout-branch-release='git checkout -b release'
alias git-merge-feature='git merge --no-ff -m "作業ブランチをマージ。" feature'
alias git-merge-release='git merge --no-ff -m "リリースブランチをマージ。" release'
alias git-merge-source='git merge --no-ff -m "ソースブランチをマージ。" source'
alias git-commit-prepare='git commit -m "リリース準備。"'
alias git-commit-refactoring='git commit -m "リファクタリング。"'
alias git-commit-release='git commit -m "リリースメッセージを設定。"'
alias git-tag='git tag -m "" -a'
alias git-push-all-tags='git push --all && git push --tags'
alias git-push-all-tags-dry-run='git push --dry-run --all && git push --dry-run --tags'
alias git-clean='git clean -d -x'
alias git-config-user-name-email='git config user.name "Tomoyuki Fujimori" && git config user.email "moyu@dromozoa.com"'
