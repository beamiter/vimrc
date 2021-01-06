" autocmd VimEnter * call Rooter

" previously set colorscheme here
"codedark  dracula alduin ayu space-vim-dark
colorscheme angr

" update local colorscheme here
let s:local_color = $HOME..'/.vim/local_color.vim'
if filereadable(s:local_color)
  execute("source"..s:local_color)
endif

function! s:UpdateLocalColorScheme() abort
  let l:current_color = execute("colorscheme")[1:]
  "echomsg s:local_color
  let l:color_list = ["colorscheme "..l:current_color]
  "echomsg l:current_color
  if !filereadable(s:local_color)
    call writefile(l:color_list, s:local_color, 'a')
  else
    call writefile(l:color_list, s:local_color, 'a')
    "for line in readfile(s:local_color, '')
      ""echomsg line
    "endfor
  endif
endfunction

command! UpdateLocalCS call s:UpdateLocalColorScheme()
"call s:UpdateLocalColorScheme()

" must indent properly
function! GenerateRandomNumber(low, high) abort
python3 << EOF

import vim
import random

idx = random.randint(int(vim.eval('a:low')), int(vim.eval('a:high')))

vim.command("let index = {}".format(idx))
EOF

return index
endfunction

function! GetRandomColorScheme() abort
  let s:colorschemes = getcompletion('', 'color')
  let s:len = len(s:colorschemes)
  let s:id = GenerateRandomNumber(0, s:len)
  echomsg 'colorscheme total number: '.s:len.' selected: '.s:id.' '.s:colorschemes[s:id]
  exe 'colorscheme '.s:colorschemes[s:id]
  redraw
endfunction

command! -nargs=0 -bang RandomLocalCS call GetRandomColorScheme()
nnoremap <Space><Space> :<C-u>RandomLocalCS<CR>
