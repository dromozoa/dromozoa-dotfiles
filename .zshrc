bindkey -v

umask 022

PATH=\
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
