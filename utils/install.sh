# 1, link ~/.vimrc to .vimrc
cd $HOME
ln -s $HOME/vimrc/.vimrc

# 2, link ~/.vim/* to following folders
cd $HOME/.vim
ln -s $HOME/vimrc/general/
ln -s $HOME/vimrc/keys/
ln -s $HOME/vimrc/plug/
ln -s $HOME/vimrc/plug-config/

# 3, option, link doom emacs config
cd $HOME/
ln -s $HOME/vimrc/.doom.d/
