vim9script

var C = g:vimrc_context

# ============================================================================
# Vim9 辅助函数
# ============================================================================
# 只有测试和键位依赖的入口保留为全局函数；其余为脚本局部，重新 source 时
# 由 Vim9 自动重定义。

# SimpleCC buffer 键位：同一张表负责按 filetype 安装，以及在 filetype 切换
# 后清理残留的 buffer-local 映射。
const SIMPLECC_NMAPS = [
  ['gd', '<Plug>(simplecc-definition)'],
  ['gr', '<Plug>(simplecc-references)'],
  ['K', '<Plug>(simplecc-hover)'],
  ['gi', '<Plug>(simplecc-implementation)'],
  ['gy', '<Plug>(simplecc-type-definition)'],
  ['[d', '<Plug>(simplecc-prev-diagnostic)'],
  [']d', '<Plug>(simplecc-next-diagnostic)'],
]
const SEMANTIC_NMAPS = [
  ['<F12>', '<Plug>(simplecc-definition)', 'SimpleCCDefinition'],
  ['<S-F12>', '<Plug>(simplecc-references)', 'SimpleCCReferences'],
  ['<leader>lq', '<Cmd>SimpleCCPopupClose<CR>', 'SimpleCCPopupClose'],
]
const SEMANTIC_POPUP_NMAPS = [
  ['<C-f>', 'simplecc#PopupScrollKey(1, "\<C-f>")', 'SimpleCCPopupScroll'],
  ['<C-b>', 'simplecc#PopupScrollKey(-1, "\<C-b>")', 'SimpleCCPopupScroll'],
]
const SEMANTIC_EDIT_NMAPS = [
  ['<F2>', '<Plug>(simplecc-rename)', 'SimpleCCRename'],
]
const SEMANTIC_IMAPS = [
  ['<C-g>s', '<Cmd>SimpleCCSignatureHelp<CR>', 'SimpleCCSignatureHelp'],
]
const SEMANTIC_XMAPS = [
  ['<leader>ca', '<Plug>(simplecc-code-action)', 'SimpleCCAction'],
  ['<leader>la', '<Plug>(simplecc-code-action)', 'SimpleCCAction'],
  ['<leader>cf', '<Plug>(simplecc-format)', 'SimpleCCFormat'],
  ['<leader>fm', '<Plug>(simplecc-format)', 'SimpleCCFormat'],
  ['<leader>lf', '<Plug>(simplecc-format)', 'SimpleCCFormat'],
]
const SIMPLECC_IMAPS = [
  ['<Tab>', '<Plug>(simplecc-select-tab)'],
  ['<S-Tab>', '<Plug>(simplecc-select-shift-tab)'],
  ['<Down>', '<Plug>(simplecc-select-down)'],
  ['<Up>', '<Plug>(simplecc-select-up)'],
]

# 配置了语言服务器的 filetype 才接管 gd/gr/gi/K 等原生动作。
const LSP_FILETYPES = [
  'rust',
  'c',
  'cpp',
  'objc',
  'objcpp',
  'python',
  'go',
  'gomod',
  'gowork',
  'typescript',
  'javascript',
  'typescriptreact',
  'javascriptreact',
  'lua',
  'julia',
]

# [filetypes, setlocal 参数]；未命中的 filetype 使用基线缩进。
const INDENT_RULES = [
  [['go', 'gomod', 'gowork'],
    ['noexpandtab', 'shiftwidth=4', 'softtabstop=0', 'tabstop=4']],
  [['c', 'cpp', 'javascript', 'javascriptreact', 'typescript',
    'typescriptreact', 'json', 'jsonc', 'yaml', 'lua', 'sh', 'bash',
    'zsh', 'haskell', 'vim'],
    ['shiftwidth=2', 'softtabstop=2', 'tabstop=2']],
  [['make'],
    ['noexpandtab', 'shiftwidth=8', 'softtabstop=0', 'tabstop=8']],
]

const PROSE_FILETYPES = ['markdown', 'org', 'text', 'gitcommit']

const SIDEBAR_FILETYPES = [
  'help',
  'man',
  'qf',
  'startify',
  'simpletree',
  'simpleminimap',
  'simpleplug',
  'terminal',
]

if !exists('g:vimrc_whitespace_highlight')
  g:vimrc_whitespace_highlight = 1
endif
if !exists('g:vimrc_preserve_markdown_breaks')
  g:vimrc_preserve_markdown_breaks = 1
endif

# Markdown permits a hard line break after two or more literal spaces. Only
# whitespace-only lines, a single trailing space, or a trailing tab are noise.
const WHITESPACE_PATTERN = '\m[ \t]\+$'
const MARKDOWN_WHITESPACE_PATTERN =
      '\m^[ \t]\+$\|\S\@<=\([ \t]*\t \?\| \)$'

def EditingBuffer(): bool
  # Remote files use acwrite; prompt, terminal and plugin buffers own their
  # formatting and window options and must never receive the editing baseline.
  return (&buftype ==# '' || &buftype ==# 'acwrite')
        && index(SIDEBAR_FILETYPES, &filetype) < 0
enddef

# Match the provider's published virtual-buffer identity without probing or
# autoloading SimpleRemote. Generic acwrite buffers retain their own view.
def NativeRemoteBuffer(): bool
  if !get(g:, 'vimrc_native_remote_view', true) || &buftype !=# 'acwrite'
    return false
  endif
  var workspace: any = get(g:, 'simpleremote_workspace', {})
  var remote: any = get(b:, 'vimrc_remote', {})
  var status: any = get(g:, 'simpleremote_status', 'disconnected')
  if type(workspace) != v:t_dict || type(remote) != v:t_dict
      || type(status) != v:t_string || empty(status)
      || status ==# 'disconnected' || status =~# '^connecting '
    return false
  endif
  var generation: any = get(remote, 'generation', -1)
  var path: any = get(remote, 'path', '')
  return type(generation) == v:t_number && generation >= 0
    && get(workspace, 'id', -2) == generation
    && get(workspace, 'mode', '') ==# 'virtual'
    && empty(get(workspace, 'local_root', ''))
    && type(path) == v:t_string && path =~# '^/'
    && get(remote, 'uri', '') ==# 'remote://' .. path
    && bufname() ==# 'remote://' .. path
enddef

def ApplyNativeIdeView()
  # Diff and plugin windows own their display and folds. Other unsupported
  # views, including right-to-left text, keep Vim's compatibility rendering.
  if !g:VimrcNativeIde() || (&buftype !=# '' && !NativeRemoteBuffer())
      || !EditingBuffer() || &diff
    return
  endif
  setlocal nowrap nospell nolist conceallevel=0 foldcolumn=0 nofoldenable
  setlocal signcolumn=yes
enddef

# An asynchronous read may finish with FileType already set, or in an
# unfocused split. Apply the existing view policy to every visible target
# without changing the user's window, buffer, cursor or focus.
def RemoteBufferReadView()
  var event: any = get(g:, 'simpleremote_event', {})
  if type(event) != v:t_dict || get(event, 'event', '') !=# 'SimpleRemoteBufferRead'
    return
  endif
  var buffer: any = get(event, 'bufnr', 0)
  if type(buffer) != v:t_number || buffer <= 0
    return
  endif
  for window in win_findbuf(buffer)
    win_execute(window, 'call ' .. expand('<SID>') .. 'ApplyNativeIdeView()')
  endfor
enddef

def ApplyHighlights()
  highlight default ExtraWhitespace ctermbg=red guibg=#5f0000
enddef

def ClearStaleSimpleccMaps()
  for [mode, mappings] in [['n', SIMPLECC_NMAPS], ['i', SIMPLECC_IMAPS]]
    for mapping in mappings
      var existing = maparg(mapping[0], mode, false, true)
      if get(existing, 'buffer', 0) == 1
            \ && get(existing, 'rhs', '') ==# mapping[1]
        execute $'silent! {mode}unmap <buffer> ' .. mapping[0]
      endif
    endfor
  endfor
  # Only remove shortcuts installed by this script, even when a user chooses
  # the same plug target. Script IDs survive re-sourcing the same file.
  var owner = str2nr(matchstr(expand('<SID>'), '\d\+'))
  for [mode, mappings] in [['n', SEMANTIC_NMAPS + SEMANTIC_EDIT_NMAPS + SEMANTIC_POPUP_NMAPS], ['i', SEMANTIC_IMAPS], ['x', SEMANTIC_XMAPS]]
    for mapping in mappings
      var existing = maparg(mapping[0], mode, false, true)
      if get(existing, 'buffer', 0) == 1 && get(existing, 'sid', -1) == owner
            \ && get(existing, 'rhs', '') ==# mapping[1]
        execute $'silent! {mode}unmap <buffer> ' .. mapping[0]
      endif
    endfor
  endfor
enddef

def ApplyBufferBaseline()
  # 先恢复稳定基线，避免同一 buffer 改 filetype 后局部设置泄漏。
  setlocal expandtab
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal tabstop=4
  setlocal wrap
  setlocal nolinebreak
  setlocal nobreakindent
  setlocal textwidth=0
  setlocal colorcolumn=
  setlocal conceallevel=0
  setlocal nospell
  setlocal spelllang<
  setlocal formatoptions-=c
  setlocal formatoptions-=r
  setlocal formatoptions-=o
  setlocal formatoptions+=j
  # Release only our Julia provider. A filetype plugin or user may have
  # installed a different completefunc, which is not ours to clear.
  if &l:completefunc ==# 'simpleedit#UnicodeComplete'
    setlocal completefunc=
  endif
enddef

def ApplyFiletypeOverrides()
  for [filetypes, arguments] in INDENT_RULES
    if index(filetypes, &filetype) >= 0
      execute 'setlocal ' .. join(arguments)
      break
    endif
  endfor

  if index(PROSE_FILETYPES, &filetype) >= 0
    setlocal linebreak
    setlocal breakindent
  endif

  if &filetype ==# 'gitcommit'
    setlocal textwidth=72
    setlocal colorcolumn=73
    setlocal spell
    setlocal spelllang=en,cjk
  endif

  # SimpleEdit 的 LaTeX/emoji 序列补全挂到 <C-x><C-u>；SimpleCC 走自己的
  # 补全通道，不经过 completefunc，两者互不干扰。
  if &filetype ==# 'julia' && empty(&l:completefunc)
        \ && exists('g:loaded_simpleedit')
    setlocal completefunc=simpleedit#UnicodeComplete
  endif
enddef

def ApplyLspMappings()
  # Keep Vim's native gd/gr/gi/K motions everywhere except buffers covered by
  # the configured language-server set.
  if !exists('g:loaded_simplecc')
        \ || !EditingBuffer()
        \ || get(b:, 'vimrc_large_file', 0)
        \ || index(LSP_FILETYPES, &filetype) < 0
    return
  endif
  for mapping in SIMPLECC_NMAPS
    var existing = maparg(mapping[0], 'n', false, true)
    if empty(existing) || get(existing, 'rhs', '') ==# mapping[1]
      execute $'nmap <buffer> <silent> {mapping[0]} {mapping[1]}'
    endif
  endfor
  for mapping in SIMPLECC_IMAPS
    var existing = maparg(mapping[0], 'i', false, true)
    if empty(existing) || get(existing, 'rhs', '') ==# mapping[1]
      execute $'imap <buffer> <silent> {mapping[0]} {mapping[1]}'
    endif
  endfor
  # Each shortcut is gated on its actual command, including provider reloads.
  if empty(bufname())
    return
  endif
  for [mode, mappings, edits, expression] in [
      ['n', SEMANTIC_NMAPS, false, false], ['n', SEMANTIC_EDIT_NMAPS, true, false],
      ['i', SEMANTIC_IMAPS, true, false], ['x', SEMANTIC_XMAPS, true, false],
      ['n', SEMANTIC_POPUP_NMAPS, false, true]]
    if edits && (&readonly || !&modifiable)
      continue
    endif
    for mapping in mappings
      if exists(':' .. mapping[2]) == 2 && empty(maparg(mapping[0], mode, false, true))
        execute $'{mode}{expression ? "noremap" : "map"} <buffer> <silent> {expression ? "<expr>" : ""} {mapping[0]} {mapping[1]}'
      endif
    endfor
  endfor
enddef

def g:VimrcConfigureFiletype()
  ClearStaleSimpleccMaps()
  if !EditingBuffer() || (g:VimrcNativeIde() && &diff)
    ShowWhitespaceMatch()
    return
  endif
  ApplyBufferBaseline()
  ApplyFiletypeOverrides()
  # FileType can run after SimpleEditorConfig's BufReadPost hook. Reapply it so
  # project policy wins over this configuration's fallback indentation rules.
  if exists('g:loaded_simpleeditorconfig') && !empty(bufname())
    simpleeditorconfig#Apply(bufnr())
  endif
  ApplyLspMappings()
  # FileType may arrive after the initial large-file detection or on reload.
  # Reassert its opt-outs without resetting workflow's per-window snapshots.
  if exists('*g:VimrcApplyLargeFileMode')
    g:VimrcApplyLargeFileMode()
  endif
  ApplyNativeIdeView()
  ShowWhitespaceMatch()
enddef

def RestoreCursor()
  if !EditingBuffer() || get(b:, 'vimrc_cursor_restored', 0)
        \ || get(b:, 'vimrc_large_file', 0)
        \ || index(['gitcommit', 'gitrebase', 'gitconfig'], &filetype) >= 0
    return
  endif
  b:vimrc_cursor_restored = 1
  var last_line = line('''"')
  if last_line >= 1 && last_line <= line('$')
    execute 'keepjumps normal! g`"'
  endif
enddef

def OwnedWhitespaceMatch(): bool
  var match_id = get(w:, 'vimrc_trailing_ws_match', -1)
  if type(match_id) != v:t_number || match_id <= 0
    return false
  endif
  for match in getmatches()
    if match.id == match_id
      return match.group ==# 'ExtraWhitespace'
            && get(match, 'pattern', '') ==#
              get(w:, 'vimrc_trailing_ws_pattern', '')
    endif
  endfor
  return false
enddef

def ClearWhitespaceMatch()
  # clearmatches() followed by another plugin may reuse our old numeric ID.
  # Delete only the match we still own, never that replacement.
  if OwnedWhitespaceMatch()
    matchdelete(w:vimrc_trailing_ws_match)
  endif
  w:vimrc_trailing_ws_match = -1
  w:vimrc_trailing_ws_pattern = ''
enddef

def PreserveMarkdownBreaks(): bool
  return &filetype =~# '^markdown\%(\.\|$\)'
        && !!get(b:, 'vimrc_preserve_markdown_breaks',
          get(g:, 'vimrc_preserve_markdown_breaks', 1))
enddef

def ShowWhitespaceMatch()
  if !EditingBuffer() || !&modifiable || &binary
        \ || mode() =~# '^i'
        \ || !get(b:, 'vimrc_whitespace_highlight',
          get(g:, 'vimrc_whitespace_highlight', 1))
        \ || get(b:, 'vimrc_large_file', 0)
    ClearWhitespaceMatch()
    return
  endif
  var pattern = PreserveMarkdownBreaks()
        ? MARKDOWN_WHITESPACE_PATTERN : WHITESPACE_PATTERN
  if get(w:, 'vimrc_trailing_ws_pattern', '') ==# pattern
        && OwnedWhitespaceMatch()
    return
  endif
  ClearWhitespaceMatch()
  w:vimrc_trailing_ws_match = matchadd('ExtraWhitespace', pattern, 10)
  w:vimrc_trailing_ws_pattern = pattern
enddef

def g:VimrcStripWhitespace(first: number = 1, last: number = line('$'),
    force: bool = false)
  if !EditingBuffer() || !&modifiable || &readonly || &binary
    g:VimrcWarn('当前 buffer 不允许清理尾随空白')
    return
  endif

  var view = winsaveview()
  var pattern = !force && PreserveMarkdownBreaks()
        ? MARKDOWN_WHITESPACE_PATTERN : WHITESPACE_PATTERN
  try
    execute $'silent keepjumps keeppatterns :{first},{last}substitute/'
          .. pattern .. '//e'
  finally
    winrestview(view)
    ShowWhitespaceMatch()
  endtry
enddef

command! -range=% -bang StripWhitespace
      \ call g:VimrcStripWhitespace(<line1>, <line2>, '<bang>' ==# '!')

def CheckCurrentFile()
  # Without a buffer number :checktime stats every loaded file on each switch.
  # Hidden files are checked when entered; remote buffers own their transport.
  if &buftype ==# '' && !empty(bufname()) && &autoread && !&modified
    execute 'silent! checktime ' .. bufnr()
  endif
enddef

def RefreshLargeFileEditing()
  ClearStaleSimpleccMaps()
  ApplyLspMappings()
  ShowWhitespaceMatch()
enddef

# ============================================================================
# 自动命令
# ============================================================================
# Plugins may detect the filetype while vimrc is still loading. Define the
# highlight group before installing handlers or configuring that buffer.
ApplyHighlights()

augroup vimrc_core
  autocmd!
  autocmd FileType * call g:VimrcConfigureFiletype()
  autocmd BufReadPost * call RestoreCursor()
  autocmd FocusGained,BufEnter * call CheckCurrentFile()
  autocmd BufEnter * call RefreshLargeFileEditing()
  autocmd OptionSet readonly,modifiable call RefreshLargeFileEditing()
  autocmd VimResized * wincmd =
  autocmd ColorScheme * call ApplyHighlights()
  autocmd InsertEnter * call ClearWhitespaceMatch()
  autocmd InsertLeave,BufWinEnter,WinEnter * call ShowWhitespaceMatch()
  autocmd BufWinEnter,WinEnter * call ApplyNativeIdeView()
  autocmd User SimpleRemoteBufferRead call RemoteBufferReadView()
  autocmd BufWinLeave * call ClearWhitespaceMatch()
  autocmd User VimrcLargeFileChanged call RefreshLargeFileEditing()
  autocmd FileType help,man
        \ nnoremap <buffer> <silent> q <Cmd>close<CR>
  autocmd FileType qf
        \ nnoremap <buffer> <silent> q <Cmd>close<CR>
  if exists('##TerminalOpen')
    autocmd TerminalOpen *
          \ setlocal nonumber norelativenumber signcolumn=no
  endif
augroup END

if &filetype !=# ''
  g:VimrcConfigureFiletype()
endif

# A reload can happen with a sidebar focused or with ordinary files open in
# other tabs. Reassert only the native file windows without changing focus.
if g:VimrcNativeIde()
  for window in getwininfo()
    win_execute(window.winid, 'call ' .. expand('<SID>') .. 'ApplyNativeIdeView()')
  endfor
endif
