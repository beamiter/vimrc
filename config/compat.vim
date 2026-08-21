vim9script

var C = g:vimrc_context

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

def SetupCompletionEnter()
  if exists('g:loaded_simplecc') && exists('g:loaded_simplepairs')
    inoremap <buffer> <silent> <expr> <CR> pumvisible()
          \ ? simplecc#SelectEnterKey()
          \ : simplepairs#Enter()
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
