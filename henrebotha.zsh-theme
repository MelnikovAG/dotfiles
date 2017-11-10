# Functionality for displaying normal mode indicator in Vi mode.
function zle-line-init zle-keymap-select {
  local visual_mode="%{$fg[green]%}N"
  local prompt_char="${${KEYMAP/vicmd/$visual_mode}/(main|viins)/»}"
  # Make prompt_char red if the last executed command failed. This needs to be
  # here because outside the function body, precedence breaks it. ¯\_(ツ)_/¯
  local return_status="%(?:%{$fg[cyan]%}$prompt_char:%{$fg[red]%}$prompt_char)"
  zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
# End Vi mode functionality

VIRTUAL_ENV_DISABLE_PROMPT=true

local host_name="%{$fg[magenta]%}$(whoami)"
local path_string="%{$fg[yellow]%}%~"
local git_string="%{$fg[green]%}$(git_prompt_info)"
local date_string="$(date '+%Y-%m-%d %H:%M:%S')"

PROMPT='${date_string} ${host_name} ${path_string} ${git_string}
${return_status} %{$reset_color%}'
