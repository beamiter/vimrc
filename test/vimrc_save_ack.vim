set nocompatible nomore
let s:root = fnamemodify(expand('<sfile>'), ':p:h:h')
let s:errors = s:root .. '/test/save-ack-errors.log'
call delete(s:errors)
let s:file = tempname()
call writefile(['original'], s:file)
execute 'edit ' .. fnameescape(s:file)
setlocal buftype=acwrite
let s:result = 'success'
let s:delay = 100
let s:serial = 0
function! s:Finish(buffer, identity, result, timer) abort
  let l:state = getbufvar(a:buffer, 'vimrc_remote_write_state', {})
  if get(l:state, 'serial', -1) != a:identity.serial
        \ || get(l:state, 'generation', -1) != a:identity.generation
    return
  endif
  if getbufvar(a:buffer, 'changedtick') != a:identity.tick
    let l:state.status = 'stale'
    call setbufvar(a:buffer, '&modified', 1)
  else
    let l:state.status = a:result
    call setbufvar(a:buffer, '&modified', a:result !=# 'success')
  endif
  let l:state.message = a:result ==# 'error' ? 'test write failure' : ''
endfunction
function! s:Begin() abort
  let s:serial += 1
  let b:vimrc_remote_write_state = {'serial':s:serial, 'generation':1,
        \ 'tick':b:changedtick, 'final_eol': !!(&endofline || (&fixendofline && !&binary)),
        \ 'status':'pending', 'message':'', 'path':get(get(b:, 'vimrc_remote', {}), 'path', '')}
  call timer_start(s:delay, function('s:Finish', [bufnr(), copy(b:vimrc_remote_write_state), s:result]))
endfunction
augroup AckSaveTest
  autocmd!
  autocmd BufWriteCmd <buffer> call s:Begin()
augroup END
" Test the no-policy native save/build helper against real ACK metadata.
if !exists('*g:VimrcProjectRoot')
  function! g:VimrcProjectRoot() abort
    return '/test'
  endfunction
endif
if !exists('*g:VimrcSave')
  execute 'source ' .. fnameescape(s:root .. '/config/save.vim')
endif
augroup AckSaveTest
  autocmd!
  autocmd BufWriteCmd <buffer> call s:Begin()
augroup END
let s:result = 'success'
call s:Begin()
setlocal nomodified
call assert_equal('pending', g:VimrcSaveWait(10).status)
call assert_equal('success', g:VimrcSaveWait(250).status)
call s:Begin()
setlocal nomodified
call assert_equal('pending', g:VimrcSaveAllWait(10).status)
call assert_equal('success', g:VimrcSaveAllWait(250).status)
call setline(1, 'dirty pending write')
call s:Begin()
let s:pending_serial = s:serial
call assert_equal('success', g:VimrcSaveAllWait(250).status)
call assert_equal(s:pending_serial, s:serial, 'save-all waits existing pending write without retransmitting')
setlocal nofixendofline endofline
call s:Begin()
setlocal nomodified
sleep 150m
setlocal noendofline nomodified
call assert_equal('error', g:VimrcSaveWait(50).status)
setlocal endofline fixendofline
let b:vimrc_remote = {'path':'/first.rs'}
call s:Begin()
setlocal nomodified
sleep 150m
let b:vimrc_remote.path = '/other.rs'
call assert_equal('error', g:VimrcSaveWait(50).status)
unlet b:vimrc_remote
let s:result = 'error'
call s:Begin()
setlocal nomodified
call assert_equal('error', g:VimrcSaveWait(250).status)
let s:result = 'success'
call s:Begin()
setlocal nomodified
call timer_start(30, {_->setline(1, 'typing while waiting')})
call assert_equal('error', g:VimrcSaveWait(250).status)
sleep 150m
" A completed read retires old ACK metadata; a clean buffer is already saved.
let b:vimrc_remote_write_state = {}
setlocal nomodified
call assert_equal('success', g:VimrcSaveWait(20).status)
augroup AckSaveTest
  autocmd!
augroup END
if !empty(v:errors)
  call writefile(v:errors, s:errors)
  cquit
endif
qa!
