vim9script

# The host sees a small, named action vocabulary. The command strings live
# here, never in a host request, a project file or a palette search query.
const ACTIONS = [
  {id: 'simple_files', command: 'SimpleFinderFiles', title: 'Find project files', scope: 'any'},
  {id: 'simple_recent', command: 'SimpleFinderRecent', title: 'Find recent files', scope: 'any'},
  {id: 'simple_tree_toggle', command: 'SimpleRemoteTree', fallback: 'SimpleTree', title: 'Toggle project tree', scope: 'any'},
  {id: 'simple_tree_reveal', command: 'SimpleRemoteTreeReveal', fallback: 'SimpleTreeReveal', title: 'Reveal current file in tree', scope: 'file'},
  {id: 'simple_tree_refresh', command: 'SimpleTreeRefresh', title: 'Refresh the open project tree', scope: 'tree'},
  {id: 'simple_terminal_toggle', command: 'SimpleTerminalToggle', title: 'Toggle terminal', scope: 'any'},
  {id: 'simple_terminal_new', command: 'SimpleTerminalNew', title: 'New terminal', scope: 'any'},
  {id: 'simple_terminal_next', command: 'SimpleTerminalNext', title: 'Next terminal', scope: 'any'},
  {id: 'simple_terminal_previous', command: 'SimpleTerminalPrev', title: 'Previous terminal', scope: 'any'},
  {id: 'simple_buffers', command: 'SimpleFinderBuffers', title: 'Find open buffers', scope: 'any'},
  {id: 'simple_grep', command: 'SimpleFinderIGrep', title: 'Search project text', scope: 'any'},
  {id: 'simple_diagnostics', command: 'SimpleCCDiagnostics', title: 'Show buffer diagnostics', scope: 'code'},
  {id: 'simple_next_diagnostic', command: 'SimpleCCNextDiag', title: 'Go to next diagnostic', scope: 'code'},
  {id: 'simple_previous_diagnostic', command: 'SimpleCCPrevDiag', title: 'Go to previous diagnostic', scope: 'code'},
  {id: 'simple_implementation', command: 'SimpleCCImplementation', title: 'Go to implementation', scope: 'code'},
  {id: 'simple_type_definition', command: 'SimpleCCTypeDef', title: 'Go to type definition', scope: 'code'},
  {id: 'simple_workspace_symbols', command: 'SimpleCCWorkspaceSymbolLive', title: 'Search workspace symbols', scope: 'code'},
  {id: 'simple_incoming_calls', command: 'SimpleCCIncomingCalls', title: 'Show incoming calls', scope: 'code'},
  {id: 'simple_outgoing_calls', command: 'SimpleCCOutgoingCalls', title: 'Show outgoing calls', scope: 'code'},
  {id: 'simple_supertypes', command: 'SimpleCCSupertypes', title: 'Show supertypes', scope: 'code'},
  {id: 'simple_subtypes', command: 'SimpleCCSubtypes', title: 'Show subtypes', scope: 'code'},
  {id: 'simple_signature_help', command: 'SimpleCCSignatureHelp', title: 'Show signature help', scope: 'code'},
  {id: 'simple_doc_pin', command: 'SimpleCCDocPin', title: 'Pin documentation in a split', scope: 'code'},
  {id: 'simple_outline', command: 'SimpleCCOutline', title: 'Show document symbols', scope: 'code'},
  {id: 'simple_code_lens', command: 'SimpleCCCodeLens', title: 'Refresh CodeLens annotations', scope: 'code'},
  {id: 'simple_code_lens_run', command: 'SimpleCCCodeLensRun', title: 'Run a CodeLens command', scope: 'write'},
  {id: 'simple_inlay_hints', command: 'SimpleCCInlayHints', title: 'Toggle inline type and parameter hints', scope: 'code'},
  {id: 'simple_rename', command: 'SimpleCCRename', title: 'Rename symbol (Vim prompt)', scope: 'write'},
  {id: 'simple_code_action', command: 'SimpleCCAction', title: 'Choose code action', scope: 'write'},
  {id: 'simple_lsp_status', command: 'SimpleCC', title: 'Inspect language server status', scope: 'any'},
  {id: 'simple_lsp_restart', command: 'SimpleCCRestart', title: 'Restart language servers', scope: 'any'},
  {id: 'simple_lsp_log', command: 'SimpleCCLog', title: 'Open language server log', scope: 'any'},
  {id: 'simple_git_status', command: 'SimpleGitStatus', title: 'Show Git status', scope: 'any'},
  {id: 'simple_git_diff', command: 'SimpleGitDiff', title: 'Compare file with Git HEAD', scope: 'file'},
  {id: 'simple_git_hunk', command: 'SimpleGitHunkPreview', title: 'Preview current Git hunk', scope: 'file'},
  {id: 'simple_git_next_hunk', command: 'SimpleGitHunkNext', title: 'Go to next Git hunk', scope: 'hunk'},
  {id: 'simple_git_previous_hunk', command: 'SimpleGitHunkPrev', title: 'Go to previous Git hunk', scope: 'hunk'},
  {id: 'simple_git_stage_hunk', command: 'SimpleGitHunkStage', title: 'Stage current saved Git hunk', scope: 'hunk-write'},
  {id: 'simple_git_undo_hunk', command: 'SimpleGitHunkUndo', title: 'Discard current saved Git hunk (confirmation)', scope: 'hunk-write'},
  {id: 'simple_git_blame', command: 'SimpleGitBlame', title: 'Toggle Git blame sidebar', scope: 'file'},
  {id: 'simple_git_blame_line', command: 'SimpleGitBlameLine', title: 'Show Git blame for this line', scope: 'file'},
  {id: 'simple_git_history', command: 'SimpleGitHistory', title: 'Browse current file history', scope: 'file'},
  {id: 'simple_plugin_status', command: 'PlugStatus', title: 'Inspect plugin status', scope: 'plugin-idle'},
  {id: 'simple_plugin_check', command: 'PlugCheck', title: 'Check for plugin updates', scope: 'plugin-idle'},
  {id: 'simple_plugin_install', command: 'PlugInstall', title: 'Install missing plugins', scope: 'plugin-idle'},
  {id: 'simple_plugin_update', command: 'PlugUpdate', title: 'Update plugins', scope: 'plugin-idle'},
  {id: 'simple_plugin_stop', command: 'PlugStop', title: 'Stop the running plugin operation', scope: 'plugin-running'},
  {id: 'simple_plugin_diff', command: 'PlugDiff', title: 'Review plugin update changes', scope: 'plugin-idle'},
  {id: 'simple_plugin_profile', command: 'PlugProfile', title: 'Inspect plugin startup timings', scope: 'any'},
  {id: 'simple_plugin_health', command: 'PlugHealth', title: 'Inspect plugin manager health', scope: 'any'},
  {id: 'simple_statusline_toggle', command: 'SimpleLineToggle', title: 'Toggle SimpleLine status and buffer bars', scope: 'any'},
  {id: 'simple_statusline_health', command: 'SimpleLineHealth', title: 'Inspect SimpleLine statusbar health', scope: 'any'},
  {id: 'simple_markdown_preview', command: 'SimpleMarkdown', title: 'Toggle Markdown preview', scope: 'markdown'},
  {id: 'simple_keys', command: 'SimpleWhichKey', title: 'Explore your key bindings', scope: 'keys'},
  {id: 'simple_workbench', command: 'VimrcWorkbench', title: 'Inspect workbench integration', scope: 'any'},
  {id: 'definition', command: 'SimpleCCDefinition', title: 'Go to definition', scope: 'code'},
  {id: 'hover', command: 'SimpleCCHover', title: 'Show symbol documentation', scope: 'code'},
  {id: 'references', command: 'SimpleCCReferences', title: 'Find symbol references', scope: 'code'},
  {id: 'format', command: 'SimpleCCFormat', title: 'Format current buffer', scope: 'write'},
]

var roots: dict<string> = {}

def Flag(name: string, fallback: bool = true): bool
  var value = get(g:, name, fallback)
  if type(value) == v:t_bool
    return value
  endif
  return type(value) == v:t_number ? value != 0 : fallback
enddef

def BoundedString(value: any, limit: number): string
  if type(value) != v:t_string
    return ''
  endif
  # Metadata is plain text. Strip terminal/control bytes before it reaches a
  # GUI label or a scratch report; preserve Unicode and ordinary punctuation.
  return substitute(strcharpart(value, 0, limit), '[[:cntrl:]]', ' ', 'g')
enddef

def Count(value: any): number
  return type(value) == v:t_number ? min([1000000, max([0, value])]) : 0
enddef

def Dictionary(value: any): dict<any>
  return type(value) == v:t_dict ? value : {}
enddef

def Boolean(value: any): bool
  return type(value) == v:t_bool ? value : type(value) == v:t_number && value != 0
enddef

# Optional providers expose cached data; checking for an already defined
# function is essential here. Reading a GUI snapshot must never autoload a
# plugin, start a daemon, inspect checkouts, or create a progress window.
def CachedProvider(name: string, fallback: any): any
  if !exists('*' .. name)
    return fallback
  endif
  try
    return call(name, [])
  catch
    return fallback
  endtry
enddef

def PluginState(): dict<any>
  var cached = Dictionary(CachedProvider('simpleplug#WorkbenchState', {}))
  var known = Boolean(get(cached, 'known', false))
  return {
    available: exists(':PlugStatus') == 2,
    known: known,
    running: known && Boolean(get(cached, 'running', false)),
    operation: known ? BoundedString(get(cached, 'operation', ''), 32) : '',
    total: known ? Count(get(cached, 'total', 0)) : 0,
    completed: known ? Count(get(cached, 'completed', 0)) : 0,
    installed: known ? Count(get(cached, 'installed', 0)) : 0,
    updated: known ? Count(get(cached, 'updated', 0)) : 0,
    errors: known ? Count(get(cached, 'errors', 0)) : 0,
  }
enddef

def TreeVisible(): bool
  for info in getwininfo()
    if info.tabnr == tabpagenr() && getbufvar(info.bufnr, '&filetype') ==# 'simpletree'
      return true
    endif
  endfor
  return false
enddef

def CachedHunks(): bool
  var git = Dictionary(get(b:, 'simplegit_status_dict', {}))
  return Count(get(git, 'added', 0)) + Count(get(git, 'changed', 0))
    + Count(get(git, 'removed', 0)) > 0
enddef

def FileBuffer(): bool
  return (&buftype ==# '' || &buftype ==# 'acwrite')
        && &filetype !~# '^\%(startify\|simple\|vimrcreport\)'
enddef

# Match SimpleMarkdown's supported filetypes without loading a plugin or
# starting its daemon while a host reads the action catalog. An explicit
# list (including []) replaces defaults, just as the provider's Setting().
def MarkdownBuffer(): bool
  if !FileBuffer()
    return false
  endif
  const defaults = ['markdown', 'markdown.pandoc', 'pandoc', 'rmd', 'vimwiki', 'ghmarkdown']
  var configured: any = get(g:, 'simplemarkdown_filetypes', defaults)
  var filetypes = type(configured) == v:t_list
    ? filter(copy(configured), (_, item) => type(item) == v:t_string) : defaults
  return index(filetypes, &filetype) >= 0
    || (&filetype ==# '' && bufname() =~? '\.\(md\|markdown\|mdown\|mkd\|mkdn\|rmd\|qmd\)$')
enddef

def Disabled(action: string): bool
  var disabled = get(g:, 'vimrc_workbench_disabled_actions', [])
  return type(disabled) == v:t_list && index(disabled, action) >= 0
enddef

# Resolve only the fixed commands from this catalog; prefer the remote-aware
# wrapper when installed, which also handles ordinary local workspaces.
def ActionCommand(entry: dict<string>): string
  var fallback = get(entry, 'fallback', '')
  var fallback_available = !empty(fallback) && exists(':' .. fallback) == 2
  if exists(':' .. entry.command) != 2
    return fallback_available ? fallback : ''
  endif
  if empty(fallback) || fallback_available
    return entry.command
  endif
  # A remote wrapper alone cannot service ordinary local buffers. Read only
  # its already-published connection state; never autoload or probe a host.
  var workspace = Dictionary(get(g:, 'simpleremote_workspace', {}))
  var status = get(g:, 'simpleremote_status', 'disconnected')
  var ready = !empty(workspace) && type(status) == v:t_string
    && !empty(status) && status !=# 'disconnected' && status !~# '^connecting '
  if !ready
    return ''
  endif
  if entry.id ==# 'simple_tree_toggle'
    return empty(get(workspace, 'local_root', '')) ? entry.command : ''
  endif
  var remote = Dictionary(get(b:, 'vimrc_remote', {}))
  var path = get(remote, 'path', '')
  return entry.id ==# 'simple_tree_reveal' && bufname() =~# '^remote://'
    && type(path) == v:t_string && !empty(path) ? entry.command : ''
enddef

def Available(entry: dict<string>): bool
  if !Flag('vimrc_workbench_enable') || Disabled(entry.id)
        || empty(ActionCommand(entry))
    return false
  endif
  if entry.scope ==# 'keys'
    return Flag('simplewhichkey_enable')
  elseif entry.scope ==# 'file'
    return FileBuffer() && !empty(bufname())
  elseif entry.scope ==# 'tree'
    return TreeVisible()
  elseif entry.scope ==# 'hunk' || entry.scope ==# 'hunk-write'
    # SimpleGit's hunks describe the saved file. Never offer an operation
    # against an unsaved buffer or a cache from a different editor split.
    return FileBuffer() && !empty(bufname()) && !&modified
      && !get(b:, 'vimrc_large_file', 0) && CachedHunks()
      && (entry.scope !=# 'hunk-write' || (&modifiable && !&readonly))
  elseif entry.scope ==# 'plugin-running'
    var manager = PluginState()
    return manager.known && manager.running
  elseif entry.scope ==# 'plugin-idle'
    var manager = PluginState()
    # Older managers still perform their own concurrency guard. Their state
    # remains explicitly unknown instead of advertising an invented result.
    return !manager.known || !manager.running
  elseif entry.scope ==# 'markdown'
    return MarkdownBuffer()
  elseif entry.scope ==# 'code' || entry.scope ==# 'write'
    return FileBuffer() && !empty(&filetype)
          && !get(b:, 'vimrc_large_file', 0)
          && (entry.scope !=# 'write' || (&modifiable && !&readonly))
  endif
  return true
enddef

# Reading a snapshot never probes the filesystem or starts a plugin daemon.
# Project discovery is refreshed only at workspace/window lifecycle events.
def RefreshRoot()
  if !Flag('vimrc_workbench_enable')
    return
  endif
  var key = string(win_getid())
  if FileBuffer() || !has_key(roots, key)
    roots[key] = BoundedString(g:VimrcProjectRoot(), 4096)
  endif
enddef

def ForgetWindow(window: string)
  if has_key(roots, window)
    remove(roots, window)
  endif
enddef

def CaptureState(): dict<any>
  var git = Dictionary(get(b:, 'simplegit_status_dict', {}))
  var diagnostics = Dictionary(get(b:, 'simplecc_diag_counts', {}))
  var workspace = Dictionary(get(g:, 'simpleremote_workspace', {}))
  var remote_status = get(g:, 'simpleremote_status', 'disconnected')
  var connected = !empty(workspace) && type(remote_status) == v:t_string
        && remote_status !=# 'disconnected' && remote_status !~# '^connecting '
  var kind = BoundedString(get(workspace, 'kind', ''), 32)
  var target = BoundedString(get(workspace, 'target', ''), 224)
  return {
    provider: 'simple',
    root: get(roots, string(win_getid()), ''),
    native: Flag('jterm_vim9_connected', false),
    large_file: !!get(b:, 'vimrc_large_file', 0),
    git: {
      head: BoundedString(get(git, 'head', ''), 128),
      ahead: Count(get(git, 'ahead', 0)), behind: Count(get(git, 'behind', 0)),
      added: Count(get(git, 'added', 0)), changed: Count(get(git, 'changed', 0)),
      removed: Count(get(git, 'removed', 0)),
    },
    diagnostics: {
      error: Count(get(diagnostics, 'error', 0)),
      warning: Count(get(diagnostics, 'warning', 0)),
      info: Count(get(diagnostics, 'info', 0)),
      hint: Count(get(diagnostics, 'hint', 0)),
    },
    remote: {
      connected: connected,
      label: connected ? kind .. ':' .. target : '',
      root: connected ? BoundedString(get(workspace, 'root', ''), 4096) : '',
    },
    lsp: {
      available: exists(':SimpleCC') == 2,
      status: BoundedString(get(g:, 'simplecc_status', ''), 256),
    },
    plugins: PluginState(),
    tree: {
      available: exists(':SimpleTree') == 2 || exists(':SimpleRemoteTree') == 2,
      visible: TreeVisible(),
      root: BoundedString(CachedProvider('simpletree#GetRoot', ''), 4096),
    },
    statusline: {
      available: exists(':SimpleLineToggle') == 2,
      enabled: Boolean(CachedProvider('simpleline#IsEnabled', false)),
    },
  }
enddef

# These hooks are the optional jterm_core contract. They also work in
# ordinary Vim; an inherited JTERM_VIM9_ADDR alone never claims a connection.
def g:VimrcWorkbenchCapabilities(): list<string>
  return copy(ACTIONS)->filter((_, entry) => Available(entry))
        ->mapnew((_, entry) => entry.id)
enddef

def g:VimrcWorkbenchState(): dict<any>
  return Flag('vimrc_workbench_enable') ? CaptureState() : {}
enddef

# exists() deliberately avoids autoloading or starting a provider on read.
def g:VimrcWorkbenchDiagnostics(): dict<any>
  if !Flag('vimrc_workbench_enable') || !FileBuffer()
        || !exists('*simplecc#DiagnosticSnapshot')
    return {items: [], total: 0}
  endif
  try
    var snapshot: any = call('simplecc#DiagnosticSnapshot', [bufnr()])
    return type(snapshot) == v:t_dict ? snapshot : {items: [], total: 0}
  catch
    return {items: [], total: 0}
  endtry
enddef

def g:VimrcWorkbenchAction(action: string)
  for entry in ACTIONS
    if entry.id ==# action
      if !Available(entry)
        throw '[vimrc] Workbench action is unavailable in this buffer: ' .. action
      endif
      if action ==# 'simple_git_undo_hunk'
        var source = [bufnr(), win_getid(), b:changedtick, line('.'), col('.')]
        if confirm('[SimpleGit] Discard the saved Git hunk at the cursor?', "&Cancel\n&Discard", 1) != 2
          return
        endif
        if source !=# [bufnr(), win_getid(), b:changedtick, line('.'), col('.')]
            || !Available(entry)
          throw '[vimrc] The source changed during confirmation; reopen the action menu'
        endif
      endif
      execute ActionCommand(entry)
      # In particular, a SimpleLine toggle has no provider event of its own.
      # Tell native hosts to refresh once; do not add a polling timer.
      if exists('#User#VimrcWorkbenchChanged')
        silent doautocmd <nomodeline> User VimrcWorkbenchChanged
      endif
      return
    endif
  endfor
  throw '[vimrc] Unknown workbench action: ' .. action
enddef

def CompleteAction(lead: string, _line: string, _position: number): list<string>
  return filter(g:VimrcWorkbenchCapabilities(), (_, action) => stridx(action, lead) == 0)
enddef

def g:VimrcWorkbenchReport()
  var source = get(b:, 'vimrc_workbench_source', 0)
  if source > 0 && win_id2win(source) > 0
    win_gotoid(source)
  endif
  RefreshRoot()
  var state = CaptureState()
  var render_protocol: any = get(g:, 'jterm_vim9_render_protocol', 0)
  var native_popups = state.native && type(render_protocol) == v:t_number && render_protocol >= 6
  var native_cards = state.native && Flag('jterm_vim9_popup_cards', false)
    && Flag('simplecc_popup_cards')
  # This is an explicit, authenticated capability. Older protocol-6 bridges
  # support popups but still fall back for every virtual text property.
  var native_after = state.native && Flag('jterm_vim9_virtual_text_after', false)
  var native_inline = state.native && Flag('jterm_vim9_virtual_text_inline', false)
  var capabilities = g:VimrcWorkbenchCapabilities()
  var origin = win_getid()
  var lines = [
    'Simple Workbench — q closes this report',
    '',
    'Integration: ' .. (Flag('vimrc_workbench_enable') ? 'enabled' : 'disabled'),
    'Editor: ' .. (state.native ? 'authenticated native Vim bridge' : 'ordinary Vim / bridge disconnected'),
    'Popups: ' .. (native_popups ? 'native text surfaces from opted-in plugins; complex popups use Vim compatibility'
      : 'Vim compatibility view'),
    'LSP cards: ' .. (native_cards ? 'native rounded documentation cards; Ctrl-F/Ctrl-B scroll, Space lq closes'
      : 'classic popup presentation'),
    'Virtual text: ' .. (native_after ? 'native after-line CodeLens and diagnostics'
      : 'Vim compatibility view'),
    'Inline hints: ' .. (native_inline ? 'native single-line hints in nowrap views; complex layouts use Vim compatibility'
      : 'Vim compatibility view'),
    'Workspace: ' .. state.root,
    'Buffer: ' .. BoundedString(bufname(), 4096),
    'Large file: ' .. (state.large_file ? 'protected' : 'no'),
    'Git: ' .. (empty(state.git.head) ? 'no cached branch' : state.git.head)
      .. printf('  +%d ~%d -%d  ahead %d / behind %d', state.git.added,
        state.git.changed, state.git.removed, state.git.ahead, state.git.behind),
    printf('Diagnostics: %d errors / %d warnings / %d info / %d hints',
      state.diagnostics.error, state.diagnostics.warning,
      state.diagnostics.info, state.diagnostics.hint),
    'Remote: ' .. (state.remote.connected ? state.remote.label .. '  ' .. state.remote.root : 'disconnected'),
    'SimpleCC: ' .. (!state.lsp.available ? 'unavailable'
      : empty(state.lsp.status) ? 'no server status published' : state.lsp.status),
    'SimplePlug: ' .. (!state.plugins.available ? 'unavailable'
      : !state.plugins.known ? 'state unknown — update SimplePlug for live progress'
      : empty(state.plugins.operation) ? 'ready; no operation in this session'
      : printf('%s%s  %d/%d completed  %d installed / %d updated / %d errors',
        state.plugins.operation, state.plugins.running ? ' running' : ' finished',
        state.plugins.completed, state.plugins.total, state.plugins.installed,
        state.plugins.updated, state.plugins.errors)),
    'SimpleTree: ' .. (!state.tree.available ? 'unavailable'
      : (state.tree.visible ? 'visible' : 'closed')
        .. (empty(state.tree.root) ? '' : '  ' .. state.tree.root)),
    'SimpleLine: ' .. (!state.statusline.available ? 'unavailable'
      : state.statusline.enabled ? 'enabled' : 'disabled'),
    '',
    'Available actions for the source buffer:',
    'Use :VimrcAction {id}; the native palette also finds these by name.',
    '',
  ]
  for entry in ACTIONS
    if index(capabilities, entry.id) >= 0
      add(lines, printf('  %-26s %s', entry.id, entry.title))
    endif
  endfor
  if empty(capabilities)
    add(lines, '  none — integration is disabled or no provider is available')
  endif
  extend(lines, ['', 'Counts read plugin caches; Git/diagnostic zero may mean the provider has not reported yet.',
    'SimplePlug counts belong to the current/last operation, not the installed plugin inventory.',
    'Space P: s status / c check / i install / u update / x stop / d diff / p profile / h health.',
    'Git stage/discard require a saved writable file and cached hunks; discard asks for confirmation.',
    'Existing Space leader bindings still call your simple* plugins directly.'])

  var report = -1
  for info in getbufinfo()
    if getbufvar(info.bufnr, 'vimrc_workbench_report', false)
      report = info.bufnr
      break
    endif
  endfor
  if report > 0 && !empty(win_findbuf(report))
    win_gotoid(win_findbuf(report)[0])
  elseif report > 0
    execute 'botright sbuffer ' .. report
  else
    botright new
    # Do not reuse a real file that happens to have the same display name.
    var names = getbufinfo()->mapnew((_, info) => info.name)
    var name = '[simple-workbench]'
    var suffix = 1
    while index(names, fnamemodify(name, ':p')) >= 0
      name = '[simple-workbench-' .. suffix .. ']'
      suffix += 1
    endwhile
    execute 'file ' .. fnameescape(name)
    b:vimrc_workbench_report = true
  endif
  b:vimrc_workbench_source = origin
  setlocal modifiable
  silent! :%delete _
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  setlocal filetype=vimrcreport nowrap nonumber norelativenumber nolist signcolumn=no
  setlocal foldmethod=manual nofoldenable
  setline(1, lines)
  setlocal nomodified nomodifiable
  nnoremap <buffer> <silent> q <Cmd>close<CR>
enddef

command! VimrcWorkbench call g:VimrcWorkbenchReport()
command! -nargs=1 -complete=customlist,CompleteAction VimrcAction
      \ call g:VimrcWorkbenchAction(<q-args>)

augroup vimrc_workbench
  autocmd!
  autocmd BufEnter,WinEnter,DirChanged * call RefreshRoot()
  autocmd WinClosed * call ForgetWindow(expand('<amatch>'))
  autocmd User SimpleRemoteConnected,SimpleRemoteWorkspaceChanged,SimpleRemoteTreeRootChanged,SimpleRemoteDisconnected
        \ call RefreshRoot()
  autocmd User JTermVim9Ready,JTermVim9Disconnected call RefreshRoot()
  autocmd User SimplePlugStateChanged,SimplePlugComplete,SimpleTreeOpen,SimpleTreeClose,SimpleTreeRootChanged
        \ silent doautocmd <nomodeline> User VimrcWorkbenchChanged
augroup END

RefreshRoot()
