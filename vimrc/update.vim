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

const STAMP_FILE = C.vim_state .. '/update-check'

var fetch_job: any = v:null
var fetch_timer = -1
var pull_job: any = v:null

def Warn(message: string)
  echohl WarningMsg
  echomsg '[vimrc] ' .. message
  echohl None
enddef

def Info(message: string)
  echomsg '[vimrc] ' .. message
enddef

# 同步 git 调用只用于本地引用比较，不涉及网络，耗时可忽略。
def GitLines(arguments: list<string>): list<string>
  var output = systemlist(['git', '-C', C.root] + arguments)
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
    writefile([], STAMP_FILE)
  catch
  endtry
enddef

def StampIsFresh(): bool
  var stamp = getftime(STAMP_FILE)
  return stamp > 0 && localtime() - stamp < g:vimrc_update_interval
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
      Warn('当前分支没有 upstream，跳过更新检查')
    endif
    return
  endif

  var counts = split(
    get(GitLines(['rev-list', '--left-right', '--count', 'HEAD...@{u}']), 0, ''),
    '\t')
  if len(counts) < 2
    g:vimrc_update_status = {checked: localtime(), error: 'rev-list-failed'}
    if forced
      Warn('无法比较本地与 ' .. upstream)
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

  if behind > 0
    Warn(printf(
      '配置落后 %s %d 个提交%s，运行 :VimrcUpdate 拉取',
      upstream,
      behind,
      ahead > 0 ? printf('（本地另有 %d 个未推送提交）', ahead) : ''))
  elseif forced
    Info(printf(
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

def OnFetchExit(status: number, forced: bool)
  StopFetchTimer()
  fetch_job = v:null
  if status != 0
    g:vimrc_update_status = {checked: localtime(), error: 'fetch-failed'}
    if forced
      Warn('git fetch 失败（退出码 ' .. status .. '）')
    endif
    return
  endif
  ReportStatus(forced)
enddef

def Check(forced: bool)
  if !IsRepository()
    if forced
      Warn('配置目录不是 git 仓库: ' .. C.root)
    endif
    return
  endif
  if !has('job')
    if forced
      Warn('缺少 +job，无法后台检查更新')
    endif
    return
  endif
  if type(fetch_job) == v:t_job && job_status(fetch_job) ==# 'run'
    if forced
      Info('更新检查正在进行中')
    endif
    return
  endif
  if !forced && StampIsFresh()
    return
  endif

  # 无论 fetch 成败都记时间戳：失败时不要每次启动都重试网络。
  TouchStamp()

  fetch_job = job_start(
    ['git', '-C', C.root, 'fetch', '--quiet', '--no-tags'],
    {
      in_io: 'null',
      out_io: 'null',
      err_io: 'null',
      exit_cb: (_, status) => OnFetchExit(status, forced),
    })

  if type(fetch_job) != v:t_job || job_status(fetch_job) ==# 'fail'
    fetch_job = v:null
    if forced
      Warn('无法启动 git fetch')
    endif
    return
  endif

  StopFetchTimer()
  fetch_timer = timer_start(g:vimrc_update_timeout, (_) => {
    if type(fetch_job) == v:t_job && job_status(fetch_job) ==# 'run'
      job_stop(fetch_job)
      if forced
        Warn('git fetch 超时')
      endif
    endif
  })
enddef

def OnPullExit(status: number)
  pull_job = v:null
  if status != 0
    Warn('git pull --ff-only 失败（退出码 ' .. status .. '），请手动处理')
    return
  endif
  TouchStamp()
  ReportStatus(false)
  Info('配置已更新，执行 :VimrcReload 或重启 Vim 生效')
enddef

def g:VimrcUpdate()
  if !IsRepository()
    Warn('配置目录不是 git 仓库: ' .. C.root)
    return
  endif
  if type(pull_job) == v:t_job && job_status(pull_job) ==# 'run'
    Info('更新正在进行中')
    return
  endif
  if !empty(GitLines(['status', '--porcelain']))
    Warn('配置仓库有未提交改动，请先处理后再运行 :VimrcUpdate')
    return
  endif

  Info('正在拉取配置更新…')
  pull_job = job_start(
    ['git', '-C', C.root, 'pull', '--ff-only', '--quiet'],
    {
      in_io: 'null',
      out_io: 'null',
      err_io: 'null',
      exit_cb: (_, status) => OnPullExit(status),
    })
  if type(pull_job) != v:t_job || job_status(pull_job) ==# 'fail'
    pull_job = v:null
    Warn('无法启动 git pull')
  endif
enddef

def g:VimrcUpdateCheck()
  Check(true)
enddef

command! VimrcUpdate call g:VimrcUpdate()
command! VimrcUpdateCheck call g:VimrcUpdateCheck()
command! VimrcReload execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')

def ScheduleCheck()
  timer_start(g:vimrc_update_delay, (_) => Check(false))
enddef

augroup vimrc_update
  autocmd!
  if g:vimrc_update_check
    autocmd VimEnter * ++once call ScheduleCheck()
  endif
augroup END

if g:vimrc_update_check && v:vim_did_enter
  ScheduleCheck()
endif
