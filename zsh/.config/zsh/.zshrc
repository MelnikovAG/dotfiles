os=`uname`

. "$ZDOTDIR"/.zsh_util_install

expand-or-complete-custom() {
  # https://github.com/ohmyzsh/ohmyzsh/blob/02d07f3e3dba0d50b1d907a8062bbaca18f88478/lib/completion.zsh#L62
  print -Pn "%F{red}…%f"
  load_tmux_user_env
  zle expand-or-complete
  zle redisplay
}

zle -N expand-or-complete-custom
bindkey -M emacs "^I" expand-or-complete-custom
bindkey -M viins "^I" expand-or-complete-custom
bindkey -M vicmd "^I" expand-or-complete-custom

# Clone zcomet if necessary
if [[ ! -f ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh ]]; then
  command git clone https://github.com/agkozak/zcomet.git ${ZDOTDIR:-${HOME}}/.zcomet/bin
fi

source ${ZDOTDIR:-${HOME}}/.zcomet/bin/zcomet.zsh

zcomet load ohmyzsh 'plugins/vi-mode'
zcomet load ohmyzsh 'plugins/ripgrep'
zcomet load 'Aloxaf/fzf-tab'
zcomet load 'larkery/zsh-histdb'
zcomet load 'benvan/sandboxd'
zcomet load 'olets/zsh-abbr'
zcomet load 'olets/zsh-test-runner'
zcomet load 'romkatv/zsh-bench'
# Zcomet recommends loading this last
zcomet load 'zsh-users/zsh-autosuggestions'

zcomet compinit

export PATH="$HOME/.local/bin:$PATH"

. "$ZDOTDIR/prompt.zsh"
setopt promptsubst

fpath=( "$ZDOTDIR"/completions "${fpath[@]}" )

# https://github.com/nickmccurdy/sane-defaults/blob/master/home/.zshrc
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
setopt no_list_ambiguous

# Key bindings for fzf-tab
zstyle ':fzf-tab:*' fzf-bindings 'right:accept'

# export MANPATH="/usr/local/man:$MANPATH"

# TODO: Try to make this work. The idea is that we set ZSH_COMPDUMP before we
# (OMZ) call compinit, so that the dump doesn't end up in our home dir.
# if [ ! -d ~/.cache/zsh ]; then
#   mkdir -p ~/.cache/zsh
# fi
# export $ZSH_COMPDUMP="~/.cache/zsh/zcompdump-$ZSH_VERSION"

if [ -d ~/zsh_help ]; then
  export HELPDIR=~/zsh_help
  unalias run-help
  autoload run-help
fi

alias help=run-help

alias s=". $ZDOTDIR/.zshrc"
alias :q=exit # Welp

setopt extended_glob
# Allow **foo as shorthand for **/*foo.
setopt glob_star_short

# Don't expand history inline.
setopt hist_verify

# Store history & share it across sessions.
setopt share_history
export HISTSIZE=1000000000
export SAVEHIST=1000000000
export HISTFILE="$XDG_DATA_HOME/zsh/.zsh_history"
# Record timestamps.
setopt extended_history
# When looking up history, ignore duplicates.
setopt hist_find_no_dups

# Create aliases such as ~dev for ~/dev. This will be reflected in both the
# prompt, and in completion for commands such as cd or ls.
hash -d -- dev="$HOME"/dev
hash -d -- dotfiles="$HOME"/dev/dotfiles

# On dir change, run a function that, if we're in
# ~/git_tree/agency-api-client/$branch_name, will add the subdirs of ./packages
# to $cdpath.
# TODO: Generalise this to read from a map of directory patterns to "package" dirs.
chpwd_functions=($chpwd_functions chpwd_add_packages)
chpwd_add_packages() {
  if [[ $(pwd) =~ "$HOME"'/git_tree/attractions/content/([A-Za-z0-9\-_]+)/?\b' ]]; then
    package_dir="$HOME"'/git_tree/attractions/content/'$match[1]'/packages'
    if [[ ! ${cdpath[(ie)$package_dir]} -le ${#cdpath} ]]; then
      cdpath=($cdpath $package_dir)
    fi
  else
    # Remove things that look like package_dir from cdpath
    cdpath=(${cdpath:#"$HOME"'/git_tree/attractions/content/'$match[1]'/packages'})
  fi
}

# chpwd is not invoked on shell startup, so we define a self-destructing
# function to do this once. Source:
# https://gist.github.com/laggardkernel/b2cbc937aa1149530a4886c8bcc7cf7c
_self_destruct_hook() {
  local f
  for f in ${chpwd_functions}; do
    "$f"
  done

  # Remove self from precmd
  precmd_functions=(${(@)precmd_functions:#_self_destruct_hook})
  builtin unfunction _self_destruct_hook
}
(( $+functions[add-zsh-hook] )) || autoload -Uz add-zsh-hook
add-zsh-hook precmd _self_destruct_hook

# Zsh-histdb
alias hf=histdb\ --forget\ --exact
# Forget last command
alias hfl='hf "$(fc -n -l -1)"'

# Zsh-autosuggestions
export ZSH_AUTOSUGGEST_USE_ASYNC=1

if command -v histdb &> /dev/null; then
  ZSH_AUTOSUGGEST_STRATEGY=histdb # (histdb history completion)

  _zsh_autosuggest_strategy_histdb() {
    typeset -g suggestion
    suggestion=$(_histdb_query "
        SELECT commands.argv
        FROM history
          LEFT JOIN commands ON history.command_id = commands.rowid
          LEFT JOIN places ON history.place_id = places.rowid
        WHERE
          commands.argv LIKE '$(sql_escape $1)%' AND
          places.dir = '$(sql_escape $PWD)'
        GROUP BY commands.argv
        ORDER BY history.start_time desc
        LIMIT 1
    ")
  }
fi

# Zsh global aliases
alias -g @q="2> /dev/null"
alias -g @qq=">/dev/null 2>&1"
alias -g @errout="2>&1"

# Docker
alias d=docker
alias dc=docker-compose

# Kubernetes
[ -f "$HOME/.kubectl.zsh" ] && . "$HOME/.kubectl.zsh"
alias k=kubectl

# Java
# TODO: Lazy-load with sandboxd.
if command -v jenv &> /dev/null; then
  eval "$(jenv init -)"
  export PATH="$HOME/.jenv/shims:$PATH"
fi

# Ruby
# Enable rbenv
# TODO: Lazy-load with sandboxd.
if command -v rbenv &> /dev/null; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# Node
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Git
alias g='git'

# A lovely script that watches files for changes and automatically commits them
# to git. Nice to use for note-taking.
autocommit() {
  # commit any changes since last run
  date +%Y-%m-%dT%H:%M:%S%z; git add $@; git commit -m "AUTOCOMMIT"; echo
  # now commit changes whenever files are saved
  fswatch -0 $@ | xargs -0 -n 1 sh -c "date +%Y-%m-%dT%H:%M:%S%z; git add .; git commit -m \"AUTOCOMMIT\"; echo"
}

# Tmux
# Let's install tpm, if we have Tmux but not tpm
if [ -d "$HOME/.tmux" -a ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone git@github.com:/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

alias tx='tmuxinator s'
alias txe='tmuxinator new'
alias ta='tmux a -t'
alias tai='tmux new-session -t' # mnemonic: "tmux attach independent"
alias tk='tmux kill-session -t'
alias tl='tmux ls 2> /dev/null || echo '\''Tmux is not running.'\'
typeset -A tmux_sessions
export tmux_sessions=(
  [dev]=~/git_tree
  [diy]=~/Documents/DIY
  [dotfiles]=~/dev/dotfiles
  [games]=~/Games
  [notes]=~/git_tree/notes
  [personal-dev]=~/dev
)
tn() {
  : ${1:?tn needs a session name.}
  args=(${@:2})
  session_root=${tmux_sessions[$1]:-$HOME}
  tmux new-session -s $1 -c $session_root $args
}
tna() {
  auto_sessions=(
    dev
    dotfiles
    notes
    personal-dev
  )
  for session in ${(@k)tmux_sessions:*auto_sessions}; do
    tn $session -d
  done
}

load_tmux_user_env() {
  if [ -n "$TMUX" ]; then
    for var in $(tmux show-environment | grep '^TMUX_USER_ENV_' | sed 's/^TMUX_USER_ENV_//'); do
      export $var
    done
  fi
}
load_tmux_user_env

# Wait for a string to appear in another pane before executing a command
tmux_await() {
  # Args: window & pane (ints), then grep pattern to match, then command to run
  : ${1:?tmux_await needs a window number (prefix-i).}
  : ${2:?tmux_await needs a pane number (prefix-i or prefix-q).}
  : ${3:?tmux_await needs a pattern to look for.}
  : ${4:?tmux_await needs a command to execute.}
  # args=(${@:2})
  # session_root=${tmux_sessions[$1]:-$HOME}
  # tmux new-session -s $1 -c $session_root $args
  while ! tmux capture-pane -p -t @"$1".%"$2" | grep "$3"; do
    sleep 1
  done; ${@:4}
}

# Fix broken mouse reporting after ssh exits abruptly
alias fix-mouse-reporting='printf '\''\e[?1000l'\'''

# Vim
# If we're in a Git repo, name the server after that repo. Otherwise, give it a
# misc name, based either on Tmux session or otherwise just "VIM".
vim_servername() {
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "$(git repo-and-branch-name)"
  elif [ -n "$TMUX" ]; then
    echo "$(tmux display-message -p '#{session_name}')"
  else
    echo 'VIM'
  fi
}
# Launch with -X to prevent communication with X11 on startup, improving startup
# speed in Tmux
if vim --version | grep '\+clientserver' > /dev/null; then
  alias vim='vim -X --servername $(vim_servername)'
else
  alias vim='vim -X'
fi
# Use as pager
alias vpage='ifne vim -X -R - -n'
# Source ~/.vimrc in every running Vim server instance
alias vu='for server in `vim --serverlist`; do; vim --servername $server --remote-send '\'':source ~/.vimrc<cr>'\''; done'

# Elm
alias elmc='elm-repl'
alias elmr='elm-reactor'
alias elmm='elm-make'
alias elmp='elm-package'

# Maven
alias mvnq='mvn -q'

# Ripgrep
rgl() {
  rg --color=always $@ | less -R
}

fzcp() {
  fzf -m --tac $@ | xclip -sel clip
}

# macOS
if [[ "$os" == 'Darwin' ]]; then
  # Fix the macOS pasteboard when it breaks
  # alias fixpboard='ps aux | grep '\''[p]board'\'' | perl -p -e '\''s/ +/ /g'\'' | cut -d '\'' '\'' -f 2 | xargs kill -9'
  alias fixpboard='pkill -9 pboard'

  alias ip-eth="ipconfig getifaddr en0"
  alias ip-wifi="ipconfig getifaddr en1"
fi

is_gnu_sed() {
  sed --version >/dev/null 2>&1
}

alias s='sudo'

# Key bindings & related config
# https://dougblack.io/words/zsh-vi-mode.html
# Enable Vi mode.
bindkey -v

autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey -M viins '^N' copy-earlier-word
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward
bindkey '^[[Z' reverse-menu-complete # SHIFT-TAB to go back
bindkey -M vicmd '^\' push-line-or-edit # "context switch" half-written command
bindkey -M viins '^\' push-line-or-edit
bindkey -M vicmd 'gcc' vi-pound-insert

# Enable quoted & bracketed text objects!!! Thanks @mr_v
autoload -U select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed
for m in visual viopp; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $m $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $m $c select-bracketed
  done
done

# Default 400ms delay after ESC is too slow. Increase this value if this breaks
# other commands that depend on the delay.
export KEYTIMEOUT=1 # 100 ms

# Completion
# Allow tab completion to match hidden files always
setopt globdots

# Misc
if command -v eza &> /dev/null; then
  # -F cannot come before other bundled single-char flags
  alias ls='eza -alF --git --group-directories-first --time-style=long-iso'
  alias l=ls
  alias ld='ls -D'
  alias tree='eza -alTF --git --time-style=long-iso'
  alias t=tree
elif command -v exa &> /dev/null; then
  alias ls='exa -aFl --git --group-directories-first --time-style=long-iso'
  alias l=ls
  alias ld='ls -D'
  alias tree='exa -aFlT --git --time-style=long-iso'
  alias t=tree
else
  alias ls='ls -Ahlp --color=auto --group-directories-first --hyperlink --time-style=long-iso'
  alias l=ls
  alias ld='ls -Ahl --color=auto --directory --hyperlink --time-style=long-iso'
  alias t=tree
fi

export RIPGREP_CONFIG_PATH="$HOME"'/.ripgreprc'

# fzf keybinds/completion
eval "$(fzf --zsh)"
[ -f "$ZDOTDIR/.fzf.zsh" ] && . "$ZDOTDIR/.fzf.zsh"

export FZF_DEFAULT_OPTS='--color=16 --bind "f1:execute(less -f {})"'
# --files: List files, do not search them
# --follow: Follow symlinks
# --hidden: Search hidden paths
# --glob: Additional conditions (exclude .git)
# --no-ignore: Do not respect .gitignore and the like
export FZF_DEFAULT_COMMAND='rg --files --glob "!.git/*" --hidden --no-ignore'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND=altc

alias fzfp='fzf --preview '\''[[ $(file --mime {}) =~ binary ]] &&
                 echo {} is a binary file ||
                 (highlight -O ansi -l {} ||
                  coderay {} ||
                  rougify {} ||
                  cat {}) 2> /dev/null | head -200'\'

fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# if [ ! -e ~/isomorphic-copy ]; then
#   g clone git@github.com:ms-jpq/isomorphic-copy.git ~/isomorphic-copy
# fi
# export PATH="$HOME/isomorphic-copy/bin:$PATH"

# # zsh-async
# # Installation
# if [[ ! -a ~/.zsh-async ]]; then
#   git clone -b 'v1.5.2' https://github.com/mafredri/zsh-async ~/.zsh-async
# fi
# . ~/.zsh-async/async.zsh

# vagrant_status() {
#   VAGRANT_CWD=$1 vagrant status
# }

# # Configuration
# async_init

# async_start_worker vagrant_prompt_worker -n

# vagrant_prompt_callback() {
#   local output=$@
#   if [[ $output =~ 'running' ]]; then
#     H_PROMPT_VAGRANT_UP='v↑'
#   else
#     H_PROMPT_VAGRANT_UP=''
#   fi
#   async_job vagrant_prompt_worker vagrant_status $(pwd)
# }

# async_register_callback vagrant_prompt_worker vagrant_prompt_callback

# async_job vagrant_prompt_worker vagrant_status $(pwd)
# # end zsh-async

bindkey '^f' reset-prompt

# OPAM configuration
[ -f "$HOME"/.opam/opam-init/init.zsh ] && . "$HOME"/.opam/opam-init/init.zsh

# Direnv
eval "$(direnv hook zsh)"

# https://gist.github.com/ctechols/ca1035271ad134841284
# On slow systems, checking the cached .zcompdump file to see if it must be
# regenerated adds a noticable delay to zsh startup.  This little hack restricts
# it to once a day.  It should be pasted into your own completion file.
#
# The globbing is a little complicated here:
# - '#q' is an explicit glob qualifier that makes globbing work within zsh's [[ ]] construct.
# - 'N' makes the glob pattern evaluate to nothing when it doesn't match (rather than throw a globbing error)
# - '.' matches "regular files"
# - 'mh+24' matches files (or directories or whatever) that are older than 24 hours.
autoload -Uz compinit
for dump in $XDG_CACHE_HOME/zsh/.zcompdump(N.mh+24); do
  compinit
done
compinit -C
autoload -U +X bashcompinit && bashcompinit

[ -f "$ZDOTDIR"/.zsh-work ] && . "$ZDOTDIR"/.zsh-work

ABBR_SET_EXPANSION_CURSOR=1

typeset -A abbr_abbreviations
export abbr_abbreviations=(
  ['bk a']='bk auth:login'
  ['bk d']='bk deploy'
  ['bk sb']='bk shipper:blocks'
  ['bk sdi']='bk sd:installations'
  ['bk sps']='bk shipper:pods:status'
  [d]=docker
  [g]=git
  [hf]='histdb --forget --exact'
  [k]=kubectl
  ['kubectl e']='kubectl exec $pod -it --'
  ['kubectl gp']='kubectl get pods'
  ['kubectl g']='kubectl get'
  ['kubectl get p']='kubectl get pods'
  ['kubectl l']='kubectl logs -c app $pod'
  ['kubectl lf']='kubectl logs -c app --tail=20 -f $pod'
  ['a']='apt'
  ['apt i']='apt install'
  ['apt install y']='apt install -y'
  ['aiy']='apt install -y'
  [v]=vim
)

typeset -A modifier_commands
export modifier_commands=(
  [s]=sudo
  [wa]=watch
  [wh]=which
)

abbrs=$(abbr list-abbreviations)
for abbreviation phrase in ${(@kv)abbr_abbreviations}; do
  if [[ ! "$abbrs" =~ "\"$abbreviation\"" ]]; then
    abbr "$abbreviation"="$phrase"
  fi
  if [[ ! "$abbrs" =~ "\"@$abbreviation\"" ]]; then
    abbr -g "@$abbreviation"="$phrase"
  fi
done
for abbreviation modifier in ${(@kv)modifier_commands}; do
  if [[ ! "$abbrs" =~ "\"$abbreviation\"" ]]; then
    abbr "$abbreviation"="$modifier @%"
  fi
done
unset modifier_commands
unset abbrs
unset abbr_abbreviations

typeset -A abbr_global_abbreviations
export abbr_global_abbreviations=(
  ['@q']='2> /dev/null'
  ['@qq']='>/dev/null 2>&1'
  ['@errout']='2>&1'
)

global_abbrs=$(abbr list-abbreviations)
for abbreviation phrase in ${(@kv)abbr_global_abbreviations}; do
  if [[ ! "$global_abbrs" =~ "\"$abbreviation\"" ]]; then
    abbr -g "$abbreviation"="$phrase"
  fi
done
unset global_abbrs
unset abbr_global_abbreviations

bindkey "^E" abbr-expand

repl() {
  case $1 in
    java)
      jshell;;
    javascript|js)
      node;;
    python)
      python;;
    python2)
      python2;;
    python3)
      python3;;
    ruby)
      if command -v rbenv &> /dev/null; then
        if rbenv which pry > /dev/null 2>&1; then
          pry
        else
          irb
        fi
      else
        if command -v pry > /dev/null 2>&1; then
          pry
        else
          irb
        fi
      fi;;
  esac
}

unset os

export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

# zprof
# zmodload -u zsh/zprof
