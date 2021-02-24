"source $HOME/.vim/general/choosetab.vim
source $HOME/.vim/general/randomcolor.vim
command! -bang LS call fzf#run(fzf#wrap({'source': 'ls'}, <bang>0))
hi Normal ctermbg=NONE guibg=NONE
