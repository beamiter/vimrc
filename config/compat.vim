vim9script

var C = g:vimrc_context

# A reload can precede the previous zero-delay callback. Cancel it before
# replacing the script's functions, and keep just one pending installation.
if get(g:, 'vimrc_compat_timer', -1) > 0
  timer_stop(g:vimrc_compat_timer)
endif
g:vimrc_compat_timer = -1

const COMPLETION_ENTER =
      'pumvisible() ? simplecc#SelectEnterKey() : simplepairs#Enter()'

# ============================================================================
# 插件兼容层
# ============================================================================
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

def RestoreCompletionEnter()
  var mapping = maparg('<CR>', 'i', false, true)
  if get(mapping, 'buffer', 0) == 1
        && get(mapping, 'rhs', '') ==# COMPLETION_ENTER
    iunmap <buffer> <CR>
    var previous = get(b:, 'vimrc_previous_completion_enter', {})
    if !empty(previous)
      mapset('i', false, previous)
    endif
  endif
  unlet! b:vimrc_previous_completion_enter
enddef

def SetupCompletionEnter()
  if !exists('g:loaded_simplecc') || !exists('g:loaded_simplepairs')
        || !get(g:, 'simplepairs_default_mappings', 1)
        || (&buftype !=# '' && &buftype !=# 'acwrite')
        || !&modifiable || &readonly || get(b:, 'vimrc_large_file', 0)
    RestoreCompletionEnter()
    return
  endif

  var mapping = maparg('<CR>', 'i', false, true)
  var rhs = get(mapping, 'rhs', '')
  if rhs ==# COMPLETION_ENTER
    return
  endif
  # Compose only the plugins' own Enter keys. An existing user mapping,
  # including a global one, keeps its ownership on every InsertEnter/reload.
  if !empty(rhs) && index([
        '<Plug>(simplepairs-enter)',
        '<Plug>(simplecc-select-enter)',
        'simplepairs#Enter()',
        'simplecc#SelectEnterKey()',
      ], rhs) < 0
    return
  endif
  b:vimrc_previous_completion_enter = get(mapping, 'buffer', 0) == 1
        ? mapping : {}
  execute 'inoremap <buffer> <silent> <expr> <CR> ' .. COMPLETION_ENTER
enddef

def InstallPluginCompatibility()
  augroup vimrc_plugin_compat
    autocmd!
    autocmd WinEnter,WinLeave,BufEnter,BufWinEnter *
          \ call RestoreSidebarStatusline()
    autocmd FileType simpletree,simpleminimap
          \ call RestoreSidebarStatusline()
    autocmd InsertEnter,FileType * call SetupCompletionEnter()
    autocmd User VimrcLargeFileChanged call SetupCompletionEnter()
  augroup END
  RestoreSidebarStatusline()
enddef

def SchedulePluginCompatibility()
  if get(g:, 'vimrc_compat_timer', -1) > 0
    timer_stop(g:vimrc_compat_timer)
  endif
  g:vimrc_compat_timer = timer_start(0, (_) => {
    g:vimrc_compat_timer = -1
    InstallPluginCompatibility()
  })
enddef

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
  RestoreCompletionEnter()
endif

if C.plugins_ready && v:vim_did_enter
  SchedulePluginCompatibility()
endif
