" Set default colorscheme here
"codedark  dracula alduin ayu space-vim-dark
colorscheme angr

" Json to store ever-selected colorscheme info
let s:local_color_json = $HOME..'/.vim/color.json'
" Store activate last colorscheme command
let s:local_color_vim = $HOME..'/.vim/color.vim'
" Dict to load colorscheme config info from json
let s:local_color_conf = {}
" Key to represent last selected colorscheme
let s:local_color_key = 'selected_color_scheme'
" restore last colorscheme at startup
if filereadable(s:local_color_vim)
  execute 'source' s:local_color_vim
endif
"" Try to reload laste selected colorscheme by json
"" But it is too slow to decode json at the startup
"if filereadable(s:local_color_json)
  "let s:local_color_conf = json_decode(join(readfile(s:local_color_json, ''), ''))
  "if has_key(s:local_color_conf, s:local_color_key)
    "execute 'colorscheme' s:local_color_conf[s:local_color_key]
    "redraw
  "endif
"endif

function! s:UpdateLocalColorScheme() abort
  " Get current colorscheme
  let color_current = execute("colorscheme")[1:]
  " Initialize colorscheme json config file
  if !filereadable(s:local_color_json)
    let s:local_color_conf = {color_current : 1}
    let s:local_color_conf[s:local_color_key] = color_current
  else
    " Load config info
    let s:local_color_conf = json_decode(join(readfile(s:local_color_json, ''), ''))
    " Update colorscheme dictionary
    if has_key(s:local_color_conf, color_current)
      let s:local_color_conf[color_current] += 1
    else
      let s:local_color_conf[color_current] = 1
    endif
    " Update the selected colorscheme
    let s:local_color_conf[s:local_color_key] = color_current
  endif
  " Rewrite config json file
  call writefile([json_encode(s:local_color_conf)], s:local_color_json)
  " Store activate last colorscheme command
  call writefile(['colorscheme '..color_current], s:local_color_vim)
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

let s:buf_nr_list = []
function s:UpdateBufferList() abort
  if empty(s:buf_nr_list)
    call extend(s:buf_nr_list, filter(range(1, bufnr('$')), 'buflisted(v:val)'))
  else
    let cur_nr = bufnr('%')
    if index(s:buf_nr_list, cur_nr) == -1
      call add(s:buf_nr_list, cur_nr)
    endif
    " echomsg s:buf_nr_list
    filter(s:buf_nr_list, 'buflisted(v:val)')
    " echomsg s:buf_nr_list
  endif
endfunction
command! UpdateBL call s:UpdateBufferList()

"call s:UpdateBufferList()
"echomsg s:buf_nr_list

function s:GetBufferNames(buf_list) abort
  let buf_nr = deepcopy(a:buf_list)
  return map(buf_nr, 'fnamemodify(bufname(v:val), ":t")')
endfunction

"echomsg s:GetBufferNames(s:buf_nr_list)
"echomsg s:buf_nr_list

" <TODO>
function UpdateTabLine()
  let s = ''
  call s:UpdateBufferList()
  let names = s:GetBufferNames(s:buf_nr_list)

  for i in range(len(names))
    let s .= '%#TabLineSel#'
    let s .= '[ '.(i + 1).' ]'.names[i]
    "let s .= '%#TabLineSel#'
    let s .= ' | '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  "let s .= '%#TabLineFill#%T'
  "let s .= '%=%#TabLine#%999Xclose'

  " echomsg s
  let &tabline = s
endfunction
