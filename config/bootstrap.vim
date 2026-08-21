vim9script

var C = g:vimrc_context

if !exists('g:vimrc_simpleplug_auto_bootstrap')
  g:vimrc_simpleplug_auto_bootstrap =
        $VIMRC_SKIP_SIMPLEPLUG_BOOTSTRAP ==# '1' ? 0 : 1
endif
if !exists('g:vimrc_simpleplug_bootstrap_script')
  g:vimrc_simpleplug_bootstrap_script =
        C.root .. '/utils/bootstrap-simpleplug.sh'
endif
if !exists('g:vimrc_simpleplug_update_timeout')
  # PlugUpdate includes Rust post-install hooks, so allow a slow first build.
  g:vimrc_simpleplug_update_timeout = 60 * 60
endif
if !exists('g:vimrc_simpleplug_bootstrap_state')
      || type(g:vimrc_simpleplug_bootstrap_state) != v:t_dict
  g:vimrc_simpleplug_bootstrap_state = {
    phase: 'idle',
    job: v:null,
    log: [],
    origin_winid: 0,
    update_bufnr: -1,
    update_started: 0,
    update_timer: -1,
  }
endif

def State(): dict<any>
  return g:vimrc_simpleplug_bootstrap_state
enddef

def g:VimrcSimplePlugReady(): bool
  var home = g:vimrc_context.plugin_home .. '/simpleplug'
  return filereadable(home .. '/autoload/simpleplug.vim')
        && filereadable(home .. '/plugin/simpleplug.vim')
        && executable(home .. '/lib/simpleplug-daemon')
enddef

def AppendBootstrapLog(message: string)
  if empty(message)
    return
  endif
  var state = State()
  if type(get(state, 'log', [])) != v:t_list
    state.log = []
  endif
  add(state.log, message)
  if len(state.log) > 80
    remove(state.log, 0, len(state.log) - 81)
  endif
  if message =~# '^BOOTSTRAP\>' || message =~? '^error:'
    g:VimrcInfo(message)
  endif
enddef

def OnBootstrapOutput(_channel: any, message: string)
  AppendBootstrapLog(message)
enddef

def StopUpdateTimer()
  var state = State()
  var timer = get(state, 'update_timer', -1)
  if type(timer) == v:t_number && timer >= 0
    timer_stop(timer)
  endif
  state.update_timer = -1
enddef

def UpdateResult(bufnr: number): dict<any>
  if bufnr <= 0 || !bufexists(bufnr)
    return {done: false, errors: 0}
  endif
  var lines = getbufline(bufnr, 1, 3)
  if empty(lines) || lines[0] !~# 'Update Complete'
    return {done: false, errors: 0}
  endif
  var errors = len(lines) > 1
        ? str2nr(matchstr(lines[1], '\<errors\s\+\zs\d\+'))
        : 0
  return {done: true, errors: errors}
enddef

def FindSimplePlugUi(): number
  if &filetype ==# 'simpleplug'
    return bufnr()
  endif
  for info in reverse(getbufinfo())
    if getbufvar(info.bufnr, '&filetype') ==# 'simpleplug'
      return info.bufnr
    endif
  endfor
  return -1
enddef

def FinishInitialUpdate(errors: number)
  StopUpdateTimer()
  var state = State()
  state.phase = 'reloading'

  # Newly cloned plugins were not part of Vim's startup runtime scan.  One
  # automatic reload activates them and rebuilds plugin-dependent mappings.
  try
    execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
  catch
    state.phase = 'update-failed'
    g:VimrcWarn('插件已经安装，但自动重载失败: ' .. v:exception)
    return
  endtry

  state = State()
  if errors == 0
    state.phase = 'ready'
    try
      simpleplug#UIClose()
    catch
    endtry
    var origin_winid = get(state, 'origin_winid', 0)
    if type(origin_winid) == v:t_number && origin_winid > 0
      win_gotoid(origin_winid)
    endif
    g:VimrcInfo('首次配置完成：SimplePlug 与全部插件已经就绪')
  else
    state.phase = 'ready-with-errors'
    g:VimrcWarn(printf(
          '首次 PlugUpdate 完成，但有 %d 个错误；详情保留在 SimplePlug 窗口',
          errors))
  endif
  silent! doautocmd <nomodeline> User VimrcBootstrapComplete
enddef

def PollInitialUpdate(timer_id: number)
  var state = State()
  if get(state, 'phase', '') !=# 'updating'
    timer_stop(timer_id)
    return
  endif

  var result = UpdateResult(get(state, 'update_bufnr', -1))
  if result.done
    FinishInitialUpdate(result.errors)
    return
  endif

  var timeout = get(g:, 'vimrc_simpleplug_update_timeout', 60 * 60)
  if type(timeout) != v:t_number || timeout <= 0
    timeout = 60 * 60
  endif
  if localtime() - get(state, 'update_started', localtime()) >= timeout
    StopUpdateTimer()
    state.phase = 'update-failed'
    g:VimrcWarn('首次 PlugUpdate 超时；可在 SimplePlug 窗口检查进度并手动重试')
  elseif localtime() - get(state, 'update_started', localtime()) >= 10
        && !bufexists(get(state, 'update_bufnr', -1))
    StopUpdateTimer()
    state.phase = 'update-failed'
    g:VimrcWarn('首次 PlugUpdate 未能启动；运行 :VimrcBootstrapStatus 查看日志')
  endif
enddef

def g:VimrcStartInitialPlugUpdate()
  var state = State()
  if get(state, 'phase', '') !=# 'manager-ready'
    return
  endif
  if exists(':PlugUpdate') != 2
    state.phase = 'update-failed'
    g:VimrcWarn('SimplePlug 已安装，但 :PlugUpdate 命令没有加载')
    return
  endif

  state.phase = 'updating'
  state.update_started = localtime()
  try
    # :PlugUpdate does not exist while this module is first compiled on a
    # pristine machine, so resolve it only after SimplePlug has been loaded.
    execute 'PlugUpdate'
  catch
    state.phase = 'update-failed'
    g:VimrcWarn('无法启动首次 PlugUpdate: ' .. v:exception)
    return
  endtry
  state.update_bufnr = FindSimplePlugUi()
  state.update_timer = timer_start(
        200,
        (timer_id) => PollInitialUpdate(timer_id),
        {repeat: -1})
enddef

def OnBootstrapExit(_job: any, status: number)
  var state = State()
  state.job = v:null
  if get(state, 'phase', '') ==# 'stopping'
    state.phase = 'stopped'
    g:VimrcWarn('SimplePlug bootstrap 已停止；运行 :VimrcBootstrapRetry 可重试')
    return
  endif
  if status != 0 || !g:VimrcSimplePlugReady()
    state.phase = 'failed'
    g:VimrcWarn(printf(
          'SimplePlug bootstrap 失败（退出码 %d）；运行 :VimrcBootstrapStatus 查看日志，:VimrcBootstrapRetry 重试',
          status))
    return
  endif

  state.phase = 'manager-ready'
  g:VimrcInfo('最新版 SimplePlug 安装完成，正在加载配置并执行首次 PlugUpdate…')
  try
    execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
  catch
    state.phase = 'failed'
    g:VimrcWarn('SimplePlug 安装成功，但自动加载配置失败: ' .. v:exception)
    return
  endtry
  timer_start(0, (_) => g:VimrcStartInitialPlugUpdate())
enddef

def g:VimrcStartSimplePlugBootstrap()
  var state = State()
  if !g:vimrc_context.plugins_enabled || g:VimrcSimplePlugReady()
    state.phase = 'ready'
    return
  endif
  if index(['running', 'manager-ready', 'updating', 'reloading'],
        get(state, 'phase', '')) >= 0
    return
  endif

  var script = get(g:, 'vimrc_simpleplug_bootstrap_script', '')
  if type(script) != v:t_string || !filereadable(script)
    state.phase = 'failed'
    g:VimrcWarn('找不到 SimplePlug bootstrap 脚本: ' .. string(script))
    return
  endif
  if !executable('bash')
    state.phase = 'failed'
    g:VimrcWarn('自动安装 SimplePlug 需要 bash')
    return
  endif

  state.phase = 'running'
  state.log = []
  state.origin_winid = win_getid()
  g:VimrcInfo('首次启动：正在后台安装最新版 SimplePlug（Vim 核心功能可直接使用）')

  var bootstrap_job: any = v:null
  try
    bootstrap_job = job_start(
          ['bash', script, g:vimrc_context.plugin_home .. '/simpleplug'],
          {
            in_io: 'null',
            out_io: 'pipe',
            err_io: 'pipe',
            out_mode: 'nl',
            err_mode: 'nl',
            out_cb: (channel, message) => OnBootstrapOutput(channel, message),
            err_cb: (channel, message) => OnBootstrapOutput(channel, message),
            exit_cb: (job, exit_status) => OnBootstrapExit(job, exit_status),
          })
  catch
    state.phase = 'failed'
    g:VimrcWarn('无法启动 SimplePlug bootstrap: ' .. v:exception)
    return
  endtry

  if type(bootstrap_job) != v:t_job || job_status(bootstrap_job) ==# 'fail'
    state.phase = 'failed'
    g:VimrcWarn('无法启动 SimplePlug bootstrap job')
    return
  endif
  state.job = bootstrap_job
enddef

def g:VimrcSimplePlugBootstrapRetry()
  var state = State()
  if type(get(state, 'job', v:null)) == v:t_job
        && job_status(state.job) ==# 'run'
    g:VimrcInfo('SimplePlug bootstrap 已在运行')
    return
  endif
  if g:VimrcSimplePlugReady()
    state.phase = 'ready'
    g:VimrcInfo('SimplePlug 已安装，无需 bootstrap')
    return
  endif
  state.phase = 'idle'
  timer_start(0, (_) => g:VimrcStartSimplePlugBootstrap())
enddef

def g:VimrcSimplePlugBootstrapStop()
  var state = State()
  var bootstrap_job = get(state, 'job', v:null)
  if type(bootstrap_job) != v:t_job || job_status(bootstrap_job) !=# 'run'
    g:VimrcInfo('当前没有正在运行的 SimplePlug bootstrap')
    return
  endif
  state.phase = 'stopping'
  job_stop(bootstrap_job)
enddef

def g:VimrcSimplePlugBootstrapStatus()
  var state = State()
  g:VimrcInfo('SimplePlug bootstrap 状态: ' .. get(state, 'phase', 'unknown'))
  var lines = get(state, 'log', [])
  if type(lines) == v:t_list
    var first = max([0, len(lines) - 12])
    for line in lines[first :]
      echomsg '  ' .. line
    endfor
  endif
enddef

command! VimrcBootstrapStatus call g:VimrcSimplePlugBootstrapStatus()
command! VimrcBootstrapRetry call g:VimrcSimplePlugBootstrapRetry()
command! VimrcBootstrapStop call g:VimrcSimplePlugBootstrapStop()

def g:VimrcConfigureSimplePlugBootstrap()
  var context = g:vimrc_context
  var state = State()
  if g:VimrcSimplePlugReady()
        && index(['idle', 'scheduled', 'failed', 'stopped'],
          get(state, 'phase', 'idle')) >= 0
    state.phase = 'ready'
  endif
  augroup vimrc_simpleplug_bootstrap
    autocmd!
    if context.plugins_enabled
          && g:vimrc_simpleplug_auto_bootstrap
          && !g:VimrcSimplePlugReady()
      autocmd VimEnter * ++once call g:VimrcStartSimplePlugBootstrap()
    endif
  augroup END

  if context.plugins_enabled
        && g:vimrc_simpleplug_auto_bootstrap
        && !g:VimrcSimplePlugReady()
    if get(state, 'phase', 'idle') ==# 'idle'
      state.phase = 'scheduled'
    endif
    if v:vim_did_enter
      timer_start(0, (_) => g:VimrcStartSimplePlugBootstrap())
    endif
  endif
enddef

g:VimrcConfigureSimplePlugBootstrap()
