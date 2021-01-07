" Set default colorscheme here
"codedark  dracula alduin ayu space-vim-dark
colorscheme angr

" Json to store ever-selected colorscheme info
let s:local_color_json = $HOME..'/.vim/color.json'
" Dict to load colorscheme config info from json
let s:local_color_conf = {}
" Key to represent last selected colorscheme
let s:local_color_key = 'selected_color_scheme'
" Try to reload laste selected colorscheme
if filereadable(s:local_color_json)
  let s:local_color_conf = json_decode(join(readfile(s:local_color_json, ''), ''))
  if has_key(s:local_color_conf, s:local_color_key)
    execute 'colorscheme' s:local_color_conf[s:local_color_key]
    redraw
  endif
endif

function! s:UpdateLocalColorScheme() abort
  " Get current colorscheme
  let l:color_current = execute("colorscheme")[1:]
  " Initialize colorscheme json config file
  if !filereadable(s:local_color_json)
    let s:local_color_conf = {l:color_current : 1}
    let s:local_color_conf[s:local_color_key] = l:color_current
  else
    " Load config info
    let s:local_color_conf = json_decode(join(readfile(s:local_color_json, ''), ''))
    " Update colorscheme dictionary
    if has_key(s:local_color_conf, l:color_current)
      let s:local_color_conf[l:color_current] += 1
    else
      let s:local_color_conf[l:color_current] = 1
    endif
    " Update the selected colorscheme
    let s:local_color_conf[s:local_color_key] = l:color_current
  endif
  " Rewrite config json file
  call writefile([json_encode(s:local_color_conf)], s:local_color_json)
endfunction

" Binding function calling whith command
command! UpdateLocalCS call s:UpdateLocalColorScheme()

" Must indent properly
" Generate random number binding python and vimscript
function! GenerateRandomNumber(low, high) abort

" Python binding part, pay attention to python version
" python/python3
python3 << EOF
import vim
import random
idx = random.randint(int(vim.eval('a:low')), int(vim.eval('a:high')))
vim.command("let index = {}".format(idx))
EOF

return index
endfunction

" Get random colorscheme by sampling index
" in the range of total colorscheme numbers
function! GetRandomColorScheme() abort
  let s:colorschemes = getcompletion('', 'color')
  let s:len = len(s:colorschemes)
  let s:id = GenerateRandomNumber(0, s:len)
  echomsg 'colorscheme total number: '.s:len.' selected: '.s:id.' '.s:colorschemes[s:id]
  exe 'colorscheme' s:colorschemes[s:id]
  redraw
endfunction

" Binding function calling whith command
command! -nargs=0 -bang RandomLocalCS call GetRandomColorScheme()
" Binding command with short key
nnoremap <Space><Space> :<C-u>RandomLocalCS<CR>
