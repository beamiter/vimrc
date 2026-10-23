vim9script

set nomore

const ROOT = g:vimrc_root
var scratch = tempname()
mkdir(scratch, 'p')

# Exercise actual Visual keystrokes. Native Visual P keeps the source
# register while placing replacements correctly at line ends and in blocks.
# Isolate the default register from a live X clipboard and other Vim tests.
var paste_clipboard = &clipboard
set clipboard=
enew!
setline(1, 'abc')
setreg('"', 'Z')
feedkeys('gg$vp', 'xt')
assert_equal('abZ', getline(1), 'Visual paste replaces the final character in place')
assert_equal('Z', getreg('"'), 'Visual paste preserves the source register')
feedkeys('u', 'xt')
assert_equal('abc', getline(1), 'one undo restores the whole Visual replacement')
feedkeys("\<C-r>", 'xt')
assert_equal('abZ', getline(1), 'redo restores the whole Visual replacement')

enew!
setline(1, 'abcdef')
setreg('a', 'NAMED')
setreg('"', 'UNNAMED')
feedkeys('gg0vl"ap', 'xt')
assert_equal('NAMEDcdef', getline(1), 'Visual paste honors an explicit register')
assert_equal('NAMED', getreg('a'))
assert_equal('UNNAMED', getreg('"'))

enew!
setline(1, ['first', 'second', 'third'])
setreg('"', ['replacement'], 'V')
feedkeys('ggjVp', 'xt')
assert_equal(['first', 'replacement', 'third'], getline(1, '$'))
assert_equal(['replacement'], getreg('"', 1, true))
assert_equal('V', getregtype('"'))

enew!
setline(1, ['abcd', 'efgh'])
setreg('"', ['XY', 'ZW'], "\<C-v>2")
feedkeys("gg0l\<C-v>jlp", 'xt')
assert_equal(['aXYd', 'eZWh'], getline(1, '$'), 'Visual block replacement retains its columns')
assert_equal(['XY', 'ZW'], getreg('"', 1, true))
assert_equal("\<C-v>2", getregtype('"'))

enew!
setline(1, 'abcd')
var previous_selection = &selection
set selection=exclusive
setreg('"', 'Z')
feedkeys('gg0lvlp', 'xt')
assert_equal('aZcd', getline(1), 'exclusive selection replaces only selected characters')
assert_equal('Z', getreg('"'))
&selection = previous_selection
&clipboard = paste_clipboard

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
# Modern keys are local, optional and never replace user bindings.
command! SimpleCCDefinition echo ''
command! SimpleCCReferences echo ''
command! SimpleCCRename echo ''
command! SimpleCCAction echo ''
command! SimpleCCFormat echo ''
command! SimpleCCSignatureHelp echo ''
command! -nargs=1 SimpleCCPopupScroll echo ''
command! SimpleCCPopupClose echo ''
g:VimrcConfigureFiletype()
assert_equal('', maparg('<F12>', 'n'), 'unnamed scratch must keep native keys')
execute 'file ' .. fnameescape(tempname() .. '.rs')
g:VimrcConfigureFiletype()
assert_equal('<Plug>(simplecc-definition)', maparg('<F12>', 'n'))
assert_equal('<Plug>(simplecc-references)', maparg('<S-F12>', 'n'))
assert_equal('<Plug>(simplecc-rename)', maparg('<F2>', 'n'))
assert_equal('<Cmd>SimpleCCSignatureHelp<CR>', maparg('<C-g>s', 'i'))
for key in ['<C-g>f', '<C-g>b', '<C-g>q']
  assert_equal(1, maparg(key, 'i', false, true).buffer)
  assert_equal(1, maparg(key, 'i', false, true).expr)
  assert_equal(1, maparg(key, 'i', false, true).noremap)
endfor
assert_match('simplecc#PopupScrollKey(1,', maparg('<C-g>f', 'i'))
assert_match('simplecc#PopupScrollKey(-1,', maparg('<C-g>b', 'i'))
assert_match('simplecc#PopupCloseKey', maparg('<C-g>q', 'i'))
assert_equal('<Plug>(simplecc-format)', maparg('<leader>cf', 'x'))
assert_equal('<Plug>(simplecc-code-action)', maparg('<leader>ca', 'x'))
assert_equal(1, maparg('<C-f>', 'n', false, true).expr)
assert_equal(1, maparg('<C-f>', 'n', false, true).noremap)
assert_match('simplecc#PopupScrollKey(1,', maparg('<C-f>', 'n'))
assert_match('simplecc#PopupScrollKey(-1,', maparg('<C-b>', 'n'))
assert_equal('<Cmd>SimpleCCPopupClose<CR>', maparg('<leader>lq', 'n'))
setlocal buftype=acwrite
g:VimrcConfigureFiletype()
assert_equal('<Plug>(simplecc-definition)', maparg('<F12>', 'n'), 'remote acwrite code retains navigation')
assert_equal('<Plug>(simplecc-format)', maparg('<leader>cf', 'x'), 'remote acwrite code retains range editing')
setlocal buftype=
nnoremap <buffer> <F2> user-local-rename
nnoremap <F12> user-global-definition
g:VimrcConfigureFiletype()
assert_equal('user-global-definition', maparg('<F12>', 'n'))
assert_equal('user-local-rename', maparg('<F2>', 'n'))
setlocal readonly
g:VimrcConfigureFiletype()
assert_equal('<Plug>(simplecc-references)', maparg('<S-F12>', 'n'))
assert_match('simplecc#PopupScrollKey', maparg('<C-f>', 'n'))
assert_equal('<Cmd>SimpleCCSignatureHelp<CR>', maparg('<C-g>s', 'i'), 'readonly signature help remains available')
assert_match('simplecc#PopupScrollKey', maparg('<C-g>f', 'i'), 'readonly documentation remains navigable')
assert_equal('', maparg('<leader>cf', 'x'))
assert_equal('user-local-rename', maparg('<F2>', 'n'))
setlocal noreadonly
setlocal nomodifiable
g:VimrcConfigureFiletype()
assert_equal('<Cmd>SimpleCCSignatureHelp<CR>', maparg('<C-g>s', 'i'), 'nomodifiable signature help remains available')
assert_equal('', maparg('<leader>cf', 'x'), 'nomodifiable buffer has no range-editing shortcut')
assert_equal('user-local-rename', maparg('<F2>', 'n'), 'user rename mapping remains owned by the user')
nunmap <buffer> <F2>
g:VimrcConfigureFiletype()
assert_equal('', maparg('<F2>', 'n'), 'nomodifiable buffer has no owned rename shortcut')
nnoremap <buffer> <F2> user-local-rename
setlocal modifiable
inoremap <C-g>f user-global-doc-scroll
inoremap <buffer> <C-g>q user-buffer-doc-close
g:VimrcConfigureFiletype()
assert_equal('user-global-doc-scroll', maparg('<C-g>f', 'i'))
assert_equal('user-buffer-doc-close', maparg('<C-g>q', 'i'))
iunmap <C-g>f
iunmap <buffer> <C-g>q
nunmap <F12>
nunmap <buffer> <F2>
g:VimrcConfigureFiletype()
execute 'source ' .. fnameescape(ROOT .. '/config/behavior.vim')
g:VimrcConfigureFiletype()
assert_equal(1, maparg('<F12>', 'n', false, true).buffer)
delcommand SimpleCCDefinition
g:VimrcConfigureFiletype()
assert_equal('', maparg('<F12>', 'n'))
command! SimpleCCDefinition echo ''
g:VimrcConfigureFiletype()
assert_equal('<Plug>(simplecc-definition)', maparg('<F12>', 'n'))
b:vimrc_large_file = 1
doautocmd User VimrcLargeFileChanged
assert_equal('', maparg('<F12>', 'n'))
assert_equal('', maparg('<leader>ca', 'x'))
for key in ['<C-g>f', '<C-g>b', '<C-g>q']
  assert_equal('', maparg(key, 'i'), 'large-file mode retires owned document keys')
endfor
b:vimrc_large_file = 0
noautocmd setlocal filetype=text
g:VimrcConfigureFiletype()
assert_equal('', maparg('<F12>', 'n'))
assert_equal('', maparg('<C-f>', 'n'))
assert_equal('', maparg('<C-b>', 'n'))
for key in ['<C-g>f', '<C-g>b', '<C-g>q']
  assert_equal('', maparg(key, 'i'), 'filetype changes retire owned document keys')
endfor
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
# ScriptCmd keeps Visual active, so '< and '> may still name an older
# selection. Exercise the actual mapping with a deterministic send provider.
var terminal_runtime = scratch .. '/terminal-runtime'
mkdir(terminal_runtime .. '/autoload', 'p')
writefile(['vim9script', 'export def Send(text: string)',
  '  g:vimrc_sent_lines = text', 'enddef'], terminal_runtime .. '/autoload/simpleterminal.vim')
execute 'set runtimepath^=' .. fnameescape(terminal_runtime)
execute 'source ' .. fnameescape(ROOT .. '/config/mappings.vim')
enew!
setline(1, ['one', 'two', 'three', 'four', 'five', 'six'])
setpos("'<", [0, 0, 0, 0])
setpos("'>", [0, 0, 0, 0])
feedkeys("ggVj" .. g:mapleader .. "tx\<Esc>", 'xt')
assert_equal("one\ntwo", get(g:, 'vimrc_sent_lines', ''), 'first live Visual selection')
feedkeys("4GVj" .. g:mapleader .. "tx\<Esc>", 'xt')
assert_equal("four\nfive", g:vimrc_sent_lines, 'new selection must replace old marks')
feedkeys("6GV2k" .. g:mapleader .. "tx\<Esc>", 'xt')
assert_equal("four\nfive\nsix", g:vimrc_sent_lines, 'reverse selection sends ascending lines')
feedkeys("3Gvl" .. g:mapleader .. "tx\<Esc>", 'xt')
assert_equal('three', g:vimrc_sent_lines, 'character selection sends its covered lines')

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
