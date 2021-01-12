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
  " Initialization
  if empty(s:buf_nr_list)
    let s:buf_nr_list = filter(range(1, bufnr('$')), 'buflisted(v:val)')
    return
  endif
  " Increasing update
  " Get current buf
  let cur_nr = bufnr('%')
  " Add new buf
  if index(s:buf_nr_list, cur_nr) == -1
    call add(s:buf_nr_list, cur_nr)
  endif
  " Remove not listed
  if !empty(s:buf_nr_list)
    " Pay attention to the grammar
    let s:buf_nr_list = filter(s:buf_nr_list, 'buflisted(v:val)')
  endif
  "echomsg s:buf_nr_list
endfunction

function s:GetBufferNames(buf_list) abort
  let buf_nr = deepcopy(a:buf_list)
  " Double check to ensure valid buf list
  let buf_nr = filter(buf_nr, 'buflisted(v:val)')
  return map(buf_nr, 'fnamemodify(bufname(v:val), ":t")')
endfunction

" <TODO>
function s:UpdateTabLine()
  let s = ''
  call s:UpdateBufferList()
  let names = s:GetBufferNames(s:buf_nr_list)

  for i in range(len(names))
    if names[i] ==# fnamemodify(bufname(), ':t')
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    let s .= '['.(i + 1).']'.names[i]
    let s .= '%#TabLine#'
    if i < len(names) - 1
      let s .= ' | '
    endif
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'
  "let s .= '%=%#TabLine#%999Xclose'

  "echomsg s
  let &l:tabline = s
endfunction

function JumpToBuffer(n) abort
  "echomsg s:buf_nr_list
  if a:n > len(s:buf_nr_list)
    echomsg 'The selected buffer number is not valid!'
    return
  endif
  if a:n == 0
    if len(s:buf_nr_list) >= 10
      execute 'buffer '.s:buf_nr_list[9]
    endif
  endif
  execute 'buffer '.s:buf_nr_list[a:n - 1]
endfunction

augroup tablinediy
  autocmd!
   autocmd BufWinEnter,BufEnter,BufWritePost,BufWinLeave * call s:UpdateTabLine()
augroup END

" Initialize at the start
call s:UpdateBufferList()
call s:UpdateTabLine()

noremap <leader>1 :<C-u>call JumpToBuffer(1)  <CR>
noremap <leader>2 :<C-u>call JumpToBuffer(2)  <CR>
noremap <leader>3 :<C-u>call JumpToBuffer(3)  <CR>
noremap <leader>4 :<C-u>call JumpToBuffer(4)  <CR>
noremap <leader>5 :<C-u>call JumpToBuffer(5)  <CR>
noremap <leader>6 :<C-u>call JumpToBuffer(6)  <CR>
noremap <leader>7 :<C-u>call JumpToBuffer(7)  <CR>
noremap <leader>8 :<C-u>call JumpToBuffer(8)  <CR>
noremap <leader>9 :<C-u>call JumpToBuffer(9)  <CR>
noremap <leader>0 :<C-u>call JumpToBuffer(10) <CR>
