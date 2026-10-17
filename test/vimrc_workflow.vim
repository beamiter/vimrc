vim9script

set nomore
const ROOT = g:vimrc_root
const FIXTURE = tempname()
mkdir(FIXTURE, 'p')

const ORIGINAL_THRESHOLDS = [g:vimrc_large_file_bytes,
  g:vimrc_large_file_lines, g:vimrc_large_file_line_bytes]

def Thresholds(bytes: any, lines: any = 0, line_bytes: any = 0)
  g:vimrc_large_file_bytes = bytes
  g:vimrc_large_file_lines = lines
  g:vimrc_large_file_line_bytes = line_bytes
enddef

def File(name: string, contents: list<string>): string
  var path = FIXTURE .. '/' .. name
  writefile(contents, path)
  return path
enddef

def Edit(path: string)
  execute 'edit! ' .. fnameescape(path)
enddef

def View(winid: number = win_getid()): dict<any>
  var info = getwininfo(winid)[0]
  var view: dict<any> = {}
  for name in ['foldmethod', 'foldenable', 'cursorline', 'relativenumber',
      'spell', 'conceallevel', 'wrap']
    view[name] = gettabwinvar(info.tabnr, info.winnr, '&' .. name)
  endfor
  return view
enddef

def Protection(): bool
  return get(b:, 'vimrc_large_file', 0) == 1
enddef

Thresholds(1024 * 1024)
var small = File('small.py', ['value = 42'])
Edit(small)
setlocal foldmethod=indent foldenable cursorline relativenumber
setlocal wrap conceallevel=1 synmaxcol=777 indentexpr=42 undolevels=321
b:simpletreesitter_disable = 0
var first = win_getid()
var first_view = View()
var buffer_options = {syntax: &l:syntax, synmaxcol: &l:synmaxcol,
  indentexpr: &l:indentexpr, undolevels: &l:undolevels,
  undofile: &l:undofile, swapfile: &l:swapfile}

# Existing views of the same buffer can have different user preferences.
vsplit
setlocal foldmethod=manual nofoldenable nocursorline norelativenumber
setlocal nowrap conceallevel=2
var second = win_getid()
var second_view = View()
win_gotoid(first)
VimrcLargeFile on
assert_true(Protection())
assert_equal('manual', b:vimrc_large_file_reason)
assert_equal(1, b:simpletreesitter_disable)
assert_equal('OFF', &l:syntax)
assert_equal('', &l:indentexpr)
assert_equal(100, &l:undolevels)
assert_false(&l:undofile)
assert_false(&l:swapfile)
assert_false(View(first).wrap)
assert_false(View(second).wrap)

# A split created while protection is active must inherit the source's saved
# normal view, rather than saving the temporarily disabled options as normal.
split
var third = win_getid()
assert_true(Protection())
assert_false(&l:wrap)
tab split
var fourth = win_getid()
assert_false(&l:wrap)
VimrcLargeFile off
assert_false(Protection())
assert_equal(0, b:simpletreesitter_disable)
assert_equal(first_view, View(first), 'first view was not restored')
assert_equal(second_view, View(second), 'independent second view was not restored')
assert_equal(first_view, View(third), 'new split lost the original view')
assert_equal(first_view, View(fourth), 'new tab lost the original view')
for [name, value] in items(buffer_options)
  assert_equal(value, eval('&l:' .. name), name .. ' was not restored')
endfor

# Reload while active must preserve the first snapshot and stay idempotent.
VimrcLargeFile on
execute 'source ' .. fnameescape(ROOT .. '/config/workflow.vim')
execute 'source ' .. fnameescape(ROOT .. '/config/workflow.vim')
assert_true(Protection())
VimrcLargeFile off
assert_equal(first_view, View())
assert_equal(777, &l:synmaxcol)
assert_equal(1, len(filter(copy(g:simpleline_custom_right),
  (_, value) => get(value, 'fn', '') ==# 'g:VimrcLargeFileStatusline')))

tabonly!
only!
# Manual mode must not revive recovery features the user/core had disabled.
setlocal noundofile noswapfile undolevels=-1
b:simpletreesitter_disable = 1
VimrcLargeFile on
assert_equal(-1, &l:undolevels)
VimrcLargeFile off
assert_false(&l:undofile)
assert_false(&l:swapfile)
assert_equal(-1, &l:undolevels)
assert_equal(1, b:simpletreesitter_disable)

# Disk protection starts before reading, and a smaller reread fully restores
# the original buffer options (including an originally absent plugin flag).
Thresholds(32)
var large = File('large.py', [repeat('x', 80)])
Edit(large)
var saved_recovery = copy(b:vimrc_large_file_saved)
assert_true(Protection())
assert_equal('bytes', b:vimrc_large_file_reason)
assert_false(&l:wrap)
var large_buf = bufnr()
Edit(small)
assert_false(Protection(), 'switching to a small buffer leaked the mode')
assert_equal(first_view, View(), 'large view leaked into a normal buffer')
execute 'buffer ' .. large_buf
assert_true(Protection())
assert_false(&l:wrap, 'returning to the large buffer lost its protection')
writefile(['x = 1'], large)
Edit(large)
assert_false(Protection(), 'shrinking a file and rereading kept protection')
assert_equal(saved_recovery.undofile, &l:undofile)
assert_equal(saved_recovery.swapfile, &l:swapfile)
assert_equal(0, exists('b:simpletreesitter_disable'))
assert_notequal('OFF', &l:syntax)

# The independent line-count and long-line cases are both below byte limits.
Thresholds(1024 * 1024, 3)
Edit(File('many-lines.txt', ['one', 'two', 'three']))
assert_true(Protection())
assert_equal('lines', b:vimrc_large_file_reason)
VimrcLargeFile off
setline(1, repeat('x', 200))
doautocmd TextChanged
assert_false(Protection(), 'manual off was ignored after an edit')
VimrcLargeFile auto
assert_true(Protection())

Thresholds(1024 * 1024, 0, 64)
Edit(File('long-line.txt', ['short', repeat('y', 100), 'short']))
assert_true(Protection())
assert_match('^long line 2$', b:vimrc_large_file_reason)
assert_false(&l:wrap)

# Startup sampling is explicitly bounded; a visit to a skipped long line is
# caught at CursorHold without rescanning thousands of lines on every edit.
var sampled_lines = repeat(['x'], 12000)
sampled_lines[5999] = repeat('z', 100)
Edit(File('sampled.txt', sampled_lines))
assert_false(Protection())
assert_true(b:vimrc_large_file_scan_limited)
cursor(6000, 1)
doautocmd CursorHold
assert_true(Protection())
assert_equal('long line 6000', b:vimrc_large_file_reason)

# Buffers growing in memory are protected without waiting for a disk write.
Thresholds(128)
Edit(File('growing.txt', ['small']))
assert_false(Protection())
setline(1, repeat('x', 200))
doautocmd TextChanged
assert_true(Protection())
assert_equal(201, b:vimrc_file_size)
setline(1, 'small again')
doautocmd TextChanged
assert_true(Protection(), 'protection should not oscillate on undo/edit')
VimrcLargeFile auto
assert_false(Protection())
assert_equal('', g:VimrcLargeFileStatusline())

Thresholds(1024 * 1024, 0, 64)
setline(1, repeat('z', 80))
doautocmd TextChangedI
assert_true(Protection(), 'insert-mode long-line growth was missed')
VimrcLargeFile off
Thresholds(0, 1, 1)
VimrcLargeFile auto
assert_false(Protection(), 'bytes=0 must retain the documented global opt-out')
VimrcLargeFile on
assert_true(Protection(), 'manual on must work when automatic detection is off')
VimrcLargeFile off
Thresholds('invalid', {}, [])
VimrcLargeFile auto
assert_false(Protection(), 'invalid settings should fail closed, not throw')
assert_match('用法', execute('VimrcLargeFile invalid'))
assert_equal('auto', b:vimrc_large_file_policy)
assert_equal(['auto'], getcompletion('VimrcLargeFile a', 'cmdline'))

enew!
setlocal buftype=nofile
setline(1, repeat('x', 100))
Thresholds(1, 1, 1)
doautocmd TextChanged
assert_false(Protection(), 'scratch buffers must not be treated as files')
assert_match('只用于', execute('VimrcLargeFile on'))

# Marker lookup is an on-demand filesystem walk with literal path handling.
Thresholds(1024 * 1024)
enew!
var old_cwd = getcwd()
var project = FIXTURE .. '/project with spaces'
mkdir(project .. '/src/deep', 'p')
writefile(['gitdir: /elsewhere/worktrees/demo'], project .. '/.git')
assert_equal(project, g:VimrcProjectRoot(project .. '/src/deep/new.rs'))
assert_equal(project, g:VimrcProjectRoot(project .. '/missing/nested/new.rs'))
writefile(['{}'], project .. '/src/package.json')
assert_equal(project .. '/src', g:VimrcProjectRoot(project .. '/src/deep/new.ts'))
var markers = g:vimrc_root_markers
g:vimrc_root_markers = []
execute 'lcd ' .. fnameescape(project .. '/src')
assert_equal(project .. '/src', g:VimrcProjectRoot(), 'unnamed buffer must start at cwd')
assert_equal('/', g:VimrcProjectRoot('/'))
g:vimrc_root_markers = [1, {}, '', '.git']
assert_equal(project, g:VimrcProjectRoot(project .. '/src/deep/new.rs'))
g:vimrc_root_markers = 'invalid'
assert_equal(project .. '/src', g:VimrcProjectRoot(project .. '/src'))
g:vimrc_root_markers = markers
execute 'VimrcRoot ' .. fnameescape(project .. '/src')
assert_equal(project .. '/src', getcwd())
VimrcRoot
assert_equal(project .. '/src', getcwd())
VimrcRoot!
assert_equal(0, haslocaldir())
assert_equal(project .. '/src', getcwd(-1))
execute 'cd ' .. fnameescape(old_cwd)

# Quickfix toggles show a bounded list without stealing editing focus.  Bang
# opts into focus; invoking from within the list closes its owning window.
Edit(small)
var origin = win_getid()
var entries: list<dict<any>> = []
for nr in range(1, 5)
  add(entries, {filename: small, lnum: 1, text: 'item ' .. nr})
endfor
setqflist(entries)
g:vimrc_quickfix_height = 2
QFToggle
var qf = getqflist({winid: 0}).winid
assert_true(qf > 0)
assert_equal(origin, win_getid())
assert_equal(2, getwininfo(qf)[0].height)
QFToggle
assert_equal(0, getqflist({winid: 0}).winid)
QFToggle!
assert_equal(getqflist({winid: 0}).winid, win_getid())
QFToggle
assert_equal(origin, win_getid())
setqflist([])
assert_match('为空', execute('QFToggle'))
assert_equal(origin, win_getid())

setloclist(0, entries)
LLToggle
var loc = getloclist(0, {winid: 0}).winid
assert_true(loc > 0)
assert_equal(origin, win_getid())
assert_equal(2, getwininfo(loc)[0].height)
LLToggle
assert_equal(0, getloclist(0, {winid: 0}).winid)
LLToggle!
assert_equal('qf', &filetype)
LLToggle
assert_equal(origin, win_getid())
setloclist(0, [])
assert_match('为空', execute('LLToggle'))

Thresholds(ORIGINAL_THRESHOLDS[0], ORIGINAL_THRESHOLDS[1], ORIGINAL_THRESHOLDS[2])
enew!
delete(FIXTURE, 'rf')
if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
