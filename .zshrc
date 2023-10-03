# If you come from bash you might have to change your $PATH.
export PATH=$HOME/.local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Enable vi mode
bindkey -v
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true
MODE_INDICATOR="%F{magenta}<<<%f"
INSERT_MODE_INDICATOR="%F{green}<<<%f"
plugins=(git vi-mode)

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
source $ZSH/oh-my-zsh.sh
bindkey -M viins 'jk' vi-cmd-mode
export KEYTIMEOUT=10
autoload -Uz history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey -M viins "^P" history-beginning-search-backward-end
bindkey -M viins "^N" history-beginning-search-forward-end
bindkey -M vicmd "^P" history-beginning-search-backward-end
bindkey -M vicmd "^N" history-beginning-search-forward-end


export EDITOR='nvim'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
