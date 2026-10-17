vim9script

set nomore

const ROOT = g:vimrc_root
const TMP = tempname()
const FIXTURE = TMP .. '/fixture'
const REPO = TMP .. '/configuration with spaces'
const BIN = TMP .. '/bin'
const SAVED_PATH = $PATH
const SAVED_FIXTURE = $VIMRC_UPDATE_FIXTURE
const SAVED_SKIP = $VIMRC_SKIP_UPDATE_CHECK
const SAVED_CONTEXT = deepcopy(g:vimrc_context)

def MakeFixture(path: string)
  mkdir(path, 'p')
  writefile(['success'], path .. '/fetch-mode')
  writefile(['success'], path .. '/pull-mode')
  writefile(['clean'], path .. '/status-mode')
  writefile([], path .. '/events')
enddef

def Mode(operation: string, value: string)
  writefile([value], FIXTURE .. '/' .. operation .. '-mode')
enddef

def Events(operation: string): list<string>
  return filter(readfile(FIXTURE .. '/events'), (_, line) =>
    stridx(line, operation .. "\t") == 0)
enddef

def WaitFor(Predicate: func(): bool, label: string, seconds = 3.0)
  var started = reltime()
  while !Predicate() && reltimefloat(reltime(started)) < seconds
    sleep 10m
  endwhile
  assert_true(Predicate(), 'timed out: ' .. label)
enddef

def TimerIds(): list<number>
  return map(timer_info(), (_, timer) => timer.id)
enddef

def AssertNoNewTimers(before: list<number>, label: string)
  sleep 20m
  assert_equal([], filter(TimerIds(), (_, id) => index(before, id) < 0), label)
enddef

def UpdateJob(operation: string): any
  for candidate in job_info()
    var command = get(job_info(candidate), 'cmd', [])
    if len(command) >= 4 && command[0] =~# '\(^\|/\)git$'
          && command[3] ==# operation && job_status(candidate) ==# 'run'
      return candidate
    endif
  endfor
  assert_report('no running update job: ' .. operation)
  return v:null
enddef

def ResetContext()
  g:vimrc_context = deepcopy(SAVED_CONTEXT)
  g:vimrc_context.root = REPO
  g:vimrc_context.vim_state = FIXTURE
  g:vimrc_update_check = 0
  $VIMRC_SKIP_UPDATE_CHECK = '1'
  g:VimrcConfigureUpdates()
enddef

def ProcessStopped(pid: number): bool
  system('kill -0 ' .. pid .. ' 2>/dev/null')
  if v:shell_error != 0
    return true
  endif
  # A terminated orphan can briefly remain a zombie until PID 1 reaps it.
  var stat_path = '/proc/' .. pid .. '/stat'
  return filereadable(stat_path) && join(readfile(stat_path), '') =~# ') Z '
enddef

def RunTests()
  ResetContext()
  g:vimrc_update_timeout = 80
  g:vimrc_update_pull_timeout = 80
  assert_equal(2, exists(':VimrcUpdateStop'))
  assert_equal(1, exists('#vimrc_update#VimLeavePre'))
  assert_equal(0, exists('#vimrc_update#VimEnter'))
  sleep 20m
  var timers_before = TimerIds()

  # Exercise the real job/channel path with bounded failure, then recovery.
  Mode('fetch', 'slow')
  g:vimrc_update_status = {}
  VimrcUpdateCheck
  var timed_fetch = UpdateJob('fetch')
  WaitFor(() => get(g:vimrc_update_status, 'error', '') ==# 'fetch-timeout',
    'fetch timeout')
  assert_equal('dead', job_status(timed_fetch))
  assert_true(filereadable(FIXTURE .. '/update-check'))
  AssertNoNewTimers(timers_before, 'fetch timeout leaked a timer')

  Mode('fetch', 'success')
  g:vimrc_update_timeout = 1000
  g:vimrc_update_status = {}
  VimrcUpdateCheck
  WaitFor(() => get(g:vimrc_update_status, 'behind', -1) == 2, 'successful fetch')
  assert_equal(1, get(g:vimrc_update_status, 'ahead', -1))
  assert_equal('origin/master', get(g:vimrc_update_status, 'upstream', ''))
  AssertNoNewTimers(timers_before, 'successful fetch leaked a timer')
  for event in Events('fetch')
    assert_match("\t0\tnever$", event, 'network jobs must disable auth prompts')
  endfor

  # An exited process can leave stderr open in a child. Its delayed data must
  # not contaminate the next operation's error message in the same controller.
  Mode('fetch', 'late-error')
  g:vimrc_update_status = {}
  VimrcUpdateCheck
  var retained_jobs = job_info()
  WaitFor(() => get(g:vimrc_update_status, 'error', '') ==# 'fetch-failed',
    'first failure before delayed stderr')
  Mode('fetch', 'delayed-failure')
  g:vimrc_update_status = {}
  VimrcUpdateCheck
  WaitFor(() => get(g:vimrc_update_status, 'error', '') ==# 'fetch-failed',
    'second failure after delayed stderr')
  var failure_messages = execute('messages')
  assert_match('CURRENT_NETWORK_ERROR', failure_messages)
  assert_notmatch('STALE_NETWORK_ERROR', failure_messages,
    'stderr from an earlier generation contaminated a later fetch')
  assert_false(empty(retained_jobs), 'first job must stay alive until its channel drains')
  AssertNoNewTimers(timers_before, 'failed fetch leaked a timer')

  # Fetch and pull share one operation slot, including the pre-pull status.
  Mode('fetch', 'slow')
  g:vimrc_update_timeout = 3000
  var fetch_count = len(Events('fetch'))
  var pull_count = len(Events('pull'))
  var status_count = len(Events('status'))
  VimrcUpdateCheck
  var cancelled_fetch = UpdateJob('fetch')
  WaitFor(() => len(Events('fetch')) > fetch_count, 'fetch started')
  VimrcUpdate
  VimrcUpdateCheck
  assert_equal(pull_count, len(Events('pull')), 'pull overlapped fetch')
  assert_equal(status_count, len(Events('status')), 'busy update ran git status')
  assert_equal(fetch_count + 1, len(Events('fetch')), 'duplicate fetch started')
  g:vimrc_update_status = {sentinel: 'cancelled'}
  VimrcUpdateStop
  WaitFor(() => job_status(cancelled_fetch) ==# 'dead', 'fetch cancellation')
  sleep 120m
  assert_equal({sentinel: 'cancelled'}, g:vimrc_update_status,
    'cancelled callback overwrote newer state')
  AssertNoNewTimers(timers_before, 'fetch cancellation leaked a timer')

  # A failed git status is not a clean checkout; dirty output also rejects pull.
  Mode('status', 'failure')
  assert_match('无法读取配置仓库状态', execute('VimrcUpdate'))
  assert_equal(pull_count, len(Events('pull')))
  Mode('status', 'dirty')
  assert_match('有未提交改动', execute('VimrcUpdate'))
  assert_equal(pull_count, len(Events('pull')))
  Mode('status', 'clean')

  Mode('pull', 'slow')
  g:vimrc_update_pull_timeout = 3000
  fetch_count = len(Events('fetch'))
  VimrcUpdate
  var cancelled_pull = UpdateJob('pull')
  WaitFor(() => len(Events('pull')) > pull_count, 'pull started')
  VimrcUpdateCheck
  VimrcUpdate
  assert_equal(fetch_count, len(Events('fetch')), 'fetch overlapped pull')
  assert_equal(pull_count + 1, len(Events('pull')), 'duplicate pull started')
  VimrcUpdateStop
  WaitFor(() => job_status(cancelled_pull) ==# 'dead', 'pull cancellation')
  AssertNoNewTimers(timers_before, 'pull cancellation leaked a timer')

  g:vimrc_update_pull_timeout = 80
  g:vimrc_update_status = {}
  VimrcUpdate
  var timed_pull = UpdateJob('pull')
  WaitFor(() => get(g:vimrc_update_status, 'error', '') ==# 'pull-timeout',
    'pull timeout')
  assert_equal('dead', job_status(timed_pull))
  AssertNoNewTimers(timers_before, 'pull timeout leaked a timer')
  Mode('pull', 'success')
  g:vimrc_update_pull_timeout = 1000
  g:vimrc_update_status = {}
  VimrcUpdate
  WaitFor(() => get(g:vimrc_update_status, 'behind', -1) == 2, 'successful pull')
  AssertNoNewTimers(timers_before, 'successful pull leaked a timer')

  # Re-source the whole configuration while the real fetch is running. Its
  # exit callback must remain valid and must not clobber the next operation.
  for reload_command in [
      'source ' .. fnameescape(ROOT .. '/.vimrc'),
      'VimrcReload',
    ]
    Mode('fetch', 'slow')
    g:vimrc_update_timeout = 3000
    VimrcUpdateCheck
    var reload_job = UpdateJob('fetch')
    execute reload_command
    execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
    WaitFor(() => job_status(reload_job) ==# 'dead', 'reload cancelled fetch')
    ResetContext()
    Mode('fetch', 'success')
    g:vimrc_update_status = {}
    VimrcUpdateCheck
    WaitFor(() => get(g:vimrc_update_status, 'behind', -1) == 2,
      'fetch after repeated source')
    assert_equal(1, count(execute('autocmd vimrc_update VimLeavePre'),
      'VimrcStopUpdateJobs'))
    AssertNoNewTimers(timers_before, 'reload leaked an update timer')
  endfor

  # Stop must cancel a pending startup timer as well as an active network job.
  delete(FIXTURE .. '/update-check')
  $VIMRC_SKIP_UPDATE_CHECK = '0'
  g:vimrc_update_check = 1
  g:vimrc_update_delay = 100
  g:VimrcConfigureUpdates()
  fetch_count = len(Events('fetch'))
  doautocmd vimrc_update VimEnter
  VimrcUpdateStop
  sleep 180m
  assert_equal(fetch_count, len(Events('fetch')), 'cancelled startup check ran')
  AssertNoNewTimers(timers_before, 'scheduled check leaked a timer')

  # A fresh stamp suppresses only automatic checks. Explicit checks still run.
  writefile([], FIXTURE .. '/update-check')
  g:VimrcConfigureUpdates()
  doautocmd vimrc_update VimEnter
  sleep 180m
  assert_equal(fetch_count, len(Events('fetch')), 'fresh stamp was ignored')
  Mode('fetch', 'success')
  VimrcUpdateCheck
  WaitFor(() => len(Events('fetch')) > fetch_count, 'forced check bypassed stamp')
  ResetContext()
  AssertNoNewTimers(timers_before, 'automatic check leaked a timer')

  # A real child Vim exits with a live update process and timeout timer. Probe
  # after the configured VimLeavePre handler, then ensure the process stopped.
  var nested = TMP .. '/nested'
  MakeFixture(nested)
  writefile(['slow'], nested .. '/fetch-mode')
  var driver = TMP .. '/exit-driver.vim'
  var report = nested .. '/exit-report'
  writefile([
    'vim9script',
    'set nomore',
    'g:vimrc_context.root = ' .. string(REPO),
    'g:vimrc_context.vim_state = ' .. string(nested),
    'g:vimrc_update_check = 0',
    'g:vimrc_update_timeout = 30000',
    'g:VimrcConfigureUpdates()',
    'VimrcUpdateCheck',
    'var started = reltime()',
    'while empty(readfile(' .. string(nested .. '/events') .. '))',
    '  if reltimefloat(reltime(started)) > 3.0 | cquit 2 | endif',
    '  sleep 10m',
    'endwhile',
    'autocmd VimLeavePre * call writefile([string(len(timer_info()))], ' .. string(report) .. ')',
    'qall!',
  ], driver)
  var child = job_start([v:progpath, '-Nu', ROOT .. '/.vimrc', '-n', '-i', 'NONE',
    '-es', '-S', driver], {
      in_io: 'null', out_io: 'null', err_io: 'file', err_name: nested .. '/stderr',
      env: {VIMRC_UPDATE_FIXTURE: nested, VIMRC_SKIP_UPDATE_CHECK: '1',
        VIMRC_SKIP_PLUGINS: '1'},
    })
  WaitFor(() => job_status(child) ==# 'dead', 'child Vim exit', 5.0)
  assert_equal(0, job_info(child).exitval, join(readfile(nested .. '/stderr'), '\n'))
  assert_true(filereadable(report), 'VimLeavePre probe did not run')
  if filereadable(report)
    assert_equal(['0'], readfile(report), 'VimLeavePre left a timer running')
  endif
  var child_events = readfile(nested .. '/events')
  assert_false(empty(child_events), 'child Vim never started fetch')
  if !empty(child_events)
    var process = str2nr(split(child_events[0], "\t")[1])
    WaitFor(() => ProcessStopped(process), 'update process survived Vim exit')
  endif
enddef

mkdir(REPO .. '/.git', 'p')
mkdir(BIN, 'p')
MakeFixture(FIXTURE)
writefile([
  '#!/bin/sh',
  'set -eu',
  '[ "$1" = -C ] || exit 90',
  'shift 2',
  'operation=$1',
  'printf "%s\t%s\t%s\t%s\n" "$operation" "$$" "${GIT_TERMINAL_PROMPT:-}" "${GCM_INTERACTIVE:-}" >>"$VIMRC_UPDATE_FIXTURE/events"',
  'case "$operation" in',
  '  fetch|pull)',
  '    case "$(cat "$VIMRC_UPDATE_FIXTURE/$operation-mode")" in',
  '      slow) exec sleep 30 ;;',
  '      failure) printf "fixture network failure\n" >&2; exit 12 ;;',
  '      delayed-failure) sleep 0.4; printf "CURRENT_NETWORK_ERROR\n" >&2; exit 12 ;;',
  '      late-error) (sleep 0.2; printf "STALE_NETWORK_ERROR\n" >&2) & exit 12 ;;',
  '      success) exit 0 ;;',
  '    esac ;;',
  '  status)',
  '    case "$(cat "$VIMRC_UPDATE_FIXTURE/status-mode")" in',
  '      failure) exit 13 ;;',
  '      dirty) printf " M local-file\n" ;;',
  '      clean) exit 0 ;;',
  '    esac ;;',
  '  rev-parse) printf "origin/master\n" ;;',
  '  rev-list) printf "1\t2\n" ;;',
  '  *) exit 91 ;;',
  'esac',
], BIN .. '/git')
setfperm(BIN .. '/git', 'rwx------')
$PATH = BIN .. ':' .. SAVED_PATH
$VIMRC_UPDATE_FIXTURE = FIXTURE
v:errmsg = ''

try
  RunTests()
  assert_equal('', v:errmsg, 'update callback raised an editor error')
catch
  assert_report(v:exception .. ' at ' .. v:throwpoint)
finally
  g:VimrcStopUpdateJobs()
  $PATH = SAVED_PATH
  $VIMRC_UPDATE_FIXTURE = SAVED_FIXTURE
  $VIMRC_SKIP_UPDATE_CHECK = SAVED_SKIP
  g:vimrc_context = SAVED_CONTEXT
  delete(TMP, 'rf')
endtry

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
