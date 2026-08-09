vim9script

var C = g:vimrc_context

# ============================================================================
# Vim9 辅助函数
# ============================================================================
# 只有测试和键位依赖的入口保留为全局函数；其余为脚本局部，重新 source 时
# 自动重定义。全局 def 无法覆盖旧定义，先统一清理再声明。
for completion in getcompletion('Vimrc', 'function')
  var function_name = substitute(completion, '(.*$', '', '')
  if exists('*' .. function_name)
    execute 'delfunction ' .. function_name
  endif
endfor

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
  'qf',
  'startify',
  'simpletree',
  'simpleminimap',
  'terminal',
]

def ApplyHighlights()
  highlight ExtraWhitespace ctermbg=red guibg=#5f0000
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
  var enter_mapping = maparg('<CR>', 'i', false, true)
  var enter_rhs = get(enter_mapping, 'rhs', '')
  if get(enter_mapping, 'buffer', 0) == 1
        \ && enter_rhs =~# 'simplecc#SelectEnterKey'
        \ && enter_rhs =~# 'lexima#expand'
    silent! iunmap <buffer> <CR>
  endif
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
  setlocal formatoptions-=c
  setlocal formatoptions-=r
  setlocal formatoptions-=o
  setlocal formatoptions+=j
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
  endif
enddef

def ApplyLspMappings()
  # Keep Vim's native gd/gr/gi/K motions everywhere except buffers covered by
  # the configured language-server set.
  if !C.plugins_ready
        \ || get(b:, 'vimrc_large_file', 0)
        \ || index(LSP_FILETYPES, &filetype) < 0
    return
  endif
  for mapping in SIMPLECC_NMAPS
    execute $'nmap <buffer> <silent> {mapping[0]} {mapping[1]}'
  endfor
  for mapping in SIMPLECC_IMAPS
    execute $'imap <buffer> <silent> {mapping[0]} {mapping[1]}'
  endfor
enddef

def g:VimrcConfigureFiletype()
  ClearStaleSimpleccMaps()
  ApplyBufferBaseline()
  ApplyFiletypeOverrides()
  # FileType can run after EditorConfig's BufReadPost hook.  Reapply it here so
  # project policy wins over this configuration's fallback indentation rules.
  if exists(':EditorConfigReload') == 2 && !empty(expand('%:p'))
    execute 'silent! EditorConfigReload'
  endif
  ApplyLspMappings()
enddef

def RestoreCursor()
  var last_line = line('''"')
  if last_line > 1 && last_line <= line('$') && &filetype !=# 'gitcommit'
    execute 'normal! g`"'
  endif
enddef

def ClearWhitespaceMatch()
  var match_id = get(w:, 'vimrc_trailing_ws_match', -1)
  if type(match_id) == v:t_number && match_id > 0
    try
      matchdelete(match_id)
    catch
    endtry
  endif
  w:vimrc_trailing_ws_match = -1
enddef

def ShowWhitespaceMatch()
  ClearWhitespaceMatch()
  if &buftype !=# ''
        \ || !&modifiable
        \ || get(b:, 'vimrc_large_file', 0)
        \ || index(SIDEBAR_FILETYPES, &filetype) >= 0
    return
  endif
  w:vimrc_trailing_ws_match = matchadd('ExtraWhitespace', '\s\+$', 10)
enddef

def g:VimrcStripWhitespace()
  if !&modifiable || &readonly || &binary
    echohl WarningMsg
    echomsg '[vimrc] 当前 buffer 不允许清理尾随空白'
    echohl None
    return
  endif

  var view = winsaveview()
  try
    silent! keepjumps keeppatterns :%substitute/\s\+$//e
  finally
    winrestview(view)
    ShowWhitespaceMatch()
  endtry
enddef

# SimpleLine 会在窗口事件中重写 statusline；侧栏必须恢复插件自己的状态栏。
# SimpleMinimap 现在自己在 BufWinEnter/WinEnter 上重新断言窗口选项，并导出规范
# 值，所以这里取用 StatuslineExpr() 而不是照抄字面量——两边各写一份迟早会漂移。
# 保留字面量分支，是为了插件尚未更新到带该接口的版本时仍能工作。
def RestoreSidebarStatusline()
  if &filetype ==# 'simpletree'
    &l:statusline = '%{simpletree#StatusLine()}'
  elseif &filetype ==# 'simpleminimap'
    if exists('*simpleminimap#StatuslineExpr')
      &l:statusline = simpleminimap#StatuslineExpr()
    else
      &l:statusline = get(g:, 'simpleminimap_show_statusline', 1)
            \ ? '%#SimpleMinimapTitle#%{simpleminimap#Statusline()}%*'
            \ : ''
    endif
  endif
enddef

def SetupCompletionEnter()
  if exists('*simplecc#SelectEnterKey') && exists('*lexima#expand')
    inoremap <buffer> <silent> <expr> <CR> pumvisible()
          \ ? simplecc#SelectEnterKey()
          \ : lexima#expand('<CR>', 'i')
  endif
enddef

def InstallPluginCompatibility()
  augroup vimrc_plugin_compat
    autocmd!
    autocmd WinEnter,WinLeave,BufEnter,BufWinEnter *
          \ call RestoreSidebarStatusline()
    autocmd FileType simpletree,simpleminimap
          \ call RestoreSidebarStatusline()
    autocmd InsertEnter * call SetupCompletionEnter()
  augroup END
  RestoreSidebarStatusline()
enddef

def SchedulePluginCompatibility()
  timer_start(0, (_) => InstallPluginCompatibility())
enddef

def HealthLine(state: string, label: string, detail: string = '')
  var icon = state ==# 'ok' ? '[OK]'
        \ : state ==# 'fail' ? '[FAIL]'
        \ : state ==# 'warn' ? '[WARN]'
        \ : '[SKIP]'
  var hl = state ==# 'ok' ? 'MoreMsg'
        \ : state ==# 'fail' ? 'ErrorMsg'
        \ : state ==# 'warn' ? 'WarningMsg'
        \ : 'Comment'
  echohl {hl}
  echomsg printf('  %-6s %-24s %s', icon, label, detail)
  echohl None
enddef

def g:VimrcHealth()
  var failures = 0
  var warnings = 0

  echomsg 'vimrc health — ' .. C.root

  var features = [
    'vim9script',
    'job',
    'channel',
    'timers',
    'popupwin',
    'textprop',
    'persistent_undo',
  ]
  for feature in features
    var ok = has(feature)
    HealthLine(ok ? 'ok' : 'fail', '+' .. feature)
    if !ok
      failures += 1
    endif
  endfor

  var json_ok = exists('*json_encode') && exists('*json_decode')
  HealthLine(json_ok ? 'ok' : 'fail', 'JSON functions')
  failures += json_ok ? 0 : 1

  var editorconfig_enabled = get(g:, 'vimrc_editorconfig', 1) != 0
  var editorconfig_ok = !editorconfig_enabled || exists(':EditorConfigReload') == 2
  HealthLine(
    editorconfig_ok ? (editorconfig_enabled ? 'ok' : 'skip') : 'warn',
    'EditorConfig',
    editorconfig_enabled ? 'Vim runtime package' : 'disabled')
  warnings += editorconfig_ok ? 0 : 1

  var hlyank_enabled = get(g:, 'vimrc_highlight_yank', 1) != 0
  var hlyank_ok = !hlyank_enabled || exists('#hlyank#TextYankPost')
  HealthLine(
    hlyank_ok ? (hlyank_enabled ? 'ok' : 'skip') : 'warn',
    'highlight yank',
    hlyank_enabled ? 'Vim runtime package' : 'disabled')
  warnings += hlyank_ok ? 0 : 1

  for tool in ['git', 'rg', 'cargo', 'rustc']
    var ok = executable(tool)
    HealthLine(ok ? 'ok' : 'warn', tool, ok ? exepath(tool) : '未找到')
    warnings += ok ? 0 : 1
  endfor

  for dir in [C.undo_dir, C.swap_dir, C.backup_dir, C.session_dir]
    var ok = isdirectory(dir) && filewritable(dir) == 2
    HealthLine(ok ? 'ok' : 'fail', fnamemodify(dir, ':t') .. ' state', dir)
    failures += ok ? 0 : 1
  endfor

  var active_config = get(g:, 'simplecc_config_path', '')
  var config_ok = !empty(active_config) && filereadable(active_config)
  var config_detail = empty(active_config)
        \ ? '项目配置发现已启用；其中 command/args 会执行'
        \ : active_config
  HealthLine(config_ok ? 'ok' : 'warn', 'SimpleCC config', config_detail)
  warnings += config_ok ? 0 : 1

  if C.plugins_enabled
    var simpleplug_home = C.plugin_home .. '/simpleplug'
    var manager_ok = g:VimrcSimplePlugReady()
    var bootstrap_phase = get(
          get(g:, 'vimrc_simpleplug_bootstrap_state', {}),
          'phase',
          'idle')
    HealthLine(
          manager_ok ? 'ok' : 'warn',
          'SimplePlug',
          manager_ok ? simpleplug_home : simpleplug_home .. ' (' .. bootstrap_phase .. ')')
    warnings += manager_ok ? 0 : 1

    var daemons = [
      ['simpleplug', 'simpleplug-daemon'],
      ['simplefinder', 'simplefinder-daemon'],
      ['simpletree', 'simpletree-daemon'],
      ['simpleline', 'simpleline-daemon'],
      ['simpleminimap', 'simpleminimap-daemon'],
      ['simpleclipboard', 'simpleclipboard-daemon'],
      ['simpletreesitter', 'ts-hl-daemon'],
      ['simplecc', 'simplecc-daemon'],
    ]
    for daemon in daemons
      var path = C.plugin_home .. '/' .. daemon[0] .. '/lib/' .. daemon[1]
      var ok = executable(path)
      HealthLine(ok ? 'ok' : 'warn', daemon[0] .. ' backend', path)
      warnings += ok ? 0 : 1
    endfor
  else
    HealthLine('skip', 'plugins', 'VIMRC_SKIP_PLUGINS=1')
  endif

  var clipboard_ok = has('unnamedplus')
        \ || executable('wl-copy')
        \ || executable('xclip')
        \ || executable('xsel')
        \ || executable(C.plugin_home .. '/simpleclipboard/lib/simpleclipboard-daemon')
  HealthLine(clipboard_ok ? 'ok' : 'warn', 'clipboard provider')
  warnings += clipboard_ok ? 0 : 1

  var lsp_install_is_explicit = get(g:, 'simplecc_auto_install', 1) == 0
  HealthLine(
        lsp_install_is_explicit ? 'ok' : 'warn',
        'language-server install',
        lsp_install_is_explicit ? 'explicit' : 'automatic')
  warnings += lsp_install_is_explicit ? 0 : 1

  g:vimrc_health_last = {fail: failures, warn: warnings}
  echomsg printf(
        'vimrc health: %d failure(s), %d warning(s)',
        failures,
        warnings)
enddef

command! StripWhitespace call g:VimrcStripWhitespace()
command! VimrcHealth call g:VimrcHealth()

# ============================================================================
# 自动命令
# ============================================================================
augroup vimrc_core
  autocmd!
  autocmd FileType * call g:VimrcConfigureFiletype()
  autocmd BufReadPost * call RestoreCursor()
  autocmd FocusGained,BufEnter * silent! checktime
  autocmd VimResized * wincmd =
  autocmd ColorScheme * call ApplyHighlights()
  autocmd InsertEnter * call ClearWhitespaceMatch()
  autocmd InsertLeave,BufWinEnter,WinEnter * call ShowWhitespaceMatch()
  autocmd BufWinLeave * call ClearWhitespaceMatch()
  autocmd FileType help,man
        \ nnoremap <buffer> <silent> q <Cmd>close<CR>
  autocmd FileType qf
        \ nnoremap <buffer> <silent> q <Cmd>close<CR>
  if exists('##TerminalOpen')
    autocmd TerminalOpen *
          \ setlocal nonumber norelativenumber signcolumn=no
  endif
augroup END

augroup vimrc_plugin_compat_boot
  autocmd!
  if C.plugins_ready
    autocmd VimEnter * ++once call SchedulePluginCompatibility()
  endif
augroup END

if !C.plugins_ready
  augroup vimrc_plugin_compat
    autocmd!
  augroup END
endif

if C.plugins_ready && v:vim_did_enter
  SchedulePluginCompatibility()
endif

if &filetype !=# ''
  g:VimrcConfigureFiletype()
endif
ApplyHighlights()
