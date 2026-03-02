ZIM_HOME=~/.cache/zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# oh-my-posh setup
eval "$(oh-my-posh init zsh --config /usr/local/share/oh-my-posh/themes/microverse-power.omp.json)"

# Use Emacs keybindings in the terminal, which are more common and generally
# more user-friendly than Vi keybindings.
bindkey -e

# up-down hist navigation
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "${key_info[Up]}"   ]] && bindkey -- "${key_info[Up]}"   up-line-or-beginning-search
[[ -n "${key_info[Down]}" ]] && bindkey -- "${key_info[Down]}" down-line-or-beginning-search

