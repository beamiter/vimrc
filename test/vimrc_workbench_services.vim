vim9script

set nomore
const TMP = tempname()
mkdir(TMP .. '/autoload', 'p')
writefile(['line one', 'line two'], TMP .. '/notes.txt')
execute 'edit ' .. fnameescape(TMP .. '/notes.txt')
setlocal filetype=

def Act(action: string): string
  try
    g:VimrcWorkbenchAction(action)
  catch
    return v:exception
  endtry
  return ''
enddef

def Called(name: string)
  g:vimrc_service_called = name
enddef

def Has(action: string): bool
  return index(g:VimrcWorkbenchCapabilities(), action) >= 0
enddef

var snapshot = g:VimrcWorkbenchState()
assert_false(snapshot.plugins.available)
assert_false(snapshot.plugins.known)
assert_false(snapshot.lsp.available)
assert_false(snapshot.tree.available)
assert_false(snapshot.statusline.available)

const SERVICES = {
  simple_plugin_status: 'PlugStatus', simple_plugin_check: 'PlugCheck',
  simple_plugin_install: 'PlugInstall', simple_plugin_update: 'PlugUpdate',
  simple_plugin_stop: 'PlugStop', simple_plugin_diff: 'PlugDiff',
  simple_plugin_profile: 'PlugProfile', simple_plugin_health: 'PlugHealth',
  simple_lsp_status: 'SimpleCC', simple_lsp_restart: 'SimpleCCRestart',
  simple_lsp_log: 'SimpleCCLog', simple_tree_refresh: 'SimpleTreeRefresh',
  simple_statusline_health: 'SimpleLineHealth',
  simple_git_next_hunk: 'SimpleGitHunkNext', simple_git_previous_hunk: 'SimpleGitHunkPrev',
  simple_git_stage_hunk: 'SimpleGitHunkStage', simple_git_undo_hunk: 'SimpleGitHunkUndo',
  simple_git_blame: 'SimpleGitBlame', simple_git_blame_line: 'SimpleGitBlameLine',
  simple_git_history: 'SimpleGitHistory',
}
for [id, command] in items(SERVICES)
  execute 'command! ' .. command .. ' call Called(' .. string(id) .. ')'
endfor
command! SimpleTree call Called('tree')
command! SimpleLineToggle g:vimrc_service_line_enabled = !g:vimrc_service_line_enabled

# Even with a discoverable runtime provider, a read must not autoload it.
writefile(['vim9script', 'g:vimrc_service_plug_loaded = true',
  'export def WorkbenchState(): any',
  "  if get(g:, 'vimrc_service_provider_throws', false)",
  "    throw 'fixture provider failure'", '  endif',
  "  return get(g:, 'vimrc_service_plug', {})", 'enddef'], TMP .. '/autoload/simpleplug.vim')
execute 'set runtimepath^=' .. fnameescape(TMP)
snapshot = g:VimrcWorkbenchState()
assert_true(snapshot.plugins.available)
assert_false(snapshot.plugins.known)
assert_false(exists('g:vimrc_service_plug_loaded'), 'snapshot autoloaded SimplePlug')
assert_false(Has('simple_plugin_stop'), 'unknown state must not advertise Stop')
assert_equal('', Act('simple_plugin_status'), 'older managers keep their own concurrency guard')
execute 'source ' .. fnameescape(TMP .. '/autoload/simpleplug.vim')
g:vimrc_service_plug = {known: true, running: false}
assert_false(Has('simple_plugin_stop'))
g:vimrc_service_plug = {known: true, running: true, operation: "update\nfixture",
  total: 9, completed: 4, installed: -3, updated: 1000001, errors: 'invalid'}
snapshot = g:VimrcWorkbenchState()
assert_equal({available: true, known: true, running: true, operation: 'update fixture',
  total: 9, completed: 4, installed: 0, updated: 1000000, errors: 0}, snapshot.plugins)
snapshot.plugins.running = false
assert_true(g:vimrc_service_plug.running, 'returned state aliases the provider cache')
assert_true(Has('simple_plugin_stop'))
for action in ['status', 'check', 'install', 'update', 'diff']
  assert_false(Has('simple_plugin_' .. action), 'busy manager still advertises ' .. action)
  assert_match('unavailable', Act('simple_plugin_' .. action))
endfor
assert_equal('', Act('simple_plugin_stop'))
assert_equal('simple_plugin_stop', g:vimrc_service_called)
g:vimrc_service_plug.running = false
for action in ['status', 'check', 'install', 'update', 'diff', 'profile', 'health']
  assert_equal('', Act('simple_plugin_' .. action))
  assert_equal('simple_plugin_' .. action, g:vimrc_service_called)
endfor
g:vimrc_service_provider_throws = true
assert_false(g:VimrcWorkbenchState().plugins.known)
g:vimrc_service_provider_throws = false

# LSP state is the actual service cache, never a claim inferred from command
# existence. Empty status remains distinguishable from a running server.
assert_equal({available: true, status: ''}, g:VimrcWorkbenchState().lsp)
g:simplecc_status = "clangd\nindexing\e"
assert_equal('clangd indexing ', g:VimrcWorkbenchState().lsp.status)
for action in ['simple_lsp_status', 'simple_lsp_restart', 'simple_lsp_log']
  assert_equal('', Act(action))
  assert_equal(action, g:vimrc_service_called)
endfor

writefile(['vim9script', 'export def IsEnabled(): bool',
  '  return g:vimrc_service_line_enabled', 'enddef'], TMP .. '/autoload/simpleline.vim')
execute 'source ' .. fnameescape(TMP .. '/autoload/simpleline.vim')
g:vimrc_service_line_enabled = true
g:vimrc_service_change_events = 0
autocmd User VimrcWorkbenchChanged g:vimrc_service_change_events += 1
assert_true(g:VimrcWorkbenchState().statusline.enabled)
assert_equal('', Act('simple_statusline_toggle'))
assert_false(g:VimrcWorkbenchState().statusline.enabled)
assert_equal(1, g:vimrc_service_change_events)
assert_equal('', Act('simple_statusline_health'))
assert_equal('simple_statusline_health', g:vimrc_service_called)

# Refresh belongs to the tree in this tab, including while focus remains in
# the source editor; a tree in another tab is not the current explorer.
writefile(['vim9script', 'export def GetRoot(): string',
  '  return "/cached/tree-root"', 'enddef'], TMP .. '/autoload/simpletree.vim')
execute 'source ' .. fnameescape(TMP .. '/autoload/simpletree.vim')
assert_false(Has('simple_tree_refresh'))
var source = win_getid()
new
setlocal buftype=nofile bufhidden=wipe filetype=simpletree
var tree = win_getid()
win_gotoid(source)
assert_equal({available: true, visible: true, root: '/cached/tree-root'}, g:VimrcWorkbenchState().tree)
assert_equal('', Act('simple_tree_refresh'))
assert_equal('simple_tree_refresh', g:vimrc_service_called)
tabnew
assert_false(Has('simple_tree_refresh'), 'tree in another tab leaked into current actions')
tabclose
win_gotoid(tree)
close
assert_false(Has('simple_tree_refresh'))

# Hunk mutations must not depend on filetype, yet must never target unsaved,
# protected or readonly text. Missing cached hunks are not a clean assertion.
assert_equal('', &filetype)
assert_false(Has('simple_git_stage_hunk'))
b:simplegit_status_dict = {added: 1, changed: 0, removed: 0}
for action in ['simple_git_next_hunk', 'simple_git_previous_hunk', 'simple_git_stage_hunk',
    'simple_git_blame', 'simple_git_blame_line', 'simple_git_history']
  assert_equal('', Act(action))
  assert_equal(action, g:vimrc_service_called)
endfor
setlocal readonly
assert_false(Has('simple_git_stage_hunk'))
assert_false(Has('simple_git_undo_hunk'))
assert_true(Has('simple_git_next_hunk'))
setlocal noreadonly
setline(1, 'unsaved change')
for action in ['simple_git_next_hunk', 'simple_git_previous_hunk', 'simple_git_stage_hunk', 'simple_git_undo_hunk']
  assert_false(Has(action), 'unsaved buffer advertised ' .. action)
  assert_match('unavailable', Act(action))
endfor
setlocal nomodified
b:vimrc_large_file = true
assert_false(Has('simple_git_stage_hunk'))
b:vimrc_large_file = false
setlocal nomodifiable
assert_false(Has('simple_git_stage_hunk'))
setlocal modifiable

assert_equal('<Cmd>VimrcAction simple_plugin_check<CR>', maparg(g:mapleader .. 'Pc', 'n'))
assert_equal('<Cmd>VimrcAction simple_plugin_update<CR>', maparg(g:mapleader .. 'Pu', 'n'))
assert_equal('<Cmd>VimrcAction simple_statusline_toggle<CR>', maparg(g:mapleader .. 'vL', 'n'))

delete(TMP, 'rf')
if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
