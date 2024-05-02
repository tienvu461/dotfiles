# dotfiles

My personal dotfiles for the following programs:

- zsh
- Git
- NeoVim (prequesite):

```
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
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

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz

echo export PATH="$PATH:/opt/nvim-linux64/bin" >> ~/.zshrc

### To start install vim plugin

:PlugInstall

## Install alacritty

sudo add-apt-repository ppa:aslatter/ppa -y
sudo apt install alacritty

## Install Ubuntu NerdFont

curl -LO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/UbuntuMono.zip
unzip -d Ubuntu.zip ~/.fonts
fc-cache -fv

## Install tmux

apt install tmux

## Install node with nvm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 16

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

curl -LO https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
