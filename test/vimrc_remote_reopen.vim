vim9script
set nomore hidden
const ROOT = expand('<sfile>:p:h:h')
delete(ROOT .. '/test/remote-reopen-errors.log')
if !exists('*g:VimrcReopenBuffer')
  execute 'source ' .. fnameescape(ROOT .. '/config/buffers.vim')
endif
var behavior = 'success'
var request = 0
var source = -1

def Finish(buffer: number, serial: number)
  if !bufexists(buffer) || serial != request
    return
  endif
  setbufvar(buffer, 'vimrc_remote_read', {})
  if behavior ==# 'failure'
    return
  endif
  setbufline(buffer, 1, ['one', 'two', 'three', 'four remote code'])
  setbufvar(buffer, '&buftype', 'acwrite')
  setbufvar(buffer, '&modified', behavior ==# 'dirty')
  setbufvar(buffer, 'vimrc_remote', {path: '/fixture/code.rs', uri: 'remote:///fixture/code.rs', generation: 1})
  g:simpleremote_event = {type: 'buffer-read', bufnr: buffer, path: '/fixture/code.rs', workspace: {id: 1}}
  doautocmd <nomodeline> User SimpleRemoteBufferRead
enddef

def Read()
  if behavior ==# 'immediate-failure'
    return
  endif
  request += 1
  var token = request
  var buffer = bufnr()
  b:vimrc_remote_read = {request_id: token, tick: b:changedtick}
  timer_start(30, (_) => Finish(buffer, token))
enddef

augroup RemoteReopenFixture
  autocmd!
  autocmd BufReadCmd remote://* Read()
augroup END

def Setup()
  request += 1
  behavior = 'success'
  silent! only!
  execute 'silent! :%bwipeout!'
  g:vimrc_closed_buffers = []
  g:simpleremote_workspace = {id: 1, kind: 'ssh', target: 'fixture', root: '/fixture'}
  edit remote:///fixture/code.rs
  sleep 60m
  source = bufnr()
  cursor(4, 6)
  g:VimrcCloseBuffer()
  assert_equal(1, len(g:vimrc_closed_buffers))
enddef

Setup()
g:VimrcReopenBuffer()
assert_equal(1, len(g:vimrc_closed_buffers), 'pending read does not consume closed-file history')
sleep 60m
assert_equal([4, 6], [line('.'), col('.')], 'restore view after asynchronous content arrives')
assert_equal([], g:vimrc_closed_buffers, 'successful read consumes precisely its history entry')

Setup()
behavior = 'failure'
g:VimrcReopenBuffer()
sleep 60m
assert_equal(1, len(g:vimrc_closed_buffers), 'transport read failure retains retryable closed-file history')
behavior = 'success'
g:VimrcReopenBuffer()
sleep 60m
assert_equal('four remote code', getline(4), 'retry after a failed read fetches actual contents rather than accepting an empty cached placeholder')
assert_equal([4, 6], [line('.'), col('.')])
assert_equal([], g:vimrc_closed_buffers)


Setup()
g:VimrcReopenBuffer()
var remote_window = win_getid()
new
var unrelated_window = win_getid()
setline(1, 'user is working here')
var user_view = winsaveview()
sleep 60m
assert_equal(unrelated_window, win_getid(), 'late read never steals focus')
assert_equal('user is working here', getline(1))
assert_equal(user_view, winsaveview())
assert_equal([4, 6], getcurpos(remote_window)[1 : 2], 'restore the remote window while another window is active')
assert_equal([], g:vimrc_closed_buffers)
setlocal nomodified

Setup()
behavior = 'dirty'
g:VimrcReopenBuffer()
sleep 60m
assert_equal(1, len(g:vimrc_closed_buffers), 'a modified buffer does not accept a delayed restoration')
assert_true(&modified)
setlocal nomodified

Setup()
behavior = 'immediate-failure'
g:VimrcReopenBuffer()
assert_equal(1, len(g:vimrc_closed_buffers), 'a disconnected read that never started must retain history')

augroup RemoteReopenFixture
  autocmd!
augroup END
if !empty(v:errors)
  writefile(v:errors, ROOT .. '/test/remote-reopen-errors.log')
  cquit
endif
qa!
