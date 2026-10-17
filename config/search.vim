vim9script

# Native asynchronous project search. No plugin, shell interpolation or cwd
# mutation is involved. Each request owns one quickfix list and bounded output.
# This controller is sourced once: :VimrcReload cancels work and rewires it.
if !exists('g:vimrc_grep_max_results')
  g:vimrc_grep_max_results = 2000
endif
if !exists('g:vimrc_grep_timeout')
  g:vimrc_grep_timeout = 15000
endif
if !exists('g:vimrc_grep_open')
  g:vimrc_grep_open = 1
endif

var sequence = 0
var current: dict<any> = {phase: 'idle', count: 0}
g:vimrc_grep_state = current

def Setting(name: string, fallback: number): number
  var value = get(g:, name, fallback)
  return type(value) == v:t_number && value > 0 ? value : fallback
enddef

def StopTimer()
  var timer = get(current, 'timer', -1)
  if timer >= 0
    timer_stop(timer)
  endif
  current.timer = -1
enddef

def StopProcess(reason: string)
  current.reason = reason
  var job = get(current, 'job', v:null)
  if type(job) == v:t_job && job_status(job) ==# 'run'
    job_stop(job, 'kill')
  endif
enddef

def Publish(phase: string)
  StopTimer()
  current.phase = phase
  current.count = len(current.items)
  current.pending = ''
  current.elapsed_ms = reltimefloat(reltime(current.started)) * 1000.0
  var context = {
    vimrc: 'grep', root: current.root, pattern: current.pattern,
    phase: phase, reason: current.reason, count: current.count,
    skipped: current.skipped,
  }
  # A compiler/LSP may have replaced the current quickfix list while rg ran.
  # Address our captured id, and never open or change somebody else's list.
  if getqflist({id: current.qfid}).id == current.qfid
    setqflist([], 'r', {
      id: current.qfid, items: current.items, context: context,
      title: printf('grep: %s [%s, %d lines]', current.pattern, phase, current.count),
    })
    if current.count > 0 && get(g:, 'vimrc_grep_open', 1)
          && phase !=# 'cancelled' && tabpagenr() == current.tab
          && getqflist({id: 0}).id == current.qfid
      var origin = win_getid()
      execute 'botright copen ' .. min([10, max([1, current.count])])
      win_gotoid(origin)
    endif
  endif
  if phase ==# 'failed'
    g:VimrcWarn('搜索失败: ' .. trim(current.stderr))
  elseif phase !=# 'cancelled'
    g:VimrcInfo(printf('搜索 %s: %d 行%s%s', phase, current.count,
      empty(current.reason) ? '' : ' (' .. current.reason .. ')',
      current.skipped > 0 ? printf('，跳过 %d 个非 UTF-8 结果', current.skipped) : ''))
  endif
  silent! doautocmd <nomodeline> User VimrcGrepComplete
enddef

def MaybeFinish(token: number)
  if token != sequence || !current.closed || !current.exited
    return
  endif
  # close_cb runs after all output callbacks; exit_cb alone can lose the last
  # batch of results from a fast process.
  if current.reason ==# 'invalid-output'
    Publish('failed')
  elseif current.reason ==# 'timeout'
    Publish('timeout')
  elseif !empty(current.reason)
    Publish('limited')
  elseif current.exit_code <= 1
    Publish('done')
  else
    Publish('failed')
  endif
enddef

def ReadRecord(record: string)
  if empty(record) || !empty(current.reason)
    return
  endif
  if strlen(record) > 1024 * 1024
    StopProcess('record-size-limit')
    return
  endif
  try
    var event = json_decode(record)
    if type(event) != v:t_dict || get(event, 'type', '') !=# 'match'
      return
    endif
    var data = event.data
    # rg represents invalid UTF-8 with a base64 `bytes` member. Skip it
    # explicitly instead of inventing an incorrect filename or jump offset.
    if !has_key(data.path, 'text') || !has_key(data.lines, 'text')
      current.skipped += 1
      return
    endif
    var path: string = data.path.text
    if path !~# '^/'
      path = current.root .. '/' .. path
    endif
    var first = get(data.submatches, 0, {start: 0})
    add(current.items, {
      filename: path, lnum: data.line_number, col: first.start + 1,
      text: strcharpart(substitute(data.lines.text, '[\r\n]\+$', '', ''), 0, 500),
    })
    current.count = len(current.items)
    if current.count >= current.limit
      StopProcess('result-limit')
    endif
  catch
    current.stderr = '无法解析 ripgrep JSON: ' .. v:exception
    StopProcess('invalid-output')
  endtry
enddef

def OnOutput(token: number, message: string)
  if token != sequence || !empty(current.reason)
    return
  endif
  current.bytes += strlen(message)
  if current.bytes > 16 * 1024 * 1024
    StopProcess('output-size-limit')
    return
  endif
  var records = split(current.pending .. message, "\n", true)
  current.pending = remove(records, -1)
  for record in records
    ReadRecord(record)
    if !empty(current.reason)
      break
    endif
  endfor
  if strlen(current.pending) > 1024 * 1024
    StopProcess('record-size-limit')
  endif
enddef

def OnClose(token: number)
  if token != sequence
    return
  endif
  if !empty(current.pending)
    ReadRecord(current.pending)
    current.pending = ''
  endif
  current.closed = true
  MaybeFinish(token)
enddef

def OnExit(token: number, status: number)
  if token != sequence
    return
  endif
  current.exit_code = status
  current.exited = true
  MaybeFinish(token)
enddef

def g:VimrcGrepStop()
  if get(current, 'phase', '') !=# 'running'
    return
  endif
  StopProcess('cancelled')
  # The old job can still deliver an exit/close callback after a new search.
  sequence += 1
  Publish('cancelled')
enddef

def g:VimrcGrep(pattern: string, literal: bool = false)
  if empty(pattern)
    g:VimrcWarn('请提供搜索内容')
    return
  endif
  if !executable('rg') || !has('job') || !has('channel')
    g:VimrcWarn('异步搜索需要 ripgrep (rg)、+job 和 +channel')
    return
  endif
  if bufname() =~# '^\a\+://' ||
        (exists('*g:SimpleRemoteIsVirtual') == 1 && g:SimpleRemoteIsVirtual())
    g:VimrcWarn('虚拟远端工作区请使用 :SimpleRemoteFind / SimpleFinder 搜索')
    return
  endif
  var root = g:VimrcProjectRoot()
  if !isdirectory(root)
    g:VimrcWarn('搜索目录不可用: ' .. root)
    return
  endif
  g:VimrcGrepStop()
  sequence += 1
  const token = sequence
  setqflist([], ' ', {title: 'grep: ' .. pattern, items: []})
  current = {
    phase: 'running', root: root, pattern: pattern, count: 0,
    limit: min([100000, Setting('vimrc_grep_max_results', 2000)]),
    items: [], pending: '', stderr: '', bytes: 0, skipped: 0,
    reason: '', closed: false, exited: false, exit_code: -1,
    qfid: getqflist({id: 0}).id, tab: tabpagenr(),
    timer: -1, job: v:null, started: reltime(),
  }
  g:vimrc_grep_state = current
  var argv = ['rg', '--no-config', '--json', '--smart-case', '--hidden',
    '--glob', '!.git/**', '--glob', '!.hg/**', '--glob', '!.svn/**',
    '--glob', '!node_modules/**', '--glob', '!target/**']
  if literal
    add(argv, '--fixed-strings')
  endif
  extend(argv, ['--', pattern, root])
  current.job = job_start(argv, {
    cwd: root, in_io: 'null', out_io: 'pipe', err_io: 'pipe',
    out_mode: 'raw', err_mode: 'raw',
    out_cb: (_, message) => OnOutput(token, message),
    err_cb: (_, message) => {
      if token == sequence
        current.stderr = strpart(current.stderr .. message, 0, 2048)
      endif
    },
    close_cb: (_) => OnClose(token),
    exit_cb: (_, status) => OnExit(token, status),
  })
  if type(current.job) != v:t_job || job_status(current.job) ==# 'fail'
    current.stderr = '无法启动 ripgrep'
    Publish('failed')
    return
  endif
  if current.phase !=# 'running'
    return
  endif
  current.timer = timer_start(Setting('vimrc_grep_timeout', 15000), (_) => {
    if token == sequence && current.phase ==# 'running'
      StopProcess('timeout')
    endif
  })
enddef

def g:VimrcGrepPrompt()
  var pattern = input('项目搜索: ')
  if !empty(pattern)
    g:VimrcGrep(pattern)
  endif
enddef

def g:VimrcGrepStatus()
  g:VimrcInfo(printf('搜索状态: %s，%d 行', current.phase, current.count))
enddef

command! -nargs=+ -bang VimrcGrep call g:VimrcGrep(<q-args>, <bang>0 ? true : false)
command! VimrcGrepWord call g:VimrcGrep(expand('<cword>'), true)
command! VimrcGrepStop call g:VimrcGrepStop()
command! VimrcGrepStatus call g:VimrcGrepStatus()

def g:VimrcConfigureSearch()
  g:VimrcGrepStop()
  augroup vimrc_search
    autocmd!
    autocmd VimLeavePre * call g:VimrcGrepStop()
  augroup END
enddef

g:VimrcConfigureSearch()
