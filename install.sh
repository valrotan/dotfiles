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

for fname in .zshrc .vimrc .tmux.conf; do
    [ -e ~/$fname ] && mv ~/$fname ~/$fname.before_dotfiles
    ln -s $DOTFILES/$fname ~/$fname
done;
