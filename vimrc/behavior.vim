vim9script

var C = g:vimrc_context

# ============================================================================
# Vim9 辅助函数
# ============================================================================
for function_name in [
      'VimrcConfigureFiletype',
      'VimrcApplyHighlights',
      'VimrcRestoreCursor',
      'VimrcClearWhitespaceMatch',
      'VimrcShowWhitespaceMatch',
      'VimrcStripWhitespace',
      'VimrcRestoreSidebarStatusline',
      'VimrcSetupCompletionEnter',
      'VimrcInstallPluginCompatibility',
      'VimrcSchedulePluginCompatibility',
      'VimrcHealthLine',
      'VimrcHealth',
    ]
  if exists('*' .. function_name)
    execute 'delfunction ' .. function_name
  endif
endfor

def g:VimrcApplyHighlights()
  highlight ExtraWhitespace ctermbg=red guibg=#5f0000
enddef

def g:VimrcConfigureFiletype()
  for mapping in [
        ['gd', '<Plug>(simplecc-definition)'],
        ['gr', '<Plug>(simplecc-references)'],
        ['K', '<Plug>(simplecc-hover)'],
        ['gi', '<Plug>(simplecc-implementation)'],
        ['gy', '<Plug>(simplecc-type-definition)'],
        ['[d', '<Plug>(simplecc-prev-diagnostic)'],
        [']d', '<Plug>(simplecc-next-diagnostic)'],
      ]
    var existing = maparg(mapping[0], 'n', false, true)
    if get(existing, 'buffer', 0) == 1
          \ && get(existing, 'rhs', '') ==# mapping[1]
      execute 'silent! nunmap <buffer> ' .. mapping[0]
    endif
  endfor
  for mapping in [
        ['<Tab>', '<Plug>(simplecc-select-tab)'],
        ['<S-Tab>', '<Plug>(simplecc-select-shift-tab)'],
        ['<Down>', '<Plug>(simplecc-select-down)'],
        ['<Up>', '<Plug>(simplecc-select-up)'],
      ]
    var existing = maparg(mapping[0], 'i', false, true)
    if get(existing, 'buffer', 0) == 1
          \ && get(existing, 'rhs', '') ==# mapping[1]
      execute 'silent! iunmap <buffer> ' .. mapping[0]
    endif
  endfor
  var enter_mapping = maparg('<CR>', 'i', false, true)
  var enter_rhs = get(enter_mapping, 'rhs', '')
  if get(enter_mapping, 'buffer', 0) == 1
        \ && enter_rhs =~# 'simplecc#SelectEnterKey'
        \ && enter_rhs =~# 'lexima#expand'
    silent! iunmap <buffer> <CR>
  endif
  for mode_and_rhs in [
        ['n', '<Cmd>JuliaFormatterFormat<CR>'],
        ['x', ':JuliaFormatterFormat<CR>'],
      ]
    var existing = maparg(g:maplocalleader .. 'jf', mode_and_rhs[0], false, true)
    if get(existing, 'buffer', 0) == 1
          \ && get(existing, 'rhs', '') ==# mode_and_rhs[1]
      execute mode_and_rhs[0] ==# 'n'
            \ ? 'silent! nunmap <buffer> <localleader>jf'
            \ : 'silent! xunmap <buffer> <localleader>jf'
    endif
  endfor

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

  if index(['go', 'gomod', 'gowork'], &filetype) >= 0
    setlocal noexpandtab
    setlocal shiftwidth=4
    setlocal softtabstop=0
    setlocal tabstop=4
  elseif index([
        'c',
        'cpp',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'json',
        'jsonc',
        'yaml',
        'lua',
        'sh',
        'bash',
        'zsh',
        'haskell',
        'vim',
      ], &filetype) >= 0
    setlocal shiftwidth=2
    setlocal softtabstop=2
    setlocal tabstop=2
  elseif &filetype ==# 'make'
    setlocal noexpandtab
    setlocal shiftwidth=8
    setlocal softtabstop=0
    setlocal tabstop=8
  endif

  if index(['markdown', 'org', 'text', 'gitcommit'], &filetype) >= 0
    setlocal linebreak
    setlocal breakindent
  endif

  if &filetype ==# 'gitcommit'
    setlocal textwidth=72
    setlocal colorcolumn=73
  endif

  if C.plugins_ready && &filetype ==# 'julia'
    nnoremap <buffer> <silent> <localleader>jf <Cmd>JuliaFormatterFormat<CR>
    xnoremap <buffer> <silent> <localleader>jf :JuliaFormatterFormat<CR>
  endif

  # Keep Vim's native gd/gr/gi/K motions everywhere except buffers covered by
  # the configured language-server set.
  if C.plugins_ready && index([
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
      ], &filetype) >= 0
    nmap <buffer> <silent> gd <Plug>(simplecc-definition)
    nmap <buffer> <silent> gr <Plug>(simplecc-references)
    nmap <buffer> <silent> K <Plug>(simplecc-hover)
    nmap <buffer> <silent> gi <Plug>(simplecc-implementation)
    nmap <buffer> <silent> gy <Plug>(simplecc-type-definition)
    nmap <buffer> <silent> [d <Plug>(simplecc-prev-diagnostic)
    nmap <buffer> <silent> ]d <Plug>(simplecc-next-diagnostic)
    imap <buffer> <silent> <Tab> <Plug>(simplecc-select-tab)
    imap <buffer> <silent> <S-Tab> <Plug>(simplecc-select-shift-tab)
    imap <buffer> <silent> <Down> <Plug>(simplecc-select-down)
    imap <buffer> <silent> <Up> <Plug>(simplecc-select-up)
  endif
enddef

def g:VimrcRestoreCursor()
  var last_line = line('''"')
  if last_line > 1 && last_line <= line('$') && &filetype !=# 'gitcommit'
    execute 'normal! g`"'
  endif
enddef

def g:VimrcClearWhitespaceMatch()
  var match_id = get(w:, 'vimrc_trailing_ws_match', -1)
  if type(match_id) == v:t_number && match_id > 0
    try
      matchdelete(match_id)
    catch
    endtry
  endif
  w:vimrc_trailing_ws_match = -1
enddef

def g:VimrcShowWhitespaceMatch()
  g:VimrcClearWhitespaceMatch()
  if &buftype !=# ''
        \ || !&modifiable
        \ || index([
          'help',
          'qf',
          'startify',
          'simpletree',
          'simpleminimap',
          'terminal',
        ], &filetype) >= 0
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
    g:VimrcShowWhitespaceMatch()
  endtry
enddef

# SimpleLine 会在窗口事件中重写 statusline；侧栏必须恢复插件自己的状态栏。
def g:VimrcRestoreSidebarStatusline()
  if &filetype ==# 'simpletree'
    &l:statusline = '%{simpletree#StatusLine()}'
  elseif &filetype ==# 'simpleminimap'
    &l:statusline = get(g:, 'simpleminimap_show_statusline', 1)
          \ ? '%#SimpleMinimapTitle#%{simpleminimap#Statusline()}%*'
          \ : ''
  endif
enddef

def g:VimrcSetupCompletionEnter()
  if exists('*simplecc#SelectEnterKey') && exists('*lexima#expand')
    inoremap <buffer> <silent> <expr> <CR> pumvisible()
          \ ? simplecc#SelectEnterKey()
          \ : lexima#expand('<CR>', 'i')
  endif
enddef

def g:VimrcInstallPluginCompatibility()
  augroup vimrc_plugin_compat
    autocmd!
    autocmd WinEnter,WinLeave,BufEnter,BufWinEnter *
          \ call g:VimrcRestoreSidebarStatusline()
    autocmd FileType simpletree,simpleminimap
          \ call g:VimrcRestoreSidebarStatusline()
    autocmd InsertEnter * call g:VimrcSetupCompletionEnter()
  augroup END
  g:VimrcRestoreSidebarStatusline()
enddef

def g:VimrcSchedulePluginCompatibility()
  timer_start(0, (_) => g:VimrcInstallPluginCompatibility())
enddef

def g:VimrcHealthLine(state: string, label: string, detail: string = '')
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
    g:VimrcHealthLine(ok ? 'ok' : 'fail', '+' .. feature)
    if !ok
      failures += 1
    endif
  endfor

  var json_ok = exists('*json_encode') && exists('*json_decode')
  g:VimrcHealthLine(json_ok ? 'ok' : 'fail', 'JSON functions')
  failures += json_ok ? 0 : 1

  for tool in ['git', 'rg', 'cargo', 'rustc']
    var ok = executable(tool)
    g:VimrcHealthLine(ok ? 'ok' : 'warn', tool, ok ? exepath(tool) : '未找到')
    warnings += ok ? 0 : 1
  endfor

  for dir in [C.undo_dir, C.swap_dir, C.backup_dir, C.session_dir]
    var ok = isdirectory(dir) && filewritable(dir) == 2
    g:VimrcHealthLine(ok ? 'ok' : 'fail', fnamemodify(dir, ':t') .. ' state', dir)
    failures += ok ? 0 : 1
  endfor

  var active_config = get(g:, 'simplecc_config_path', '')
  var config_ok = !empty(active_config) && filereadable(active_config)
  var config_detail = empty(active_config)
        \ ? '项目配置发现已启用；其中 command/args 会执行'
        \ : active_config
  g:VimrcHealthLine(config_ok ? 'ok' : 'warn', 'SimpleCC config', config_detail)
  warnings += config_ok ? 0 : 1

  if C.plugins_enabled
    var simpleplug_home = C.plugin_home .. '/simpleplug'
    var manager_ok = isdirectory(simpleplug_home)
    g:VimrcHealthLine(manager_ok ? 'ok' : 'warn', 'SimplePlug', simpleplug_home)
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
      g:VimrcHealthLine(ok ? 'ok' : 'warn', daemon[0] .. ' backend', path)
      warnings += ok ? 0 : 1
    endfor
  else
    g:VimrcHealthLine('skip', 'plugins', 'VIMRC_SKIP_PLUGINS=1')
  endif

  var clipboard_ok = has('unnamedplus')
        \ || executable('wl-copy')
        \ || executable('xclip')
        \ || executable('xsel')
        \ || executable(C.plugin_home .. '/simpleclipboard/lib/simpleclipboard-daemon')
  g:VimrcHealthLine(clipboard_ok ? 'ok' : 'warn', 'clipboard provider')
  warnings += clipboard_ok ? 0 : 1

  var safe_install = get(g:, 'simpleplug_auto_install', 1) == 0
        \ && get(g:, 'simplecc_auto_install', 1) == 0
  g:VimrcHealthLine(safe_install ? 'ok' : 'fail', 'offline-by-default')
  failures += safe_install ? 0 : 1

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
  autocmd BufReadPost * call g:VimrcRestoreCursor()
  autocmd FocusGained,BufEnter * silent! checktime
  autocmd VimResized * wincmd =
  autocmd ColorScheme * call g:VimrcApplyHighlights()
  autocmd InsertEnter * call g:VimrcClearWhitespaceMatch()
  autocmd InsertLeave,BufWinEnter,WinEnter * call g:VimrcShowWhitespaceMatch()
  autocmd BufWinLeave * call g:VimrcClearWhitespaceMatch()
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
    autocmd VimEnter * ++once call g:VimrcSchedulePluginCompatibility()
  endif
augroup END

if !C.plugins_ready
  augroup vimrc_plugin_compat
    autocmd!
  augroup END
endif

if C.plugins_ready && v:vim_did_enter
  g:VimrcSchedulePluginCompatibility()
endif

if &filetype !=# ''
  g:VimrcConfigureFiletype()
endif
g:VimrcApplyHighlights()
