vim9script

set nomore

const ROOT = g:vimrc_root
const PROJECT = tempname()
mkdir(PROJECT .. '/src', 'p')
mkdir(PROJECT .. '/.git', 'p')
writefile(['let alpha = 1', '中文 é 🧑‍💻'], PROJECT .. '/src/example.vim')

def Run(command: string): string
  try
    execute command
  catch
    return v:exception
  endtry
  return ''
enddef

def Act(action: string): string
  try
    g:VimrcWorkbenchAction(action)
  catch
    return v:exception
  endtry
  return ''
enddef

def Called(name: string)
  g:vimrc_workbench_called = name
enddef

assert_equal(2, exists(':VimrcWorkbench'))
assert_equal(2, exists(':VimrcAction'))
assert_equal('<Cmd>VimrcWorkbench<CR>', maparg(g:mapleader .. 'vw', 'n'))
assert_equal(':VimrcAction ', maparg(g:mapleader .. 'va', 'n'))
assert_equal(['simple_workbench'], g:VimrcWorkbenchCapabilities())
assert_match('unavailable', Act('simple_files'))

# Loading an old native bridge or inheriting its startup environment does
# not claim that a GUI session has authenticated.
$JTERM_VIM9_ADDR = '127.0.0.1:43210'
$JTERM_VIM9_TOKEN = 'test-only-token'
g:jterm_vim9_bridge_loaded = true
assert_false(g:VimrcWorkbenchState().native)
g:jterm_vim9_connected = true
doautocmd User JTermVim9Ready
assert_true(g:VimrcWorkbenchState().native)
g:jterm_vim9_connected = false
doautocmd User JTermVim9Disconnected
assert_false(g:VimrcWorkbenchState().native)
$JTERM_VIM9_ADDR = ''
$JTERM_VIM9_TOKEN = ''
unlet g:jterm_vim9_bridge_loaded

execute 'edit ' .. fnameescape(PROJECT .. '/src/example.vim')
setfiletype vim
var source_window = win_getid()
var source_buffer = bufnr()
assert_equal(PROJECT, g:VimrcWorkbenchState().root)

# Metadata must stay cheap and side-effect free between lifecycle events.
# A new marker is deliberately invisible until the next workspace refresh.
mkdir(PROJECT .. '/src/.git', 'p')
assert_equal(PROJECT, g:VimrcWorkbenchState().root)
doautocmd BufEnter
assert_equal(PROJECT .. '/src', g:VimrcWorkbenchState().root)

b:simplegit_status_dict = {head: "feature/中文\nnext", ahead: 2, behind: -7,
  added: 4, changed: 8, removed: 1000001}
b:simplecc_diag_counts = {error: 2, warning: 1, info: -3, hint: 'invalid'}
var view = winsaveview()
var before_text = getline(1, '$')
var before_modified = &modified
var before_qf = getqflist({id: 0, changedtick: 0})
var snapshot = g:VimrcWorkbenchState()
assert_equal('simple', snapshot.provider)
assert_equal({head: 'feature/中文 next', ahead: 2, behind: 0,
  added: 4, changed: 8, removed: 1000000}, snapshot.git)
assert_equal({error: 2, warning: 1, info: 0, hint: 0}, snapshot.diagnostics)
snapshot.git.head = 'mutated-copy'
assert_equal("feature/中文\nnext", b:simplegit_status_dict.head)
assert_equal(before_text, getline(1, '$'))
assert_equal(before_modified, &modified)
assert_equal(before_qf, getqflist({id: 0, changedtick: 0}))
assert_equal(view, winsaveview())

# Connections and counts are read from existing plugin caches, without
# importing a plugin or touching quickfix just to obtain its diagnostics.
g:simpleremote_workspace = {kind: 'ssh', target: 'dev-host', root: '/srv/project'}
g:simpleremote_status = 'connecting ssh:dev-host'
assert_false(g:VimrcWorkbenchState().remote.connected)
g:simpleremote_status = 'ssh:dev-host'
assert_equal({connected: true, label: 'ssh:dev-host', root: '/srv/project'},
  g:VimrcWorkbenchState().remote)
g:simpleremote_status = 'disconnected'
assert_equal({connected: false, label: '', root: ''}, g:VimrcWorkbenchState().remote)
unlet g:simpleremote_workspace g:simpleremote_status

# Provider installation can happen after VimEnter. The same catalog drives
# capabilities, completion and execution, and execution rechecks live state.
command! SimpleFinderFiles call Called('files')
command! SimpleFinderBuffers call Called('buffers')
command! SimpleFinderIGrep call Called('grep')
command! SimpleCCDefinition call Called('definition')
command! SimpleCCHover call Called('hover')
command! SimpleCCReferences call Called('references')
command! SimpleCCFormat call Called('format')
command! SimpleCCRename call Called('rename-prompt')
command! SimpleCCAction call Called('code-action')
command! SimpleCCDiagnostics call Called('diagnostics')
command! SimpleCCNextDiag call Called('next-diagnostic')
command! SimpleCCPrevDiag call Called('previous-diagnostic')
command! SimpleCCOutline call Called('outline')
command! SimpleGitStatus call Called('git-status')
command! SimpleGitDiff call Called('git-diff')
command! SimpleGitHunkPreview call Called('git-hunk')
command! SimpleMarkdown call Called('markdown')
command! SimpleWhichKey call Called('keys')

var capabilities = g:VimrcWorkbenchCapabilities()
assert_equal(18, len(capabilities), 'Markdown preview is hidden outside Markdown')
assert_equal(-1, index(capabilities, 'rename'), 'typed rename must not become a prompt')
assert_true(index(capabilities, 'simple_rename') >= 0)
assert_equal(['simple_git_status', 'simple_git_diff', 'simple_git_hunk'],
  getcompletion('VimrcAction simple_git_', 'cmdline'))
assert_equal('', Run('VimrcAction simple_files'))
assert_equal('files', g:vimrc_workbench_called)
assert_equal('', Act('definition'))
assert_equal('definition', g:vimrc_workbench_called)
assert_equal({items: [], total: 0}, g:VimrcWorkbenchDiagnostics())
assert_equal('', Act('simple_diagnostics'))
assert_equal('diagnostics', g:vimrc_workbench_called)
assert_equal('', Act('simple_next_diagnostic'))
assert_equal('next-diagnostic', g:vimrc_workbench_called)
assert_equal('', Act('simple_previous_diagnostic'))
assert_equal('previous-diagnostic', g:vimrc_workbench_called)
assert_equal('', Act('simple_rename'))
assert_equal('rename-prompt', g:vimrc_workbench_called)
assert_match('Unknown', Act("simple_files | let g:workbench_injected = 1"))
assert_match('Unknown', Act("simple_files\nqall!"))
assert_false(exists('g:workbench_injected'))

setlocal readonly
assert_match('unavailable', Act('format'))
assert_true(index(g:VimrcWorkbenchCapabilities(), 'hover') >= 0)
setlocal noreadonly
b:vimrc_large_file = 1
assert_match('unavailable', Act('hover'))
assert_true(index(g:VimrcWorkbenchCapabilities(), 'simple_files') >= 0)
assert_true(g:VimrcWorkbenchState().large_file)
b:vimrc_large_file = 0
setlocal filetype=markdown
assert_true(index(g:VimrcWorkbenchCapabilities(), 'simple_markdown_preview') >= 0)
assert_equal('', Act('simple_markdown_preview'))
assert_equal('markdown', g:vimrc_workbench_called)

# User opt-outs are authoritative, including Boolean values and re-source.
g:simplewhichkey_enable = false
assert_match('unavailable', Act('simple_keys'))
g:vimrc_workbench_disabled_actions = ['simple_grep', 'definition']
assert_match('unavailable', Act('simple_grep'))
assert_match('unavailable', Act('definition'))
g:vimrc_workbench_enable = false
assert_equal([], g:VimrcWorkbenchCapabilities())
assert_equal({}, g:VimrcWorkbenchState())
assert_match('unavailable', Act('simple_files'))
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
assert_false(g:vimrc_workbench_enable)
assert_false(g:simplewhichkey_enable)
assert_equal(['simple_grep', 'definition'], g:vimrc_workbench_disabled_actions)
assert_equal([], g:VimrcWorkbenchCapabilities())
g:vimrc_workbench_enable = true
doautocmd BufEnter
assert_equal(PROJECT .. '/src', g:VimrcWorkbenchState().root)
assert_match('unavailable', Act('simple_grep'))
assert_true(index(g:VimrcWorkbenchCapabilities(), 'simple_files') >= 0)

# Context follows the active split instead of leaking another buffer's Git
# or diagnostic summary. Repeated sourcing leaves exactly one event owner.
split
enew
assert_equal('', g:VimrcWorkbenchState().git.head)
assert_equal(0, g:VimrcWorkbenchState().diagnostics.error)
close
assert_equal(source_window, win_getid())
assert_equal(source_buffer, bufnr())
var autocommands = execute('autocmd vimrc_workbench')
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal(autocommands, execute('autocmd vimrc_workbench'))

# The inspectable fallback works in ordinary Vim with plugins absent. Opening
# it twice reuses its owned scratch window and preserves unsaved source text.
setline(1, 'unsaved work')
var source_text = getline(1, '$')
setreg('"', 'untouched-register')
var windows_before = winnr('$')
assert_equal('', Run('VimrcWorkbench'))
assert_equal(windows_before + 1, winnr('$'))
assert_true(get(b:, 'vimrc_workbench_report', false))
assert_equal('nofile', &buftype)
assert_false(&modifiable)
assert_false(&modified)
assert_false(&swapfile)
assert_false(&buflisted)
assert_match('ordinary Vim / bridge disconnected', join(getline(1, '$'), "\n"))
assert_match('feature/中文 next', join(getline(1, '$'), "\n"))
assert_equal('', Run('VimrcWorkbench'))
assert_equal(windows_before + 1, winnr('$'))
close
assert_equal(source_window, win_getid())
assert_equal(source_text, getline(1, '$'))
assert_true(&modified)
assert_equal('untouched-register', getreg('"'))

delete(PROJECT, 'rf')
if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
