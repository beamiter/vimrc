vim9script

set nomore
const ROOT = g:vimrc_root
const FIXTURE = tempname()
const PROJECT = FIXTURE .. '/project with spaces:colon'
mkdir(PROJECT .. '/.git', 'p')
mkdir(PROJECT .. '/src with spaces', 'p')

const SOURCE = PROJECT .. '/src with spaces/sample:notes.txt'
writefile([
  'literal: a.b',
  'regexp: aXb',
  '中文 café needle',
  'marker!',
  '--dash $(echo SHELL_LITERAL)',
], SOURCE)
writefile(['HIDDEN_MARKER'], PROJECT .. '/.hidden.txt')
writefile(['IGNORED_MARKER'], PROJECT .. '/ignored.txt')
writefile(['ignored.txt'], PROJECT .. '/.gitignore')
for dir in ['.git', '.hg', '.svn', 'node_modules', 'target']
  mkdir(PROJECT .. '/' .. dir, 'p')
  writefile(['EXCLUDED_MARKER'], PROJECT .. '/' .. dir .. '/excluded.txt')
endfor

execute 'edit ' .. fnameescape(SOURCE)
const ORIGIN = win_getid()
const CWD = getcwd()
const REAL_PATH = $PATH
const RG_CONFIG = $RIPGREP_CONFIG_PATH
const OLD_SETTINGS = {
  max_results: g:vimrc_grep_max_results,
  timeout: g:vimrc_grep_timeout,
  open: g:vimrc_grep_open,
}
g:vimrc_grep_timeout = 10000

def WaitForSearch()
  for attempt in range(1, 1000)
    if get(g:vimrc_grep_state, 'phase', '') !=# 'running'
      return
    endif
    sleep 10m
  endfor
  assert_report('asynchronous search did not finish within 10 seconds')
  g:VimrcGrepStop()
enddef

def Results(id: number = get(g:vimrc_grep_state, 'qfid', 0)): list<dict<any>>
  return getqflist({id: id, items: 0}).items
enddef

def Search(pattern: string, literal: bool = false): dict<any>
  silent! cclose
  g:VimrcGrep(pattern, literal)
  WaitForSearch()
  return g:vimrc_grep_state
enddef

assert_equal(2, exists(':VimrcGrep'))
assert_equal(2, exists(':VimrcGrepWord'))
assert_equal(2, exists(':VimrcGrepStop'))
assert_equal(2, exists(':VimrcGrepStatus'))
assert_true(executable('rg'), 'the search regression suite requires real ripgrep')

# JSON preserves literal filenames (including colons/spaces) and UTF-8 byte
# columns. ripgrep configuration outside the repository must not alter results.
writefile(['--glob', '!**'], FIXTURE .. '/ripgreprc')
$RIPGREP_CONFIG_PATH = FIXTURE .. '/ripgreprc'
var state = Search('needle')
assert_equal('done', state.phase)
assert_equal(PROJECT, state.root)
assert_equal(1, state.count)
var result = Results()[0]
assert_equal(SOURCE, fnamemodify(bufname(result.bufnr), ':p'))
assert_equal(3, result.lnum)
assert_equal(strlen('中文 café ') + 1, result.col)
assert_equal('中文 café needle', result.text)
assert_equal(ORIGIN, win_getid(), 'background completion stole editing focus')
assert_equal(CWD, getcwd(), 'search changed the user working directory')
assert_true(getqflist({winid: 0}).winid > 0)
assert_equal(1, getwininfo(getqflist({winid: 0}).winid)[0].height)
var context = getqflist({id: state.qfid, context: 0}).context
assert_equal('grep', context.vimrc)
assert_equal(PROJECT, context.root)
assert_equal('done', context.phase)

silent! cclose
VimrcGrep a.b
WaitForSearch()
assert_equal(2, g:vimrc_grep_state.count, 'regular expressions must remain enabled by default')
VimrcGrep! a.b
WaitForSearch()
assert_equal(1, g:vimrc_grep_state.count, 'bang must select fixed-string search')
assert_equal('literal: a.b', Results()[0].text)
VimrcGrep! marker!
WaitForSearch()
assert_equal(1, g:vimrc_grep_state.count, 'literal bang was consumed by Ex parsing')
state = Search('--dash $(echo SHELL_LITERAL)', true)
assert_equal(1, state.count, 'leading dashes and shell punctuation were not literal argv')
assert_equal('--dash $(echo SHELL_LITERAL)', Results()[0].text)

cursor(3, strlen('中文 café ') + 1)
VimrcGrepWord
WaitForSearch()
assert_equal('needle', g:vimrc_grep_state.pattern)
assert_equal(1, g:vimrc_grep_state.count)
assert_equal(1, Search('HIDDEN_MARKER').count)
assert_equal(0, Search('IGNORED_MARKER').count)
assert_equal(0, Search('EXCLUDED_MARKER').count)

# Preview clipping must not leave half a Chinese character in quickfix text.
var unicode_line = repeat('x', 499) .. '中文 UNICODE_PREVIEW'
writefile([unicode_line], PROJECT .. '/unicode-preview.txt')
state = Search('UNICODE_PREVIEW')
assert_equal(1, state.count)
assert_equal(repeat('x', 499) .. '中', Results()[0].text)
assert_equal(500, strchars(Results()[0].text))

# A later compiler/LSP list owns focus and the current history position.  The
# search still updates only its own captured quickfix list id in the background.
silent! cclose
g:VimrcGrep('needle')
var owned_id = g:vimrc_grep_state.qfid
setqflist([], ' ', {title: 'compiler owns this list', items: [
  {filename: SOURCE, lnum: 2, text: 'compiler result'},
]})
var compiler_id = getqflist({id: 0}).id
WaitForSearch()
assert_equal('done', g:vimrc_grep_state.phase)
assert_equal(compiler_id, getqflist({id: 0}).id)
assert_equal('compiler owns this list', getqflist({title: 0}).title)
assert_equal('compiler result', getqflist()[0].text)
assert_equal(1, len(Results(owned_id)))
assert_equal(0, getqflist({winid: 0}).winid)
assert_equal(ORIGIN, win_getid())

# Removing search history while rg is running must not recreate/free another
# producer's list, throw an error, or open a new window on completion.
g:VimrcGrep('needle')
setqflist([], 'f')
WaitForSearch()
assert_equal('done', g:vimrc_grep_state.phase)
assert_equal(0, getqflist({winid: 0}).winid)

# A completion in another tab should never pop a results window into that tab.
g:VimrcGrep('needle')
tabnew
var other_tab = tabpagenr()
var other_win = win_getid()
WaitForSearch()
assert_equal(other_tab, tabpagenr())
assert_equal(other_win, win_getid())
assert_equal(0, getqflist({winid: 0}).winid)
tabclose!
assert_equal(ORIGIN, win_getid())

# rg exit 1 means a successful zero-result search; invalid regex exits 2.
state = Search('THIS_PATTERN_DOES_NOT_EXIST')
assert_equal('done', state.phase)
assert_equal(0, state.count)
assert_equal(1, state.exit_code)
assert_equal([], Results())
assert_equal(0, getqflist({winid: 0}).winid)
state = Search('[')
assert_equal('failed', state.phase)
assert_equal(2, state.exit_code)
assert_match('regex parse error', state.stderr)
assert_equal(ORIGIN, win_getid())
var previous_id = state.qfid
assert_match('请提供', execute("call g:VimrcGrep('')"))
assert_equal(previous_id, g:vimrc_grep_state.qfid, 'empty input should not replace results')

# Result and transport limits bound memory separately. Real rg exercises both
# complete JSON records and records delivered in multiple raw channel chunks.
writefile(repeat(['CAP_MARKER'], 100), PROJECT .. '/many-results.txt')
g:vimrc_grep_max_results = 3
state = Search('CAP_MARKER')
assert_equal('limited', state.phase)
assert_equal('result-limit', state.reason)
assert_equal(3, state.count)
assert_equal(3, len(Results()))
g:vimrc_grep_max_results = 100000

writefile(['OVERSIZED:' .. repeat('x', 1100000)], PROJECT .. '/oversized.txt')
state = Search('OVERSIZED:')
assert_equal('limited', state.phase)
assert_equal('record-size-limit', state.reason)
assert_equal(0, state.count)
assert_equal('', state.pending)
delete(PROJECT .. '/oversized.txt')

writefile(repeat(['STREAM:' .. repeat('s', 3000)], 6000), PROJECT .. '/stream.txt')
state = Search('STREAM:')
assert_equal('limited', state.phase)
assert_equal('output-size-limit', state.reason)
assert_true(state.count < 6000)
assert_true(state.count > 0)
assert_equal('', state.pending)
delete(PROJECT .. '/stream.txt')

# A tiny controlled rg stand-in makes cancellation, timeout and malformed
# output deterministic without relying on machine speed or network access.
mkdir(FIXTURE .. '/bin', 'p')
writefile([
  '#!/bin/sh',
  'case "${VIMRC_RG_FIXTURE:-slow}" in',
  '  malformed) echo ''{'' ;;',
  '  stderr)',
  '    printf ''fixture error: '' >&2',
  '    printf ''%05000d\n'' 0 >&2',
  '    exit 2 ;;',
  '  *)',
  '    echo ''{"type":"begin","data":{}}''',
  '    exec sleep 30 ;;',
  'esac',
], FIXTURE .. '/bin/rg')
setfperm(FIXTURE .. '/bin/rg', 'rwx------')
$PATH = FIXTURE .. '/bin:' .. REAL_PATH
$VIMRC_RG_FIXTURE = 'malformed'
state = Search('fixture')
assert_equal('failed', state.phase)
assert_equal('invalid-output', state.reason)
assert_match('无法解析', state.stderr)

$VIMRC_RG_FIXTURE = 'stderr'
state = Search('fixture')
assert_equal('failed', state.phase)
assert_equal(2, state.exit_code)
assert_match('fixture error:', state.stderr)
assert_true(strlen(state.stderr) <= 2048)

$VIMRC_RG_FIXTURE = 'slow'
g:vimrc_grep_timeout = 30
state = Search('fixture')
assert_equal('timeout', state.phase)
assert_equal('timeout', state.reason)
assert_equal(-1, state.timer)
g:vimrc_grep_timeout = 10000

# Replacing a request immediately, or sourcing the public vimrc repeatedly
# while callbacks are pending, cannot let an old callback overwrite new state.
g:VimrcGrep('old request')
assert_equal('running', g:vimrc_grep_state.phase)
var old_job = g:vimrc_grep_state.job
VimrcGrepStop
assert_equal('cancelled', g:vimrc_grep_state.phase)
assert_equal('cancelled', g:vimrc_grep_state.reason)
assert_equal(-1, g:vimrc_grep_state.timer)
$PATH = REAL_PATH
state = Search('needle')
assert_equal('done', state.phase)
assert_equal('needle', state.pattern)
assert_equal(1, state.count)
sleep 100m
assert_notequal('run', job_status(old_job))
assert_equal('needle', g:vimrc_grep_state.pattern)
assert_equal('done', g:vimrc_grep_state.phase)

$PATH = FIXTURE .. '/bin:' .. REAL_PATH
g:VimrcGrep('reload request')
old_job = g:vimrc_grep_state.job
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal('cancelled', g:vimrc_grep_state.phase)
sleep 100m
assert_notequal('run', job_status(old_job))
assert_equal(1, len(filter(autocmd_get({group: 'vimrc_search'}),
  (_, item) => item.event ==# 'VimLeavePre')))
for message in split(execute('messages'), "\n")
  assert_notmatch('E117:.*Unknown function', message)
  assert_notmatch('E933:.*deleted', message)
  assert_notmatch('E932:.*removed', message)
endfor
$PATH = REAL_PATH
state = Search('needle')
assert_equal('done', state.phase)
assert_equal(1, state.count)
assert_match('done', execute('VimrcGrepStatus'))
VimrcGrepStop
assert_equal('done', g:vimrc_grep_state.phase, 'stopping an idle search changed its state')

# Core-only search remains isolated from virtual remote buffers.
enew!
execute 'file remote://fixture/project/file.py'
setlocal buftype=acwrite
assert_match('远端', execute("call g:VimrcGrep('needle')"))
assert_equal('needle', g:vimrc_grep_state.pattern)
assert_equal('done', g:vimrc_grep_state.phase)

$PATH = REAL_PATH
$RIPGREP_CONFIG_PATH = RG_CONFIG
unlet $VIMRC_RG_FIXTURE
g:vimrc_grep_max_results = OLD_SETTINGS.max_results
g:vimrc_grep_timeout = OLD_SETTINGS.timeout
g:vimrc_grep_open = OLD_SETTINGS.open
g:VimrcGrepStop()
silent! cclose
enew!
delete(FIXTURE, 'rf')
if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
