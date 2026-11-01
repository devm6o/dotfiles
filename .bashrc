[ -f /etc/bashrc ] && . /etc/bashrc

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac
[ -d /usr/local/go/bin ] && PATH="$PATH:/usr/local/go/bin"
export PATH

for rc in ~/.bashrc.d/*; do [ -f "$rc" ] && . "$rc"; done
unset rc

PS1='\[\e]133;A\e\\\][\u@\h \W]\$ \[\e]133;B\e\\\]'
set -o vi
command -v nvim >/dev/null && alias vim='nvim'
alias as='ls'
export EDITOR=vim
