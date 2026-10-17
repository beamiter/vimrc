vim9script

set nomore

const ROOT = g:vimrc_root
var scratch = tempname()
mkdir(scratch, 'p')

def Whitespaces(): list<dict<any>>
  return filter(getmatches(), (_, item) => item.group ==# 'ExtraWhitespace')
enddef

# A single command preserves the user's view, registers, search and Markdown
# hard breaks, and a range limits what it changes. Bang is explicit removal.
enew!
setlocal filetype=markdown
var original = ['hard break  ', 'more spaces   ', 'single ', "tab\t ", '  ',
  'outside range ']
setline(1, original)
setreg('/', 'unrelated-search')
setreg('"', 'unrelated-yank')
cursor(2, 4)
var view = winsaveview()
var jumps = getjumplist()
:1,5StripWhitespace
assert_equal(['hard break  ', 'more spaces   ', 'single', 'tab', '',
  'outside range '], getline(1, '$'))
assert_equal(view, winsaveview())
assert_equal(jumps, getjumplist())
assert_equal('unrelated-search', getreg('/'))
assert_equal('unrelated-yank', getreg('"'))
StripWhitespace!
assert_equal(['hard break', 'more spaces', 'single', 'tab', '',
  'outside range'], getline(1, '$'))

# Semantically meaningful spaces alone must not dirty a Markdown document.
enew!
setlocal filetype=markdown
setline(1, ['hard break  ', 'hard break   '])
setlocal nomodified
StripWhitespace
assert_false(&modified)
b:vimrc_preserve_markdown_breaks = 0
StripWhitespace
assert_equal(['hard break', 'hard break'], getline(1, '$'))
unlet b:vimrc_preserve_markdown_breaks

# Window entry reuses one match, rather than allocating a new one every time.
# An external :clearmatches and reused numeric ID must not be mistaken for it.
enew!
setlocal filetype=vim
setline(1, ['alpha ', 'beta'])
doautocmd BufWinEnter
var matches = Whitespaces()
assert_equal(1, len(matches))
var match_id = matches[0].id
for _ in range(10)
  doautocmd WinEnter
  doautocmd BufWinEnter
endfor
assert_equal(match_id, Whitespaces()[0].id)
matchdelete(match_id)
matchadd('Search', 'alpha', 20, match_id)
doautocmd InsertEnter
assert_equal(1, len(filter(getmatches(), (_, item) => item.group ==# 'Search')))
matchdelete(match_id)
doautocmd InsertLeave
assert_equal(1, len(Whitespaces()))
b:vimrc_whitespace_highlight = 0
doautocmd BufWinEnter
assert_equal([], Whitespaces())
unlet b:vimrc_whitespace_highlight

# The same window's syntax and indentation belong to special buffers. The
# generic FileType handler must not flatten a plugin's own configuration.
for [kind, filetype] in [['nofile', 'simpletree'], ['help', 'help'],
  ['quickfix', 'qf'], ['prompt', 'terminal']]
  enew!
  noautocmd execute 'setlocal buftype=' .. kind .. ' filetype=' .. filetype
  setlocal nowrap conceallevel=2 shiftwidth=7 textwidth=65
  &l:completefunc = 'UserProvidedComplete'
  g:VimrcConfigureFiletype()
  assert_false(&l:wrap, filetype)
  assert_equal(2, &l:conceallevel, filetype)
  assert_equal(7, &l:shiftwidth, filetype)
  assert_equal(65, &l:textwidth, filetype)
  assert_equal('UserProvidedComplete', &l:completefunc, filetype)
  assert_equal([], Whitespaces(), filetype)
endfor

# A normal filetype's completion provider survives, and remote acwrite files
# retain normal editing support rather than being treated as plugin windows.
enew!
setlocal filetype=python
&l:completefunc = 'UserProvidedComplete'
g:VimrcConfigureFiletype()
assert_equal('UserProvidedComplete', &l:completefunc)
setlocal buftype=acwrite
setline(1, 'remote  ')
StripWhitespace
assert_equal('remote', getline(1))
setlocal buftype=nofile
setline(1, 'scratch  ')
StripWhitespace
assert_equal('scratch  ', getline(1))

# Initial cursor restoration includes a first-line column. A later read or
# checktime must not jump back to an old mark after the user moved elsewhere.
enew!
setline(1, ['abcdefghijk', 'second line'])
setpos("'\"", [bufnr(), 1, 6, 0])
unlet! b:vimrc_cursor_restored
doautocmd BufReadPost
assert_equal([1, 6], [line('.'), col('.')])
setpos("'\"", [bufnr(), 2, 3, 0])
cursor(1, 2)
doautocmd BufReadPost
assert_equal([1, 2], [line('.'), col('.')])

# BufEnter checks only the current file. Another hidden buffer is refreshed
# when entered, and a local unsaved edit is never overwritten on focus gain.
var first = scratch .. '/first.txt'
var second = scratch .. '/second.txt'
writefile(['first-original'], first)
writefile(['second-original'], second)
execute 'edit! ' .. fnameescape(first)
var first_buffer = bufnr()
execute 'edit ' .. fnameescape(second)
writefile(['first-changed-on-disk-and-longer'], first)
writefile(['second-changed-on-disk-and-longer'], second)
doautocmd BufEnter
assert_equal('second-changed-on-disk-and-longer', getline(1))
assert_equal(['first-original'], getbufline(first_buffer, 1))
execute 'buffer ' .. first_buffer
assert_equal('first-changed-on-disk-and-longer', getline(1))
setline(1, 'local-unsaved-edit')
writefile(['new-external-change'], first)
doautocmd FocusGained
assert_equal('local-unsaved-edit', getline(1))
assert_true(&modified)

# All plugin settings are defaults. These represent both .vimrc.before and
# interactive overrides; reloading must not silently turn them back on.
g:simplecc_auto_start = 0
g:simplecc_inlay_hints = 0
g:simpletree_width = 61
g:simplefinder_max_results = 77
g:simpleclipboard_auto_copy = 0
g:simplestartify_styles = ['minimal']
g:vimrc_colorscheme = 'default'
g:vimrc_background = 'light'
execute 'source ' .. fnameescape(ROOT .. '/config/plugins.vim')
assert_equal(0, g:simplecc_auto_start)
assert_equal(0, g:simplecc_inlay_hints)
assert_equal(61, g:simpletree_width)
assert_equal(77, g:simplefinder_max_results)
assert_equal(0, g:simpleclipboard_auto_copy)
assert_equal(['minimal'], g:simplestartify_styles)
assert_equal('default', g:colors_name)
assert_equal('light', &background)
var markers = g:vimrc_root_markers
g:vimrc_root_markers = ['custom-project-marker']
execute 'source ' .. fnameescape(ROOT .. '/config/plugins.vim')
assert_equal(g:vimrc_root_markers, g:simplefinder_root_markers)
g:simplefinder_root_markers = ['independent-finder-marker']
g:vimrc_root_markers = markers
execute 'source ' .. fnameescape(ROOT .. '/config/plugins.vim')
assert_equal(['independent-finder-marker'], g:simplefinder_root_markers)
unlet g:simplefinder_root_markers
execute 'source ' .. fnameescape(ROOT .. '/config/plugins.vim')
assert_equal(markers, g:simplefinder_root_markers)

# Compatibility can be installed late, as during one-launch bootstrap. No
# server is started here: only the plugins' documented mapping boundary is
# enabled, which is sufficient to exercise ownership and stale-map removal.
g:loaded_simplecc = 1
g:loaded_simplepairs = 1
g:vimrc_context.plugins_ready = true
execute 'source ' .. fnameescape(ROOT .. '/config/compat.vim')
doautocmd VimEnter
sleep 10m
enew!
# The LSP layer also preserves user mappings and releases only its own maps
# when protection activates; returning to a small file installs them again.
noautocmd setlocal filetype=rust
nnoremap gd user-global-definition
nnoremap <buffer> K user-buffer-hover
g:VimrcConfigureFiletype()
assert_equal('user-global-definition', maparg('gd', 'n'))
assert_equal('user-buffer-hover', maparg('K', 'n'))
assert_equal('<Plug>(simplecc-references)', maparg('gr', 'n'))
b:vimrc_large_file = 1
doautocmd User VimrcLargeFileChanged
assert_equal('user-global-definition', maparg('gd', 'n'))
assert_equal('user-buffer-hover', maparg('K', 'n'))
assert_equal('', maparg('gr', 'n'))
b:vimrc_large_file = 0
doautocmd User VimrcLargeFileChanged
assert_equal('<Plug>(simplecc-references)', maparg('gr', 'n'))
nunmap gd
nunmap <buffer> K
enew!
inoremap <CR> user-global-enter
doautocmd InsertEnter
assert_equal('user-global-enter', maparg('<CR>', 'i'))
inoremap <buffer> <CR> user-buffer-enter
doautocmd InsertEnter
assert_equal('user-buffer-enter', maparg('<CR>', 'i'))
iunmap <buffer> <CR>
iunmap <CR>
imap <buffer> <CR> <Plug>(simplepairs-enter)
doautocmd InsertEnter
assert_match('simplecc#SelectEnterKey', maparg('<CR>', 'i'))
assert_match('simplepairs#Enter', maparg('<CR>', 'i'))
g:simplepairs_default_mappings = 0
doautocmd InsertEnter
assert_equal('<Plug>(simplepairs-enter)', maparg('<CR>', 'i'))
g:simplepairs_default_mappings = 1
doautocmd InsertEnter
b:vimrc_large_file = 1
doautocmd User VimrcLargeFileChanged
assert_equal('<Plug>(simplepairs-enter)', maparg('<CR>', 'i'))
b:vimrc_large_file = 0
iunmap <buffer> <CR>
setlocal buftype=prompt
doautocmd InsertEnter
assert_equal('', maparg('<CR>', 'i'))
g:vimrc_context.plugins_ready = false
unlet g:loaded_simplecc g:loaded_simplepairs
execute 'source ' .. fnameescape(ROOT .. '/config/compat.vim')

# Exercise actual files, not only option strings: every recovery file remains
# within an XDG path containing both a comma and whitespace.
enew!
var previous_state = $XDG_STATE_HOME
$XDG_STATE_HOME = scratch .. '/state, with spaces'
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal($XDG_STATE_HOME .. '/vim/session', g:simplestartify_session_dir)
var custom_session = scratch .. '/custom-sessions'
g:simplestartify_session_dir = custom_session
execute 'source ' .. fnameescape(ROOT .. '/config/plugins.vim')
assert_equal(custom_session, g:simplestartify_session_dir)
unlet g:simplestartify_session_dir
execute 'source ' .. fnameescape(ROOT .. '/config/plugins.vim')
assert_equal($XDG_STATE_HOME .. '/vim/session', g:simplestartify_session_dir)
set updatecount=200
var recovery_file = scratch .. '/recovery.txt'
writefile(['recover-me'], recovery_file)
execute 'edit ' .. fnameescape(recovery_file)
var swap = swapname(bufnr())
assert_true(stridx(swap, $XDG_STATE_HOME .. '/vim/swap/') == 0, swap)
set backup backupskip=
setline(1, 'after-write')
write
assert_true(filereadable(undofile(recovery_file)), undofile(recovery_file))
var backups = glob($XDG_STATE_HOME .. '/vim/backup/*', false, true)
assert_equal(1, len(backups))
if len(backups) == 1
  assert_equal(['recover-me'], readfile(backups[0]))
endif
assert_equal(['after-write'], readfile(recovery_file))
enew!
$XDG_STATE_HOME = previous_state
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
delete(scratch, 'rf')

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
