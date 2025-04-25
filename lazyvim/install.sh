rm ~/.config/nvim* -rf
rm ~/.local/share/nvim* -rf
rm ~/.locah/state/nvim* -rf
rm ~/.cache/nvim* -rf
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
