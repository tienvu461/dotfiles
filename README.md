# dotfiles

My personal dotfiles for the following programs:

- zsh
- Git
- NeoVim (prequesite):

```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```
## Prerequesites

```
sudo apt install unzip tmux git
```

## How to use

- Clone this repo
- Run `sh ./config.sh` and select an option

## Install ZSH & oh-my-zsh themes

###

sudo apt install zsh

### install oh-my-zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

## Install neovim

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

echo export PATH="$PATH:/opt/nvim-linux64/bin" >> ~/.zshrc

### To start install vim plugin

:PlugInstall

## Install alacritty

sudo add-apt-repository ppa:aslatter/ppa -y
sudo apt install alacritty

## Install fzf
curl -LO https://github.com/junegunn/fzf/releases/download/v0.60.3/fzf-0.60.3-linux_amd64.tar.gz
sudo tar -C /opt -xzf fzf-0.60.3-linux_amd64.tar.gz
sudo mv /opt/fzf /usr/bin/fzf

## Install Ubuntu NerdFont

curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/UbuntuMono.zip
unzip -d Ubuntu.zip ~/.fonts
fc-cache -fv

https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/UbuntuMono.zip

## Install tmux
apt install tmux
### Install tpm 
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
### Installing plugins
Add new plugin to ~/.tmux.conf with set -g @plugin '...'
Press prefix + I (capital i, as in Install) to fetch the plugin.
### Uninstalling plugins
Remove (or comment out) plugin from the list.
Press prefix + alt + u (lowercase u as in uninstall) to remove the plugin.

## Install node with nvm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 18

### Development

### aws cli

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

### assume-role

go get -u github.com/remind101/assume-role
or
go install github.com/remind101/assume-role@latest
or
Download binary directly and put in /usr/local/bin with group and mod

### tfenv

git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.zshrc

### go
export GOPATH=$HOME/go
curl -LO https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz

### gosak
VERSION=v0.0.4
OS=Linux
ARCH=$(uname -i)
curl -sSL -o gosak.tar.gz https://github.com/tienvu461/gosak/releases/download/${VERSION}/gosak_${OS}_${ARCH}.tar.gz
tar -xvf gosak.tar.gz
chmod +x gosak
./gosak version
# Optional
# mv gosak $GOPATH/bin/