vim9script

var C = g:vimrc_context

# ============================================================================
# 配置仓库更新检查
# ============================================================================
# 启动后异步 `git fetch` 本仓库，只读取远端引用，不动工作区，也不碰插件。
# 真正的拉取始终是显式的 :VimrcUpdate。
#
#   g:vimrc_update_check     0 关闭自动检查（VIMRC_SKIP_UPDATE_CHECK=1 等效）
#   g:vimrc_update_interval  两次自动检查的最小间隔（秒），默认 24 小时
#   g:vimrc_update_delay     VimEnter 之后延迟多久开始 fetch（毫秒）
#   g:vimrc_update_timeout   fetch 超时（毫秒），超时后 job 被终止
#   g:vimrc_update_status    最近一次检查结果，可用于 statusline

if !exists('g:vimrc_update_check')
  g:vimrc_update_check = $VIMRC_SKIP_UPDATE_CHECK ==# '1' ? 0 : 1
endif
if !exists('g:vimrc_update_interval')
  g:vimrc_update_interval = 24 * 60 * 60
endif
if !exists('g:vimrc_update_delay')
  g:vimrc_update_delay = 800
endif
if !exists('g:vimrc_update_timeout')
  g:vimrc_update_timeout = 20000
endif
if !exists('g:vimrc_update_status')
  g:vimrc_update_status = {}
endif

# Keep this controller alive across :source; pending callbacks must retain
# their script-local functions until their job and channel are drained.

var fetch_job: any = v:null
var fetch_timer = -1
var pull_job: any = v:null
var pull_timer = -1
var schedule_timer = -1
var generation = 0
var fetch_error = ''
var pull_error = ''
var fetch_timed_out = false
var pull_timed_out = false

def NumberSetting(name: string, fallback: number): number
  var value = get(g:, name, fallback)
  return type(value) == v:t_number && value > 0 ? value : fallback
enddef

def Running(job: any): bool
  return type(job) == v:t_job && job_status(job) ==# 'run'
enddef

def CaptureError(token: number, kind: string, message: string)
  if token != generation
    return
  endif
  if kind ==# 'fetch'
    fetch_error = strpart(fetch_error .. message, 0, 2048)
  else
    pull_error = strpart(pull_error .. message, 0, 2048)
  endif
enddef

# 同步 git 调用只用于本地引用比较，不涉及网络，耗时可忽略。
def GitLines(arguments: list<string>): list<string>
  # Vim's systemlist() takes a shell command string (unlike job_start(), which
  # also accepts argv).  Quote every dynamic component so paths and ref names
  # remain safe when handed to the shell.
  var command = 'git -C ' .. shellescape(C.root)
  for argument in arguments
    command ..= ' ' .. shellescape(argument)
  endfor
  var output = systemlist(command)
  if v:shell_error != 0
    return []
  endif
  return output
enddef

def IsRepository(): bool
  if !executable('git')
    return false
  endif
  # 子模块和 worktree 里 .git 是文件而不是目录。
  var dot_git = C.root .. '/.git'
  return isdirectory(dot_git) || filereadable(dot_git)
enddef

def TouchStamp()
  if !isdirectory(C.vim_state) || filewritable(C.vim_state) != 2
    return
  endif
  try
    writefile([], C.vim_state .. '/update-check')
  catch
  endtry
enddef

def StampIsFresh(): bool
  var stamp = getftime(C.vim_state .. '/update-check')
  return stamp > 0 && localtime() - stamp < NumberSetting('vimrc_update_interval', 86400)
enddef

# fetch 之后比较本地 HEAD 与 upstream；forced 时才对无 upstream 等情况出声。
def ReportStatus(forced: bool)
  var upstream = get(
    GitLines(['rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{u}']),
    0,
    '')
  if empty(upstream)
    g:vimrc_update_status = {checked: localtime(), error: 'no-upstream'}
    if forced
      g:VimrcWarn('当前分支没有 upstream，跳过更新检查')
    endif
    return
  endif

  var counts = split(
    get(GitLines(['rev-list', '--left-right', '--count', 'HEAD...@{u}']), 0, ''),
    '\t')
  if len(counts) < 2
    g:vimrc_update_status = {checked: localtime(), error: 'rev-list-failed'}
    if forced
      g:VimrcWarn('无法比较本地与 ' .. upstream)
    endif
    return
  endif

  var ahead = str2nr(counts[0])
  var behind = str2nr(counts[1])
  g:vimrc_update_status = {
    checked: localtime(),
    upstream: upstream,
    ahead: ahead,
    behind: behind,
  }

  # statusline 段位读 g:vimrc_update_status，结果变了就重画一次。
  if exists(':redrawstatus') == 2
    silent! redrawstatus!
  endif

  if behind > 0
    g:VimrcWarn(printf(
      '配置落后 %s %d 个提交%s，运行 :VimrcUpdate 拉取',
      upstream,
      behind,
      ahead > 0 ? printf('（本地另有 %d 个未推送提交）', ahead) : ''))
  elseif forced
    g:VimrcInfo(printf(
      '配置已是最新（%s%s）',
      upstream,
      ahead > 0 ? printf('，本地领先 %d 个提交', ahead) : ''))
  endif
enddef

def StopFetchTimer()
  if fetch_timer >= 0
    timer_stop(fetch_timer)
    fetch_timer = -1
  endif
enddef

def OnFetchExit(token: number, status: number, forced: bool)
  if token != generation
    return
  endif
  StopFetchTimer()
  fetch_job = v:null
  if status != 0
    g:vimrc_update_status = {checked: localtime(),
      error: fetch_timed_out ? 'fetch-timeout' : 'fetch-failed'}
    if forced
      g:VimrcWarn(fetch_timed_out ? 'git fetch 超时，已停止'
        : 'git fetch 失败（退出码 ' .. status .. '）: ' .. trim(fetch_error))
    endif
    return
  endif
  ReportStatus(forced)
enddef

def Check(forced: bool)
  if !IsRepository()
    if forced
      g:VimrcWarn('配置目录不是 git 仓库: ' .. C.root)
    endif
    return
  endif
  if !has('job')
    if forced
      g:VimrcWarn('缺少 +job，无法后台检查更新')
    endif
    return
  endif
  if Running(fetch_job) || Running(pull_job)
    if forced
      g:VimrcInfo('配置检查或更新正在进行中')
    endif
    return
  endif
  if !forced && StampIsFresh()
    return
  endif

  # 无论 fetch 成败都记时间戳：失败时不要每次启动都重试网络。
  TouchStamp()

  generation += 1
  const token = generation
  fetch_error = ''
  fetch_timed_out = false
  fetch_job = job_start(
    ['git', '-C', C.root, 'fetch', '--quiet', '--no-tags'],
    {
      in_io: 'null',
      out_io: 'null',
      err_io: 'pipe',
      err_mode: 'raw',
      env: {GIT_TERMINAL_PROMPT: '0', GCM_INTERACTIVE: 'never'},
      err_cb: (_, message) => CaptureError(token, 'fetch', message),
      exit_cb: (_, status) => OnFetchExit(token, status, forced),
    })

  if type(fetch_job) != v:t_job || job_status(fetch_job) ==# 'fail'
    fetch_job = v:null
    if forced
      g:VimrcWarn('无法启动 git fetch')
    endif
    return
  endif

  StopFetchTimer()
  # job_status() may synchronously deliver an exit callback for a fast job.
  # Do not recreate a timeout that the callback has already cleaned up.
  if !Running(fetch_job)
    return
  endif
  fetch_timer = timer_start(NumberSetting('vimrc_update_timeout', 20000), (_) => {
    if token == generation && Running(fetch_job)
      fetch_timed_out = true
      job_stop(fetch_job, 'kill')
    endif
  })
enddef

def OnPullExit(token: number, status: number)
  if token != generation
    return
  endif
  if pull_timer >= 0
    timer_stop(pull_timer)
    pull_timer = -1
  endif
  pull_job = v:null
  if status != 0
    g:vimrc_update_status = {checked: localtime(),
      error: pull_timed_out ? 'pull-timeout' : 'pull-failed'}
    g:VimrcWarn(pull_timed_out ? 'git pull 超时，已停止；可重试 :VimrcUpdate'
      : 'git pull --ff-only 失败（退出码 ' .. status .. '）: ' .. trim(pull_error))
    return
  endif
  TouchStamp()
  ReportStatus(false)
  g:VimrcInfo('配置已更新，执行 :VimrcReload 或重启 Vim 生效')
enddef

def g:VimrcStopUpdateJobs()
  # Invalidate late callbacks before stopping their processes.
  generation += 1
  StopFetchTimer()
  for timer in [pull_timer, schedule_timer]
    if timer >= 0
      timer_stop(timer)
    endif
  endfor
  pull_timer = -1
  schedule_timer = -1
  if type(fetch_job) == v:t_job && job_status(fetch_job) ==# 'run'
    job_stop(fetch_job, 'kill')
  endif
  if type(pull_job) == v:t_job && job_status(pull_job) ==# 'run'
    job_stop(pull_job, 'kill')
  endif
  fetch_job = v:null
  pull_job = v:null
enddef

def g:VimrcReload()
  # Stop background work; controller modules retain callback ownership until
  # Vim exits, so late process notifications remain safe after a reload.
  g:VimrcStopUpdateJobs()
  if exists('*g:VimrcGrepStop') == 1
    g:VimrcGrepStop()
  endif
  if exists(':SimpleRemoteDisconnect') == 2
    try
      silent execute 'SimpleRemoteDisconnect'
    catch
    endtry
  endif
  execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
enddef

def g:VimrcUpdate()
  if !IsRepository()
    g:VimrcWarn('配置目录不是 git 仓库: ' .. C.root)
    return
  endif
  if Running(pull_job) || Running(fetch_job)
    g:VimrcInfo('配置检查或更新正在进行中')
    return
  endif
  # A failed status command must never be mistaken for a clean checkout.
  var changes = systemlist('git -C ' .. shellescape(C.root)
    .. ' status --porcelain')
  if v:shell_error != 0
    g:VimrcWarn('无法读取配置仓库状态，更新已取消')
    return
  endif
  if !empty(changes)
    g:VimrcWarn('配置仓库有未提交改动，请先处理后再运行 :VimrcUpdate')
    return
  endif

  if !has('job')
    g:VimrcWarn('缺少 +job，无法后台更新')
    return
  endif
  generation += 1
  const token = generation
  pull_error = ''
  pull_timed_out = false
  g:VimrcInfo('正在拉取配置更新…')
  pull_job = job_start(
    ['git', '-C', C.root, 'pull', '--ff-only', '--quiet'],
    {
      in_io: 'null',
      out_io: 'null',
      err_io: 'pipe',
      err_mode: 'raw',
      env: {GIT_TERMINAL_PROMPT: '0', GCM_INTERACTIVE: 'never'},
      err_cb: (_, message) => CaptureError(token, 'pull', message),
      exit_cb: (_, status) => OnPullExit(token, status),
    })
  if type(pull_job) != v:t_job || job_status(pull_job) ==# 'fail'
    pull_job = v:null
    g:VimrcWarn('无法启动 git pull')
    return
  endif
  if !Running(pull_job)
    return
  endif
  pull_timer = timer_start(NumberSetting('vimrc_update_pull_timeout', 120000), (_) => {
    if token == generation && Running(pull_job)
      pull_timed_out = true
      job_stop(pull_job, 'kill')
    endif
  })
enddef

def g:VimrcUpdateCheck()
  Check(true)
enddef

# ----------------------------------------------------------------------------
# statusline 段位
# ----------------------------------------------------------------------------
# 每次重画都会调用，因此只读 g:vimrc_update_status，绝不在这里跑 git。
def g:VimrcUpdateStatusline(): string
  var status = get(g:, 'vimrc_update_status', {})
  if type(status) != v:t_dict
    return ''
  endif
  var behind = get(status, 'behind', 0)
  if type(behind) != v:t_number || behind <= 0
    return ''
  endif
  var icon = get(g:, 'simpleline_nerdfont', 1) ? '󰚰 ' : 'vimrc '
  return icon .. behind
enddef

command! VimrcUpdate call g:VimrcUpdate()
command! VimrcUpdateCheck call g:VimrcUpdateCheck()
command! VimrcUpdateStop call g:VimrcStopUpdateJobs()
command! VimrcReload call g:VimrcReload()

def ScheduleCheck()
  if schedule_timer >= 0
    timer_stop(schedule_timer)
  endif
  const token = generation
  schedule_timer = timer_start(NumberSetting('vimrc_update_delay', 800), (_) => {
    schedule_timer = -1
    if token == generation
      Check(false)
    endif
  })
enddef

def g:VimrcConfigureUpdates()
  g:VimrcStopUpdateJobs()
  C = g:vimrc_context
  g:VimrcRegisterStatuslineSegment({
    fn: 'g:VimrcUpdateStatusline',
    hl: 'SimpleLineDiagWarn',
  })
  augroup vimrc_update
    autocmd!
    autocmd VimLeavePre * call g:VimrcStopUpdateJobs()
    if get(g:, 'vimrc_update_check', 1) && $VIMRC_SKIP_UPDATE_CHECK !=# '1'
      autocmd VimEnter * ++once call ScheduleCheck()
    endif
  augroup END
  if get(g:, 'vimrc_update_check', 1) && $VIMRC_SKIP_UPDATE_CHECK !=# '1'
        && v:vim_did_enter
    ScheduleCheck()
  endif
enddef

g:VimrcConfigureUpdates()
