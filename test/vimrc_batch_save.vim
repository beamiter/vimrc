vim9script
set nomore hidden

const ROOT = expand('<sfile>:p:h:h')
delete(ROOT .. '/test/batch-save-errors.log')
if !exists('*g:VimrcProjectRoot')
  def g:VimrcProjectRoot(): string
    return '/batch-test'
  enddef
endif
if !exists('*g:VimrcSaveAllWait')
  execute 'source ' .. fnameescape(ROOT .. '/config/save.vim')
endif
g:vimrc_save_projects = {}
const BASE = tempname()
mkdir(BASE, 'p')
var first = -1
var second = -1
var third = -1
var next_buffer = -1

def Setup()
  augroup BatchSaveFixture
    autocmd!
  augroup END
  silent! only!
  execute 'silent! :%bwipeout!'
  writefile(['first'], BASE .. '/first.txt')
  writefile(['second'], BASE .. '/second.txt')
  writefile(['third'], BASE .. '/third.txt')
  execute 'edit ' .. fnameescape(BASE .. '/first.txt')
  first = bufnr()
  second = bufadd(BASE .. '/second.txt')
  bufload(second)
  setbufvar(second, '&buflisted', 1)
  third = bufadd(BASE .. '/third.txt')
  bufload(third)
  setbufvar(third, '&buflisted', 1)
enddef

def DirtyNext()
  setbufline(next_buffer, 1, 'changed by another save')
enddef

def NewDirty()
  writefile(['new file'], BASE .. '/created.txt')
  next_buffer = bufadd(BASE .. '/created.txt')
  bufload(next_buffer)
  setbufvar(next_buffer, '&buflisted', 1)
  setbufline(next_buffer, 1, 'created dirty by a write hook')
enddef

def AsyncWrite(buffer: number)
  timer_start(30, (_) => setbufvar(buffer, '&modified', 0))
enddef

def ScheduleBufferChange()
  timer_start(20, (_) => ChangeBuffer())
enddef

def ChangeBuffer()
  execute 'hide buffer ' .. third
enddef

Setup()
setline(1, 'saved first')
setbufline(second, 1, 'saved second')
split
vsplit
var origin = win_getid()
var layout = winlayout()
var ids = mapnew(getwininfo(), (_, info) => info.winid)
var result = g:VimrcSaveAllWait(500)
assert_equal('success', result.status, 'all ordinary modified buffers are saved')
assert_equal(['saved first'], readfile(BASE .. '/first.txt'))
assert_equal(['saved second'], readfile(BASE .. '/second.txt'))
assert_equal(origin, win_getid(), 'save-all preserves focus')
assert_equal(first, bufnr(), 'save-all restores the source buffer')
assert_equal(layout, winlayout(), 'save-all preserves split geometry')
assert_equal(ids, mapnew(getwininfo(), (_, info) => info.winid))

Setup()
setline(1, 'first triggers a later buffer')
next_buffer = second
execute 'autocmd BatchSaveFixture BufWritePost <buffer=' .. first .. '> DirtyNext()'
result = g:VimrcSaveAllWait(500)
assert_false(result.status ==# 'success' && getbufvar(second, '&modified'),
  'a buffer that became dirty during save-all must not be skipped as originally clean')

Setup()
setline(1, 'first triggers a new buffer')
execute 'autocmd BatchSaveFixture BufWritePost <buffer=' .. first .. '> NewDirty()'
result = g:VimrcSaveAllWait(500)
assert_false(result.status ==# 'success' && getbufvar(next_buffer, '&modified'),
  'new modified buffers created during save-all must prevent false build success')

Setup()
setline(1, 'save then dirty again')
setbufline(second, 1, 'second redirties first')
next_buffer = first
execute 'autocmd BatchSaveFixture BufWritePost <buffer=' .. second .. '> DirtyNext()'
result = g:VimrcSaveAllWait(500)
assert_false(result.status ==# 'success' && getbufvar(first, '&modified'),
  'a previously saved buffer becoming dirty again must prevent false build success')

Setup()
setline(1, 'first can save')
setbufline(second, 1, 'readonly remains dirty')
setbufline(third, 1, 'must remain unsaved after an earlier failure')
setbufvar(second, '&readonly', 1)
result = g:VimrcSaveAllWait(500)
assert_equal('error', result.status)
assert_false(empty(result.message), 'the first failed write retains its explanation')
assert_notequal('A buffer changed while saving; build not started', result.message,
  'the first failure must not be replaced by the final dirty scan')
assert_true(getbufvar(second, '&modified'))
assert_true(getbufvar(third, '&modified'), 'save-all stops at the first failed write')
assert_equal(first, bufnr(), 'failed save-all restores the original buffer')
assert_equal(['second'], readfile(BASE .. '/second.txt'), 'read-only files are never forced')
assert_equal(['third'], readfile(BASE .. '/third.txt'), 'buffers after a failed write are not saved')

Setup()
setlocal buftype=acwrite
setline(1, 'remote async write')
execute 'autocmd BatchSaveFixture BufWriteCmd <buffer=' .. first .. '> AsyncWrite(' .. first .. ')'
result = g:VimrcSaveAllWait(500)
assert_equal('success', result.status, 'a no-policy asynchronous acwrite must await transport completion')
assert_false(getbufvar(first, '&modified'))

Setup()
setlocal buftype=acwrite
setline(1, 'write transport failure')
execute 'autocmd BatchSaveFixture BufWriteCmd <buffer=' .. first .. '> throw "fixture transport failure"'
result = g:VimrcSaveAllWait(500)
assert_equal('error', result.status)
assert_true(getbufvar(first, '&modified'))

Setup()
setlocal buftype=acwrite
setline(1, 'original remains unwritten')
execute 'autocmd BatchSaveFixture BufWriteCmd <buffer=' .. first .. '> ScheduleBufferChange()'
result = g:VimrcSaveAllWait(500)
assert_notequal('success', result.status, 'a write callback changing buffers cannot certify the old dirty buffer')
assert_true(getbufvar(first, '&modified'))
assert_equal(third, bufnr(), 'save-all does not override a focus change performed during a write')

Setup()
setline(1, 'zero deadline')
result = g:VimrcSaveAllWait(0)
assert_equal('pending', result.status)
assert_equal(['first'], readfile(BASE .. '/first.txt'))

augroup BatchSaveFixture
  autocmd!
augroup END
delete(BASE, 'rf')
if !empty(v:errors)
  writefile(v:errors, ROOT .. '/test/batch-save-errors.log')
  cquit
endif
qa!
