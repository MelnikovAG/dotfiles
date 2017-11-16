ZSH_THEME="henrebotha"

COMPLETION_WAITING_DOTS="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(git osx zsh-nvm)

# User configuration

# export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.

# Enable rbenv.
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Fix yarn binary issue https://github.com/yarnpkg/yarn/issues/648
# Do `yarn global bin` to get the path
export PATH="/usr/local/Cellar/node/8.2.1/bin:$PATH"

# # zsh-autoenv
# source ~/.dotfiles/lib/zsh-autoenv/autoenv.zsh

# Shortcut for finding aliases.
alias cmd='alias | grep '
# Shortcut for discarding changes to all unstaged, tracked files.
alias gdisc='git checkout -- $(git ls-files -m)'
# Shortcuts for hiding changes from git (e.g. so that we can override configs
# in dev without risk of committing them by accident).
alias ghide='git update-index --skip-worktree'
alias gunhide='git update-index --no-skip-worktree'
alias ghidden='git ls-files -v . | grep ^S'

alias emacs="/usr/local/Cellar/emacs-plus/25.1/Emacs.app/Contents/MacOS/Emacs -nw"
alias vim="mvim -v"
alias v='mvim -v'
alias t='tree'
alias tx='tmuxinator s'
alias txe='tmuxinator new'
alias ta='tmux a -t'
# Shortcuts for elm.
alias elmc='elm-repl'
alias elmr='elm-reactor'
alias elmm='elm-make'
alias elmp='elm-package'

alias s='source ~/.zshrc'

# https://dougblack.io/words/zsh-vi-mode.html
# Enable Vi mode.
bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward

# Default 400ms delay after ESC is too slow. Increase this value if this breaks
# other commands that depend on the delay.
export KEYTIMEOUT=1 # 100 ms

# # Functionality for displaying normal mode indicator in Vi mode.
# function zle-line-init zle-keymap-select {
#     VIM_PROMPT="%{$bg[blue]$fg[yellow]%}[% NORMAL]% %{$reset_color%}"
#     RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$EPS1"
#     zle reset-prompt
# }
# zle -N zle-line-init
# zle -N zle-keymap-select
# # End Vi mode functionality

# List folder contents after cd.
cdl() { cd $1; la }

# A lovely script that watches files for changes and automatically commits them
# to git. Nice to use for note-taking.
autocommit() {
  # commit any changes since last run
  date +%Y-%m-%dT%H:%M:%S%z; git add $@; git commit -m "AUTOCOMMIT"; echo
  # now commit changes whenever files are saved
  fswatch -0 $@ | xargs -0 -n 1 sh -c "date +%Y-%m-%dT%H:%M:%S%z; git add .; git commit -m \"AUTOCOMMIT\"; echo"
}

# https://github.com/thoughtbot/dotfiles/blob/master/bin/replace
# Find and replace by a given list of files.
#
# replace foo bar **/*.rb

replace() {
  find_this="$1"
  shift
  replace_with="$1"
  shift

  items=("${(@f)$(ag -l --nocolor "$find_this" "$@")}")
  temp="${TMPDIR:-/tmp}/replace_temp_file.$$"
  IFS=$'\n'
  for item in $items; do
    sed "s/$find_this/$replace_with/g" "$item" > "$temp" && mv "$temp" "$item"
  done
}

# fzf keybinds/completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ~/.dev
