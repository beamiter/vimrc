" This stores the bur nr in a list, the index refers to the number showed
" in the tab page, and the corresponding value refers to the buf nr
let s:buf_nr_list = []

" <TODO> Extend more flexibilities
" Update tab line
function s:UpdateTabLineFunc()
  if !buflisted(bufnr('%'))
    return
  endif
  let i = 0
  let tmp_dict = []
  let buf_info = getbufinfo({'buflisted':1})
  "call sort(buf_info, {a, b -> a.lastused < b.lastused})
  for buf in buf_info
    let i += 1
    " Use this tmp to decide append or insert.
    let tmp = ""
    let name = fnamemodify(buf.name, ':t')
    if buf.changed
      let tmp .= '+'
    endif

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
    " Highlight selected.
    if buf.bufnr == bufnr('%')
      let tmp = '%#TabLineSel#'..tmp
      call insert(tmp_dict, tmp)
    else
      let tmp = '%#TabLine#'..tmp
      call add(tmp_dict, tmp)
    endif

    "let s .= tmp
  endfor
  let s = join(tmp_dict, '')

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
   autocmd BufWinEnter,BufWritePost * call s:UpdateTabLineFunc()
augroup END

" Initialize at the start
call s:UpdateTabLineFunc()

function s:TestForFunFunc(...) abort
  echomsg a:0
  echomsg a:000
endfunction

command! -bang -bar -nargs=* TFT :call s:TestForFunFunc(<f-args>, <bang>0)
noremap <Plug>TFTPrompt :<c-u>TFT<Space>
