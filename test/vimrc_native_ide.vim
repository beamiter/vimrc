vim9script

set nomore

const ROOT = g:vimrc_root

def Reload()
  execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
enddef

def View(): dict<any>
  return {wrap: &l:wrap, spell: &l:spell, list: &l:list,
    conceallevel: &l:conceallevel, foldcolumn: &l:foldcolumn,
    foldenable: &l:foldenable, signcolumn: &l:signcolumn}
enddef

# Render protocol 8 paints closed folds and protocol 9 soft-wrapped lines
# natively. Until a bridge reports an older protocol, the native view keeps
# the window's folding and wrapping (the FileType baseline wraps).
var nativeFolds = true
var nativeWrap = true

def AssertNative(label: string)
  assert_equal({wrap: nativeWrap, spell: false, list: false,
    conceallevel: 0, foldcolumn: 0, foldenable: nativeFolds, signcolumn: 'yes'},
    View(), label)
enddef

# The normal shell profile remains unchanged, even with a stale inherited
# address from an outer editor. A complete handshake is required at startup.
assert_false(g:VimrcNativeIde())
$JTERM_VIM9_ADDR = '127.0.0.1:12345'
$JTERM_VIM9_TOKEN = ''
assert_false(g:VimrcNativeIde())
enew!
setlocal filetype=gitcommit
assert_true(&l:wrap)
assert_true(&l:spell)
assert_true(index(['auto:2', 'yes'], &l:signcolumn) >= 0)
assert_equal(1, g:simplecc_inlay_hints)
assert_equal(1, g:simplecc_signature_help)

# Native startup defaults run before plugins and override the ordinary
# FileType baseline only in file windows. Prose formatting still works.
$JTERM_VIM9_TOKEN = 'fixture-only-token'
Reload()
assert_true(g:VimrcNativeIde())
AssertNative('native gitcommit')
assert_equal(72, &l:textwidth)
assert_equal(0, g:simplecc_inlay_hints)
assert_equal(0, g:simplecc_signature_help)
setlocal filetype=markdown
assert_equal('markdown', &filetype)
setline(1, ['hard break  ', 'single ', '中 ', "tab\t "])
doautocmd BufWinEnter
AssertNative('native Markdown')
var matches = filter(getmatches(), (_, item) => item.group ==# 'ExtraWhitespace')
assert_equal(1, len(matches))
assert_notmatch('\\[_%zn]', matches[0].pattern,
  'Markdown decoration must use the supported native match atoms')
var original = '\m^[ \t]\+$\|\S\zs\%([ \t]*\t \?\| \)$'
for text in ['hard break  ', 'hard break   ', 'single ', "tab\t ",
  "tail \t", '  ', "\t", '中文 ', "e\u0301 ", 'clean', '']
  assert_equal(matchstrpos(text, original), matchstrpos(text, matches[0].pattern), text)
endfor
StripWhitespace
assert_equal(['hard break  ', 'single', '中', 'tab'], getline(1, '$'))

# Splits and window reentry reassert the view after a local display change.
var first = win_getid()
split
setlocal wrap spell list conceallevel=2 foldcolumn=2 foldenable signcolumn=auto
doautocmd BufWinEnter
AssertNative('split reentry')
var second = win_getid()
setlocal filetype=rust
assert_equal('rust', &filetype)
AssertNative('new filetype')

# The bridge deliberately removes TOKEN once authenticated. Reload from a
# plugin window must still update the ordinary windows in every tab.
tabnew
setlocal filetype=text
var third = win_getid()
setlocal wrap spell list conceallevel=2 foldcolumn=2 foldenable signcolumn=auto
noautocmd enew!
noautocmd setlocal buftype=nofile filetype=simpletree
setlocal wrap spell list conceallevel=2 foldcolumn=2 foldenable signcolumn=no
var plugin_view = View()
g:jterm_vim9_bridge_loaded = true
$JTERM_VIM9_TOKEN = ''
Reload()
assert_true(g:VimrcNativeIde())
assert_equal(plugin_view, View(), 'reload must preserve the focused plugin window')
noautocmd setlocal buftype= filetype=startify
Reload()
assert_equal(plugin_view, View(), 'a plugin filetype can also own an empty buftype window')
for id in [first, second]
  win_gotoid(id)
  AssertNative('reload ordinary split')
endfor
win_gotoid(third)
assert_equal(plugin_view, View(), 'entering a plugin window must preserve its view')

# Diff owns folds and its visual comparison options. Remote acwrite buffers
# retain their own window settings unless their live SimpleRemote identity matches.
enew!
setlocal filetype=cpp
setlocal diff nowrap spell list conceallevel=2 foldcolumn=2 foldenable signcolumn=auto
var diff_view = View()
doautocmd BufWinEnter
Reload()
assert_equal(diff_view, View(), 'diff display must survive native reload')
assert_true(&l:diff)
diffoff
# :diffoff restores the wrap that :diffthis saved; this fixture set diff
# directly, and soft wrap stays the user's choice in a native view.
setlocal wrap
doautocmd BufWinEnter
AssertNative('leaving diff')
setlocal rightleft
doautocmd BufWinEnter
assert_true(&l:rightleft, 'RTL remains a compatibility view')
setlocal norightleft
enew!
noautocmd setlocal buftype=acwrite filetype=text
setlocal wrap spell list conceallevel=2 foldcolumn=2 foldenable signcolumn=auto
var remote_view = View()
doautocmd BufWinEnter
assert_equal(remote_view, View(), 'remote views keep their own display')

file remote:///srv/project/main.rs
b:vimrc_remote = {path: '/srv/project/main.rs', uri: 'remote:///srv/project/main.rs', generation: 7}
g:simpleremote_workspace = {id: 7, mode: 'virtual', local_root: ''}
g:simpleremote_status = 'connected'
doautocmd BufWinEnter
AssertNative('connected virtual remote file')

# A later asynchronous reread of an already typed buffer has no FileType or
# WinEnter event. Both visible copies update while another buffer keeps focus.
var remote_buffer = bufnr()
var remote_first = win_getid()
split
var remote_second = win_getid()
for id in [remote_first, remote_second]
  win_execute(id, 'setlocal wrap spell list conceallevel=2 foldcolumn=2 foldenable signcolumn=auto')
endfor
new
var focused = win_getid()
setlocal buftype=nofile filetype=simpletree
setline(1, ['keep focus', 'and cursor'])
cursor(2, 3)
var focused_buffer = bufnr()
var focused_cursor = getcurpos()
var focused_view = View()
g:simpleremote_event = {event: 'SimpleRemoteBufferRead', bufnr: remote_buffer}
doautocmd User SimpleRemoteBufferRead
assert_equal(focused, win_getid(), 'async remote view must not steal focus')
assert_equal(focused_buffer, bufnr())
assert_equal(focused_cursor, getcurpos())
assert_equal(focused_view, View(), 'unrelated focused plugin view survives')
for id in [remote_first, remote_second]
  assert_false(getwinvar(id, '&spell'), 'async read updates every displayed target')
  assert_equal('yes', getwinvar(id, '&signcolumn'))
endfor
unlet g:simpleremote_event
close!
close!
win_gotoid(remote_first)

for scenario in ['optout', 'disconnected', 'generation', 'uri', 'projection', 'diff', 'plugin']
  setlocal wrap spell list conceallevel=2 foldcolumn=2 foldenable signcolumn=auto
  var preserved = View()
  g:vimrc_native_remote_view = scenario !=# 'optout'
  g:simpleremote_status = scenario ==# 'disconnected' ? 'disconnected' : 'connected'
  g:simpleremote_workspace.id = scenario ==# 'generation' ? 8 : 7
  g:simpleremote_workspace.local_root = scenario ==# 'projection' ? '/tmp/projection' : ''
  b:vimrc_remote.uri = scenario ==# 'uri' ? 'remote:///other.rs' : 'remote:///srv/project/main.rs'
  noautocmd setlocal filetype=rust
  if scenario ==# 'plugin'
    noautocmd setlocal filetype=simpletree
  elseif scenario ==# 'diff'
    setlocal diff
  endif
  doautocmd BufWinEnter
  assert_equal(preserved, View(), 'remote protection: ' .. scenario)
  setlocal nodiff
endfor
unlet g:vimrc_native_remote_view g:simpleremote_workspace g:simpleremote_status
unlet b:vimrc_remote


# An older host (render protocol 7) cannot paint folds or wrapped rows: its
# ready event turns both off in every native file window. Protocol 8 keeps
# folds on and protocol 9 also keeps soft wrap.
enew!
setlocal filetype=rust foldenable
assert_true(&l:wrap, 'native file windows wrap before the host is known')
var older = win_getid()
split
setlocal foldenable wrap
g:jterm_vim9_connected = true
g:jterm_vim9_render_protocol = 7
doautocmd <nomodeline> User JTermVim9Ready
nativeFolds = false
nativeWrap = false
AssertNative('older host, focused split')
win_gotoid(older)
AssertNative('older host, other split')
close
g:jterm_vim9_render_protocol = 8
nativeFolds = true
setlocal foldenable wrap
doautocmd <nomodeline> User JTermVim9Ready
doautocmd BufWinEnter
AssertNative('protocol 8 keeps folds but not wrap')
g:jterm_vim9_render_protocol = 9
nativeWrap = true
setlocal wrap
doautocmd <nomodeline> User JTermVim9Ready
doautocmd BufWinEnter
AssertNative('protocol 9 keeps soft wrap')
setlocal nowrap
doautocmd BufWinEnter
assert_false(&l:wrap, 'a user nowrap choice survives window reentry')
setlocal wrap
g:jterm_vim9_connected = false
g:jterm_vim9_render_protocol = 0

# Closed folds read like the code they hide, natively painted or not.
enew!
setlocal tabstop=4 shiftwidth=4 foldmethod=manual
setline(1, ["\tfn main() {  ", "\t\tbody\tvalue", "\t}", '', '" section {{{1', 'text'])
:1,3fold
assert_equal('    fn main() { ⋯ 3 lines ', foldtextresult(1))
setlocal foldminlines=0
:4,4fold
assert_equal('⋯ 1 line ', foldtextresult(4))
normal! zE
setlocal foldmethod=marker foldminlines<
assert_equal('" section ⋯ 2 lines ', foldtextresult(5))
setlocal foldmethod=manual

# Explicit plugin preferences are authoritative, including on reload. Manual
# hover/docs/minimap UI remains available with compatibility rendering.
g:simplecc_inlay_hints = 1
g:simplecc_signature_help = 1
execute 'source ' .. fnameescape(ROOT .. '/config/plugins.vim')
assert_equal(1, g:simplecc_inlay_hints)
assert_equal(1, g:simplecc_signature_help)
assert_equal(0, g:simplecc_virtual_diag)

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
