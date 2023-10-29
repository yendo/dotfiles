# ~/.bashrc: executed by bash(1) for non-login shells.

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

_command_exists() {
  type "$1" &> /dev/null
}

_source_if_exists() {
  [[ -s "$1" ]] && source "$1"
}

__git_ps1_venv() {
  local pre="$1"
  local post="$2"

  if [[ -n ${VIRTUAL_ENV} && -z ${VIRTUAL_ENV_DISABLE_PROMPT:-} ]]; then
    pre="($(basename "$VIRTUAL_ENV")) ${pre}"
  fi
  __git_ps1 "${pre}" "${post}"
}

# history | sort -urk2 | sort -n | sed 's/^ \+[0-9]\+ \+//' > ~/.bash_history

HISTCONTROL=ignoreboth:erasedups
HISTSIZE=1000
HISTFILESIZE=2000

shopt -s autocd
shopt -s checkwinsize
shopt -s cdspell
shopt -s globstar
shopt -s histappend

alias ls="ls --color=auto -FB"
alias ll='ls -lFBU --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias emacs='emacs -nw'
alias gs='git status'
alias gd='git diff'
alias df='df -h'

export VISUAL=vim

eval "$(dircolors -b)"

# bash_completion
_source_if_exists /etc/bash_completion

# git-prompt
_source_if_exists /opt/rh/rh-git218/root/usr/share/git-core/contrib/completion/git-prompt.sh

# xrdb
[[ $DISPLAY ]] && echo "Emacs.useXIM: false" | xrdb

# completion
_command_exists kubectl && source <(kubectl completion bash)
_command_exists kind && source <(kind completion bash)
_command_exists terraform && complete -C terraform terraform
_command_exists aws_completer && complete -C 'aws_completer' aws
# go get -u github.com/posener/complete/gocomplete
_command_exists gocomplete && complete -C gocomplete go


# prompt
# PS1='[\u@\h \W]\$ '
PROMPT_COMMAND='__git_ps1_venv "'"${PS1%\\\$ }"'" "\\\$ "'
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWCOLORHINTS=true
export GIT_PS1_SHOWUNTRACKEDFILES=true

# fzf
if [ -f /etc/redhat-release ]; then
  _source_if_exists /usr/share/fzf/shell/key-bindings.bash
else
  _source_if_exists /usr/share/doc/fzf/examples/completion.bash
  _source_if_exists /usr/share/doc/fzf/examples/key-bindings.bash
fi

export FZF_DEFAULT_OPTS='--no-border'

# cd ghq project
fgh() {
  # shellcheck disable=SC2155
  declare -r repo_name="$(ghq list | fzf)"
  [[ -n "${repo_name}" ]] && cd "$(ghq root)/${repo_name}" || return
}


# checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

# load local bashrc
_source_if_exists ~/.bash_local

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/devel
export VIRTUALENV_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/bin/virtualenv
# source ~/.local/bin/virtualenvwrapper.sh

# asdf
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash

# fcqs
fcqs() {
  local title=$(fcqs-cli | \
    fzf --preview "fcqs-cli {}" \
        --bind "ctrl-y:execute-silent(fcqs-cli {} | xclip -selection c),ctrl-o:execute-silent(fcqs-cli -u {} | xargs xdg-open),ctrl-e:execute-silent(fcqs-cli -l {} | awk '{printf \"+%s %s\",\$2,\$1}' | xargs -o $VISUAL > /dev/tty)+abort")
  fcqs-cli "$title"
  local command=$(fcqs-cli -c "$title")
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${command}${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(( READLINE_POINT + ${#command} ))
}

# You can customize the key binding
bind -x '"\C-o":fcqs'
