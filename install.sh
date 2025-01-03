#!/bin/bash

set -e

# setup repo
DOTFILES=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $DOTFILES

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)
        machine=Linux
        nvim_url='https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz'
        ;;
    Darwin*)
        nvim_url='https://github.com/neovim/neovim/releases/latest/download/nvim-macos-arm64.tar.gz'
        machine=Mac
        ;;
    *)
        machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

git submodule update --init --recursive

# setup nvim
# cd neovim
# make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$DOTFILES/neovim"
# make install
# cd ..
if [ -z $nvim_url ]; then
    echo Could not find Neovim installation for $machine. Please install it yourself under nvim/;
else
    wget -O nvim.tar.gz $nvim_url
    [ -e nvim ] && mv nvim nvim.old
    mkdir nvim && tar -xzf nvim.tar.gz -C nvim --strip-components 1
    rm nvim.tar.gz
fi

# setup fzf
.fzf/install --bin

# setup zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# link dotfiles
link() {
    local from="$1" to="$2"
    [ -e $from ] && mv $from $from.before_dotfiles
    ln -s $DOTFILES/$to $from
}
link "$HOME/.zshrc" ".zshrc"
link "$HOME/.vimrc" ".vimrc"
link "$HOME/.tmux.conf" ".tmux.conf"
mkdir -p "$HOME/.config/nvim/"
link "$HOME/.config/nvim/init.vim" ".vimrc"
link "$HOME/.config/nvim/nvim_config.lua" "nvim_config.lua"
