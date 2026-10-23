vim9script
set nomore hidden
var root = tempname()
mkdir(root, 'p')
writefile(['first', 'position here'], root .. '/first.txt')
writefile(['second'], root .. '/second.txt')
execute 'edit ' .. fnameescape(root .. '/first.txt')
var first = bufnr()
cursor(2, 4)
split
vsplit
var ids = mapnew(getwininfo(), (_, w) => w.winid)
var layout = winlayout()
var origin = win_getid()
execute 'badd ' .. fnameescape(root .. '/second.txt')
g:VimrcCloseBuffer(first)
assert_equal(ids, mapnew(getwininfo(), (_, w) => w.winid), 'close preserves all split identities')
assert_equal(layout, winlayout(), 'close preserves split geometry')
assert_equal(origin, win_getid(), 'close keeps focus')
assert_equal([], win_findbuf(first))
assert_false(buflisted(first))
assert_true(g:VimrcCanReopenBuffer())
g:VimrcReopenBuffer()
assert_equal(root .. '/first.txt', expand('%:p'))
assert_equal([2, 4], [line('.'), col('.')])
assert_equal(layout, winlayout())
b:vimrc_remote_write_state = {status: 'pending'}
try
  g:VimrcCloseBuffer()
  assert_report('clean pending remote write must not close')
catch
  assert_match('Remote write pending', v:exception)
endtry
assert_true(buflisted(bufnr()))
assert_equal(layout, winlayout())
unlet b:vimrc_remote_write_state
setline(1, 'modified')
try
  g:VimrcCloseBuffer()
  assert_report('modified close must be refused')
catch
  assert_match('Unsaved changes', v:exception)
endtry
assert_equal('modified', getline(1))
assert_equal(layout, winlayout())
setlocal nomodified
only
for info in getbufinfo({buflisted: 1})
  if info.bufnr != bufnr()
    execute 'bdelete ' .. info.bufnr
  endif
endfor
var final_window = win_getid()
g:VimrcCloseBuffer()
assert_equal(final_window, win_getid(), 'last file keeps its window with an empty buffer')
assert_equal('', bufname())
assert_true(buflisted(bufnr()))
execute 'cd ' .. fnameescape(root)
g:VimrcReopenBuffer()
assert_equal(root .. '/first.txt', expand('%:p'), 'history stores absolute names across cwd changes')
assert_equal([2, 4], [line('.'), col('.')])
execute 'source ' .. fnameescape(g:vimrc_root .. '/config/buffers.vim')
assert_equal(2, exists(':VimrcCloseBuffer'))
assert_equal(2, exists(':VimrcReopenBuffer'))
if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
