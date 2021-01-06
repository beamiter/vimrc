" autocmd VimEnter * call Rooter

" previously set colorscheme here
"codedark  dracula alduin ayu space-vim-dark
colorscheme angr

" update local colorscheme here
let s:local_color = $HOME..'/.config/local_color.vim'

function! s:UpdateLocalColorScheme() abort
  let l:current_color = execute("colorscheme")[1:]
  "echomsg s:local_color
  let l:color_list = ["colorscheme "..l:current_color]
  "echomsg l:current_color
  if !filereadable(s:local_color)
    call writefile(l:color_list, s:local_color, 'a')
  else
    "call writefile(l:color_list, s:local_color, 'a')
    "for line in readfile(s:local_color, '')
      ""echomsg line
    "endfor
    execute("source"..s:local_color)
  endif
endfunction

command! UpdateLocalCS call s:UpdateLocalColorScheme()
call s:UpdateLocalColorScheme()
