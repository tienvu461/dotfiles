# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin::/usr/local/go/bin:$PATH

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
plugins=(git git-flow brew history node npm)

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
export PATH=$PATH:/opt/nvim-linux64/bin
alias vi=nvim
# Compilation flags
# export ARCHFLAGS="-arch x86_64"

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

# get pacman vpn password
alias pacman_vpn="echo 'i.|/B1[iz.' | pbcopy"

# show export PATH
alias export_path="echo 'export \$PATH=\$PATH:/usr/bin'"

# open note.txt
alias note_file="nvim $HOME/TienVu/myWS/10_myScript/notes/note.txt"

# assume-role aws
# make sure pecu, assume-role were installed
function aws_set() {
    BASTION=$1
    AWS_PROFILE=$(grep -iE "\[*\]" ~/.aws/credentials | tr -d "[]" | peco)
    # assume-role $BASTION $AWS_PROFILE
    if ! command -v decrypt.key.sh &> /dev/null
    then
        eval $(assume-role $AWS_PROFILE)
    else
        eval $(decrypt.key.sh $BASTION | assume-role $AWS_PROFILE)
    fi
}

# ssh quick select
# make sure pecu was installed
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

# kubectl settings

export BASH_COMPLETION_COMPAT_DIR=/usr/local/etc/bash_completion.d
[[ -r /usr/local/etc/profile.d/bash_completion.sh ]] && . /usr/local/etc/profile.d/bash_completion.sh

export LBC_VERSION="v2.0.0"
[ -x "$(command -v kubectl)" ] &&  source <(kubectl completion zsh)
#alias k='kubectl'
alias k="kubectl --insecure-skip-tls-verify  --kubeconfig ~/workspace/01_powertech/kube/tienvv.conf"
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
# added by travis gem
[ ! -s $HOME/.travis/travis.sh ] || source $HOME/.travis/travis.sh

# ZVM Zsh Vim Mode
# source /usr/local/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Terraform
export PATH="$HOME/.tfenv/bin:$PATH"
