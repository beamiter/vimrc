" This stores the bur nr in a list, the index refers to the number showed
" in the tab page, and the corresponding value refers to the buf nr
let s:buf_nr_list = []

" Update buffer number list
function s:UpdateBufferListFunc() abort
  " If empty, then nitialize and finish
  if empty(s:buf_nr_list)
    let s:buf_nr_list = filter(range(1, bufnr('$')), 'buflisted(v:val)')
    return
  endif

  " Increasing updating

  " Get current buf nr
  let cur_nr = bufnr('%')
  " If not stored, store it
  if index(s:buf_nr_list, cur_nr) == -1
    call add(s:buf_nr_list, cur_nr)
  endif
  " Remove the buf nr not listed in the list
  if !empty(s:buf_nr_list)
    " Pay attention to the grammar filter
    let s:buf_nr_list = filter(s:buf_nr_list, 'buflisted(v:val)')
  endif
  " For debug
  "echomsg s:buf_nr_list
endfunction

" Get corresponding buffer name according to bufer nr
function s:GetBufferNamesFunc(buf_list) abort
  " Deep copy to avoid data pollution
  let buf_nr = deepcopy(a:buf_list)
  " Double check to ensure valid buf nr list
  let buf_nr = filter(buf_nr, 'buflisted(v:val)')
  return map(buf_nr, 'fnamemodify(bufname(v:val), ":t")')
endfunction

" <TODO> Extend more flexibilities
" Update tab line
function s:UpdateTabLineFunc()
  let s = ''
  call s:UpdateBufferListFunc()
  let names = s:GetBufferNamesFunc(s:buf_nr_list)

  for i in range(len(names))
    " Highlight selected
    if names[i] ==# fnamemodify(bufname(), ':t')
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif
    " 0-9
    if i <= 9
      let s .= '['.(i + 1).']'.names[i]
    " a-z
    elseif i <= 35
      let s .= '['.nr2char(97 + i - 10).']'.names[i]
    else
      " Not support counting yet
      let s .= names[i]
    endif
    let s .= '%#TabLine#'
    if i < len(names) - 1
      " Seperator
      let s .= ' | '
    endif
  endfor

  let s .= '%#TabLineFill#%T'
  "let s .= '%=%#TabLine#%999Xclose'

  " For debug
  "echomsg s
  let &l:tabline = s
endfunction

" Enrich functionality and feature
function s:JumpToBufferFunc(n) abort
  " For debug
  "echomsg s:buf_nr_list

  if a:n =~ '\d'
    if a:n > 10 || a:n <= 0
      echomsg 'Must input 1-10 !'
      return
    endif
    if a:n > len(s:buf_nr_list)
      echomsg 'The buffer number input is not valid !'
    else
      execute 'buffer '.s:buf_nr_list[a:n - 1]
    endif
  elseif a:n =~ '\l'
    " Map 'a-z' to number
    let id = char2nr(a:n) - 86
    if id > len(s:buf_nr_list)
        echomsg 'The buffer number input is not valid !'
    else
      execute 'buffer '.s:buf_nr_list[id - 1]
    endif
  else
    echomsg 'Must input 1-10 or a-z !'
  endif
endfunction
command! -nargs=1 JumpToBuffer call s:JumpToBufferFunc(<args>)

" Group for the autocmd
augroup tablinediy
  autocmd!
   autocmd BufWinEnter,BufEnter,BufWritePost,BufWinLeave * call s:UpdateTabLineFunc()
   autocmd WinEnter,WinLeave * call s:UpdateTabLineFunc()
augroup END

" Initialize at the start
call s:UpdateTabLineFunc()
