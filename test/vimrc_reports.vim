vim9script

set nomore

const ROOT = g:vimrc_root

def Run(command: string): string
  try
    execute command
  catch
    return v:exception
  endtry
  return ''
enddef

def Reports(name: string): list<dict<any>>
  return filter(getbufinfo(), (_, info) =>
    getbufvar(info.bufnr, 'vimrc_report_name', '') ==# name)
enddef

def CheckReport(name: string, title: string)
  assert_equal(name, get(b:, 'vimrc_report_name', ''))
  assert_match(title, getline(1))
  assert_equal('nofile', &buftype)
  assert_equal('wipe', &bufhidden)
  assert_false(&modifiable)
  assert_false(&modified)
  assert_false(&swapfile)
  assert_false(&buflisted)
  assert_false(&wrap)
  assert_equal('<Cmd>close<CR>', maparg('q', 'n'))
  assert_equal([], filter(getmatches(), (_, item) =>
    item.group ==# 'ExtraWhitespace'), 'report inherited editing highlights')
enddef

def CheckTimings(): list<string>
  assert_true(g:vimrc_load_ms > 0.0)
  assert_true(len(g:vimrc_load_timings) > 5)
  var modules: list<string> = []
  var sum = 0.0
  for entry in g:vimrc_load_timings
    assert_equal(v:t_string, type(entry.module))
    assert_equal(v:t_float, type(entry.ms))
    assert_true(entry.ms >= 0.0, entry.module)
    add(modules, entry.module)
    sum += entry.ms
  endfor
  assert_equal(len(modules), len(uniq(sort(copy(modules)))))
  for required in ['core.vim', 'behavior.vim', 'health.vim', 'workflow.vim',
    'search.vim', 'mappings.vim', 'update.vim']
    assert_true(index(modules, required) >= 0, required)
  endfor
  assert_true(sum <= g:vimrc_load_ms + 0.1,
    'module durations exceed the entire configuration load')
  return modules
enddef

assert_equal(2, exists(':VimrcHealth'))
assert_equal(2, exists(':VimrcProfile'))
assert_equal('<Cmd>VimrcHealth<CR>', maparg(g:mapleader .. 'vh', 'n'))
assert_equal('<Cmd>VimrcHealth!<CR>', maparg(g:mapleader .. 'vH', 'n'))
assert_equal('<Cmd>VimrcProfile<CR>', maparg(g:mapleader .. 'vp', 'n'))
assert_equal('<Cmd>VimrcUpdateStop<CR>', maparg(g:mapleader .. 'vs', 'n'))
assert_equal('<Cmd>VimrcLargeFile<CR>', maparg(g:mapleader .. 'vl', 'n'))
assert_equal('<Cmd>VimrcGrepWord<CR>', maparg(g:mapleader .. 'sw', 'n'))
assert_equal('<Cmd>VimrcGrepStop<CR>', maparg(g:mapleader .. 'sx', 'n'))
var original_modules = CheckTimings()

# Native Vim9 booleans are valid in user overrides, just like numeric 0/1.
# Diagnostic flags and the plugin skip switch must not compare bool to number.
var old_flags = {
  editorconfig: g:simpleeditorconfig_enable,
  yank: g:simpleedit_yank_highlight,
  install: g:simplecc_auto_install,
}
var skip_existed = exists('g:vimrc_skip_plugins') == 1
var old_skip = get(g:, 'vimrc_skip_plugins', 0)
for enabled in [false, true]
  g:simpleeditorconfig_enable = enabled
  g:simpleedit_yank_highlight = enabled
  g:simplecc_auto_install = enabled
  assert_equal('', Run('VimrcHealth'), 'boolean diagnostic options')
  g:vimrc_skip_plugins = enabled
  assert_equal('', Run('source ' .. fnameescape(ROOT .. '/.vimrc')),
    'boolean plugin skip option')
  assert_equal(original_modules, CheckTimings())
endfor
g:simpleeditorconfig_enable = old_flags.editorconfig
g:simpleedit_yank_highlight = old_flags.yank
g:simplecc_auto_install = old_flags.install
if skip_existed
  g:vimrc_skip_plugins = old_skip
else
  unlet g:vimrc_skip_plugins
endif
assert_equal('', Run('source ' .. fnameescape(ROOT .. '/.vimrc')))

# The original echo API remains usable in scripts, with no window or buffer
# transition and no changes to the user's unsaved text or unnamed register.
enew!
setlocal filetype=text
setline(1, ['user edit that must survive', 'another line '])
setreg('"', 'original yank')
var user_buffer = bufnr()
var user_window = win_getid()
var user_lines = getline(1, '$')
var window_count = len(getwininfo())
var output = execute('VimrcHealth')
assert_match('vimrc health —', output)
assert_match('config load', output)
assert_match('vimrc health: \d\+ failure(s), \d\+ warning(s)', output)
assert_equal(0, g:vimrc_health_last.fail)
assert_true(g:vimrc_health_last.warn >= 0)
assert_equal(user_buffer, bufnr())
assert_equal(user_window, win_getid())
assert_equal(window_count, len(getwininfo()))
assert_equal(user_lines, getline(1, '$'))
assert_true(&modified)

# Bang creates a readable, disposable report; repeating it refreshes the same
# report window, including when invoked from a different editing window.
assert_equal('', Run('VimrcHealth!'))
CheckReport('[vimrc-health]', 'Vimrc health report')
assert_match('vimrc health:', join(getline(1, '$'), "\n"))
var health_buffer = bufnr()
var health_window = win_getid()
assert_equal(window_count + 1, len(getwininfo()))
assert_equal(user_lines, getbufline(user_buffer, 1, '$'))
assert_true(getbufvar(user_buffer, '&modified'))
assert_equal('original yank', getreg('"'))
assert_equal('', Run('VimrcHealth!'))
assert_equal(health_buffer, bufnr())
assert_equal(health_window, win_getid())
assert_equal(1, len(Reports('[vimrc-health]')))
assert_equal(window_count + 1, len(getwininfo()))
win_gotoid(user_window)
assert_equal('', Run('VimrcHealth!'))
assert_equal(health_buffer, bufnr())
assert_equal(health_window, win_getid())

# Module rows expose real timing values; rendering a sorted report must not
# reorder the recorded module execution history used by later diagnostics.
win_gotoid(user_window)
assert_equal('', Run('VimrcProfile'))
CheckReport('[vimrc-profile]', 'Vimrc load profile')
var profile_buffer = bufnr()
var profile_window = win_getid()
var profile_lines = getline(1, '$')
assert_match('Last configuration load: ', join(profile_lines, "\n"))
assert_match('excludes later plugin jobs and Vim startup', join(profile_lines, "\n"))
for module in original_modules
  assert_true(len(filter(copy(profile_lines), (_, value) =>
    stridx(value, module) == 0)) == 1, module)
endfor
assert_equal(original_modules, mapnew(g:vimrc_load_timings, (_, value) => value.module))
assert_equal('', Run('VimrcProfile'))
assert_equal(profile_buffer, bufnr())
assert_equal(profile_window, win_getid())
assert_equal(1, len(Reports('[vimrc-profile]')))
assert_equal(window_count + 2, len(getwininfo()))

# A reload must rebuild timings instead of appending to, or rendering, a
# stale snapshot. It must leave an already-open report safe to refresh.
g:vimrc_load_timings = [{module: 'stale-test-entry', ms: 99999.0}]
g:vimrc_load_ms = 99999.0
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal(original_modules, CheckTimings())
assert_equal('', Run('VimrcProfile'))
assert_equal(profile_buffer, bufnr())
assert_notmatch('stale-test-entry', join(getline(1, '$'), "\n"))
CheckReport('[vimrc-profile]', 'Vimrc load profile')
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal(original_modules, CheckTimings())

# The report's q binding wipes only that scratch buffer, preserving the
# original editing window and its unsaved contents.
normal q
assert_false(bufexists(profile_buffer))
win_gotoid(health_window)
normal q
assert_false(bufexists(health_buffer))
assert_equal(user_window, win_getid())
assert_equal(user_lines, getline(1, '$'))
assert_true(&modified)
assert_equal('original yank', getreg('"'))

# A real user buffer may legitimately have the report's display name. It is
# identified as a report only by its ownership tag, never by that name alone.
for [name, command] in [['[vimrc-health]', 'VimrcHealth!'],
  ['[vimrc-profile]', 'VimrcProfile']]
  botright new
  execute 'file ' .. fnameescape(name)
  setline(1, 'user document named ' .. name)
  var collision_buffer = bufnr()
  var collision_window = win_getid()
  var collision_text = getline(1)
  var error = Run(command)
  assert_equal('', error, 'report display-name collision: ' .. name)
  assert_equal([collision_text], getbufline(collision_buffer, 1, '$'))
  assert_true(getbufvar(collision_buffer, '&modified'))
  assert_equal('', getbufvar(collision_buffer, 'vimrc_report_name', ''))
  if empty(error)
    assert_notequal(collision_buffer, bufnr())
    assert_equal(name, get(b:, 'vimrc_report_name', ''))
    normal q
  endif
  win_gotoid(collision_window)
  close!
endfor

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
