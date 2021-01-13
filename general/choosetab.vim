" This stores the bur nr in a list, the index refers to the number showed
" in the tab page, and the corresponding value refers to the buf nr
let s:buf_nr_list = []

" <TODO> Extend more flexibilities
" Update tab line
function s:UpdateTabLineFunc()
  if !buflisted(bufnr('%'))
    return
  endif
  let s = ''
  let i = 0
  let buf_info = getbufinfo({'buflisted':1})
  "call sort(buf_info, {a, b -> a.lastused < b.lastused})
  for buf in buf_info
    let i += 1
    " Use this tmp to decide append or insert.
    let tmp = ""
    let is_current = 0
    " Highlight selected.
    if buf.bufnr == bufnr('%')
      let is_current = 1
      let tmp .= '%#TabLineSel#'
    else
      let tmp .= '%#TabLine#'
    endif
    let name = fnamemodify(copy(buf.name), ':t')
    " 1-9
    if i <= 9
      let tmp .= '['.i.']'.name
    " a-z
    elseif i <= 35
      let tmp .= '['.nr2char(87 + i).']'.name
    else
      " Not support counting yet
      let tmp .= name
    endif
    let tmp .= '%#TabLine#'
    " Seperator
    let tmp .= ' | '

    if is_current
      let s = tmp.s
    else
      let s .= tmp
    endif
  endfor

  " Brilliant work, put selected at the first play all
  " the times
  let s .= '%#TabLineFill#%T'
  "let s .= '%=%#TabLine#%999Xclose'

  " Where to truncate line if too long.
  " Default is at the start.
  " No width fields allowed.
  let s .= '%<'

  " For debug
  "echomsg s
  let &l:tabline = s

  "let s:buf_nr_list = filter(range(1, bufnr('$')), 'buflisted(v:val)')
  let s:buf_nr_list = map(buf_info, 'v:val.bufnr')
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
   "autocmd BufWinEnter,BufEnter,BufLeave,BufWinLeave * call s:UpdateTabLineFunc()
   "autocmd WinEnter,WinLeave * call s:UpdateTabLineFunc()
   autocmd BufWinEnter * call s:UpdateTabLineFunc()
augroup END

" Initialize at the start
call s:UpdateTabLineFunc()
