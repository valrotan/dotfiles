#!/bin/bash

set -e

DOTFILES=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $DOTFILES

git submodule update --init --recursive

# setup nvim
cd neovim
make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$DOTFILES/neovim"
make install
cd ..

# setup fzf
.fzf/install --bin

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
