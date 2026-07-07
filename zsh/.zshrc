# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$HOME/workspace/00_dotfiles/bin:$PATH
export PATH="$PATH:$HOME/.docker/bin"
export PATH="$PATH:$HOME/.local/bin"

# MACOS specific
if [[ "$(uname)" == "Darwin" ]]; then
    export PATH="$PATH:/opt/homebrew/opt/libpq/bin"
    # Add Visual Studio Code (code) due to missing admin permission
    export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin:/Applications/DBeaver.app/Contents/MacOS"
    export XDG_CONFIG_HOME="$HOME/.config"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="agnoster_newline"
ZSH_THEME="miloshadzic"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(aws git git-flow history node npm
        zsh-autosuggestions #https://github.com/zsh-users/zsh-autosuggestions
    )

SHOW_AWS_PROMPT=true
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

export EDITOR=nvim
# nvim setup
#export PATH=$PATH:/opt/nvim-linux-x86_64/bin
alias vi=nvim
# using fzf in CTRL-R
source <(fzf --zsh) # for fzf > 0.48
# source /usr/share/doc/fzf/examples/key-bindings.zsh
# source /usr/share/doc/fzf/examples/completion.zsh
# Compilation flags
# export ARCHFLAGS="-arch x86_64"
tmss () {
    # WORK_DIR="~/workspace/02_keypay/configuration-management"
    # SESSION="configuration-management"
    WORK_DIR=$1
    SESSION=$2

    tmux kill-session -t $SESSION
    tmux new-session -d -s $SESSION -c $WORK_DIR
    tmux split-window -t $SESSION:1.1 -hl 1
    tmux split-window -t $SESSION:1.2 -vl 1
    tmux send-keys -t $SESSION:1.1 "nvim ." Enter
    tmux send-keys -t $SESSION:1.2 "cd $WORK_DIR" Enter
    tmux send-keys -t $SESSION:1.3 "cd $WORK_DIR && ll && git s" Enter
    tmux attach-session -t $SESSION
}

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
alias ll="ls -lah"
# enc_pass settings
alias enc_ssl="openssl enc -aes-256-cbc"
alias dec_ssl="openssl enc -aes-256-cbc -d"

# show export PATH
alias export_path="echo 'export \$PATH=\$PATH:/usr/bin'"

# open note.txt
alias note_file="nvim $HOME/workspace/note.txt"
# jwt-decode
jwt-decode() {
    if [[ -x $(command -v jq) ]]; then
        jq -R 'split(".") | .[0,1] | @base64d | fromjson' <<< "${1}"
    else
        echo "Error: jq is required."
    fi
}

# quick worktree dir switch with peco
# need peco installation
wt() {
  local dir
  dir=$(git worktree list | peco | awk '{print $1}')
  [[ -n "$dir" ]] && cd "$dir"
}
# AWS cli shortcut
export AWS_PAGER=""

# aws → always via aws-vault when AWS_PROFILE is set.
# Escape hatch for raw binary (e.g. `aws configure sso`): AWS_NO_VAULT=1 aws ...
function aws() {
    if [[ -n "${AWS_NO_VAULT:-}" ]]; then
        command aws "$@"
        return $?
    fi
    if [[ -z "${AWS_PROFILE:-}" ]]; then
        echo "aws: no AWS_PROFILE set. Run: awssso <profile>  (or AWS_NO_VAULT=1 aws ...)" >&2
        return 1
    fi
    command aws-vault exec "$AWS_PROFILE" -- aws "$@"
}

# ave is now just an alias preserved for muscle memory
function ave() { aws "$@"; }
alias awswho="aws sts get-caller-identity"

# Refresh SSO token for current profile
function awslogin() {
    local profile="${1:-$AWS_PROFILE}"
    if [[ -z "$profile" ]]; then
        echo "Usage: awslogin [profile]  (or set AWS_PROFILE first)"
        return 1
    fi
    command aws sso login --profile "$profile"
}

# Set profile + region + tmux colors
function awssso() {
    export AWS_PROFILE=$1
    export AWS_REGION=eu-west-1
    if [[ -n "$TMUX" ]]; then
        local danger_profiles=(admin master-admin master-ro)
        local is_danger=0
        for kw in "${danger_profiles[@]}"; do
            [[ "$AWS_PROFILE" == *"$kw"* ]] && is_danger=1 && break
        done
        if (( is_danger )); then
            tmux set-window-option pane-active-border-style 'fg=colour210,bold'
        else
            tmux set-window-option pane-active-border-style 'fg=green'
        fi
    fi
    awslogin $AWS_PROFILE
    echo "AWS profile: $AWS_PROFILE"
}



# assume-role aws
# make sure peco, assume-role were installed
# function aws_set() {
#     BASTION=$1
#     AWS_PROFILE=$(grep -iE "\[*\]" ~/.aws/credentials | tr -d "[]" | peco)
#     # assume-role $BASTION $AWS_PROFILE
#     if ! command -v decrypt.key.sh &> /dev/null
#     then
#         eval $(assume-role $AWS_PROFILE)
#     else
#         eval $(decrypt.key.sh $BASTION | assume-role $AWS_PROFILE)
#     fi
# }
# function awsssh(){
#     ssh $(aws ec2 describe-instances \
#         --query "Reservations[*].Instances[*].[InstanceId, PrivateIpAddress, Tags[?Key=='Name'].Value | [0]]" \
#         --output text | column -t | peco | awk '{print $1}')
# }

# ssh quick select
# make sure peco was installed
# function ssh_start() {
#     REMOTE=$(grep )
# }

# custom settings
# Show timestamp on right hand side
# RPROMPT="[%D{%f-%m}T%D{%H:%M}]"

# aws settings
# Enable auto completion
autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws
# gcp settings
# gcloud autocompletion
# source /usr/share/google-cloud-sdk/completion.zsh.inc

[[ -n "$MOLE_ENV" ]] && RPROMPT="%F{cyan}[mole:$MOLE_ENV]%f $RPROMPT"

# kubectl settings

export BASH_COMPLETION_COMPAT_DIR=/usr/local/etc/bash_completion.d
[[ -r /usr/local/etc/profile.d/bash_completion.sh ]] && . /usr/local/etc/profile.d/bash_completion.sh

export LBC_VERSION="v2.0.0"
[ -x "$(command -v kubectl)" ] &&  source <(kubectl completion zsh)
# export KUBECONFIG=$HOME/.kube/config
alias k='kubectl'
# alias k="kubectl --insecure-skip-tls-verify  --kubeconfig ~/workspace/01_powertech/kube/tienvv.conf"
alias klf='kubectl logs --tail=200  -f'
alias kgs='kubectl get service -o wide'
alias kgd='kubectl get deployment -o wide'
alias kgp='kubectl get pod -o wide'
alias kgn='kubectl get node -o wide'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kgsa='kubectl get service -o wide --all-namespaces'
alias kgda='kubectl get deployment -o wide --all-namespaces'
alias kgpa='kubectl get pod -o wide --all-namespaces'
alias kgna='kubectl get node -o wide --all-namespaces'
alias kdpa='kubectl describe pod --all-namespaces'
alias kdsa='kubectl describe service --all-namespaces'
alias kdd='kubectl describe deployment'
alias kdf='kubectl delete -f'
alias kaf='kubectl apply -f'
alias kak='kubectl apply -k'
alias kci='kubectl cluster-info'
alias uil='kubectl get nodes --no-headers | awk '\''{print $1}'\'' | xargs -I {} sh -c '\''echo {} ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo '\'''
alias kgc='k config get-contexts'
alias kuc='k config use-context'
alias kscn='k config set-context --current --namespace="$1"'
alias kdn='k describe no'
alias kgn='k get no'
alias kd='k describe'
# eksctl
fpath=($fpath ~/.zsh/completion)
# helm
[ -x "$(command -v helm)" ] &&  source <(helm completion zsh)

# flux
command -v flux >/dev/null && . <(flux completion zsh)

# added by travis gem
[ ! -s $HOME/.travis/travis.sh ] || source $HOME/.travis/travis.sh

# ZVM Zsh Vim Mode
# source /usr/local/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# git alias
alias g="git"
alias gp="git push"
alias ga="git add"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Terraform
# export PATH="$HOME/.tfenv/bin:$PATH"
# complete -o nospace -C /usr/local/bin/terragrunt terragrunt

# GO with custom installation path
export GOROOT=/usr/local/go/bin/go
export GOPATH=$HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH


# Timestamp to terminal for logging
preexec() {
    print -P "%F{240}[$(date +'%Y%m%dT%H%M%S')]%f"
}

# Border title reflects AWS context after each command (including awssso)
_precmd_border_title() {
    [[ -z "$TMUX" ]] && return
    local title=""
    [[ -n "$AWS_PROFILE" ]] && title="$AWS_PROFILE"
    [[ -n "$AWS_REGION" ]]  && title+=" | $AWS_REGION"
    [[ -z "$title" ]] && return

    local danger=0
    local danger_profiles=(admin master-admin master-ro)
    for kw in "${danger_profiles[@]}"; do
        [[ "$AWS_PROFILE" == *"$kw"* ]] && danger=1 && break
    done

    if (( danger )); then
        printf '\033]2;⚠ %s ⚠\033\\' "$title"
    else
        printf '\033]2;%s\033\\' "$title"
    fi
}
add-zsh-hook precmd _precmd_border_title

# add Pulumi to the PATH
# export PATH=$PATH:/home/tienvv-eh/.pulumi/bin


# WSL2 specific setups
if [[ $WSL_DISTRO_NAME == "Ubuntu" ]]; then
    # export BROWSER=/usr/bin/wslview
    export BROWSER="/mnt/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
elif [[ "$(uname)" == "Darwin" ]]; then
    export BROWSER="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
fi
#if [[ $- == *i* ]]; then
#  if [[ -z "$SCRIPT_RUNNING" ]]; then
#    export SCRIPT_RUNNING=1
#    script -a $HOME/workspace/90_bash_logs/$( date +"%Y%m%dT%H%M%S" )-$WT_SESSION.log
#    exit
#  fi
#fi
#
# custom scripts
PATH=$HOME/.local/scripts:$PATH
autoload -U +X bashcompinit && bashcompinit


# java
export PATH=$PATH:/opt/gradle/gradle-9.0.0/bin

if [ -e /home/tienvv/.nix-profile/etc/profile.d/nix.sh ]; then . /home/tienvv/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# Hook
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path=""
  nvmrc_path="$(nvm_find_nvmrc 2>/dev/null)"
  if [ -n "$nvmrc_path" ]; then
    nvm use --silent >/dev/null || nvm install
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
