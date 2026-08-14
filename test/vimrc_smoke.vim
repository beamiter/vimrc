vim9script

set nomore

const ROOT = g:vimrc_root
var temp_files: list<string> = []

def EditTemp(name: string, lines: list<string>)
  var dir = tempname()
  mkdir(dir, 'p')
  var path = dir .. '/' .. name
  writefile(lines, path)
  add(temp_files, path)
  add(temp_files, dir)
  execute 'edit ' .. fnameescape(path)
enddef

assert_true(v:version >= 900)
assert_equal(0, get(g:, 'vimrc_plugins_ready', -1))
assert_equal(' ', g:mapleader)
assert_equal(',', g:maplocalleader)

assert_true(&undofile)
assert_true(&swapfile)
assert_true(&writebackup)
assert_false(&backup)
assert_match('/vim/undo//$', &undodir)
assert_match('/vim/swap//$', &directory)
assert_match('/vim/viminfo$', &viminfofile)
assert_equal(2, exists(':VimrcHealth'))
assert_equal(2, exists(':StripWhitespace'))
assert_equal(2, exists(':VimrcUpdate'))
assert_equal(2, exists(':VimrcUpdateCheck'))
assert_equal(2, exists(':VimrcReload'))
assert_equal(2, exists(':VimrcBootstrapStatus'))
assert_equal(2, exists(':VimrcBootstrapRetry'))
assert_equal(2, exists(':VimrcBootstrapStop'))
assert_equal(2, exists(':VimrcRoot'))
assert_equal(2, exists(':VimrcLargeFile'))
assert_equal(2, exists(':QFToggle'))
assert_equal(2, exists(':LLToggle'))
# Remote commands are provided by the external simpleremote plugin.
assert_equal(0, exists(':VimrcRemoteConnect'))
assert_equal(0, exists(':VimrcRemoteDisconnect'))
assert_equal(0, exists(':VimrcRemoteOpen'))
assert_equal(0, exists(':VimrcRemoteStatus'))
# VIMRC_SKIP_UPDATE_CHECK=1 必须让启动检查完全不注册，测试不联网。
assert_equal(0, g:vimrc_update_check)
assert_equal(0, exists('#vimrc_update#VimEnter'))
assert_equal(0, exists('#vimrc_simpleplug_bootstrap#VimEnter'))
assert_equal(ROOT .. '/simplecc.json', g:simplecc_config_path)
assert_false(&modeline)
assert_false(&exrc)
assert_match('block', &virtualedit)

# The plugin manifest is intentionally closed over beamiter/simple*: adding a
# third-party Plug declaration must fail even though this smoke runs core-only.
for declaration in readfile(ROOT .. '/config/plugins.vim')
  if stridx(declaration, "simpleplug#Plug('") >= 0
    assert_match("simpleplug#Plug('beamiter/simple", declaration,
      'non-simple plugin declaration: ' .. trim(declaration))
  endif
endfor

colorscheme habamax
assert_notmatch('cleared', execute('highlight ExtraWhitespace'))

# Native editing motions must remain native.
assert_equal('', maparg('s', 'n'))
assert_equal('', maparg('(', 'n'))
assert_equal('', maparg(')', 'n'))
assert_equal('<Cmd>update<CR>', maparg('<Space>fs', 'n'))
assert_equal('<Cmd>VimrcHealth<CR>', maparg('<Space>vh', 'n'))
assert_equal('<Cmd>VimrcUpdateCheck<CR>', maparg('<Space>vc', 'n'))
assert_equal('<Cmd>VimrcUpdate<CR>', maparg('<Space>vu', 'n'))
assert_equal('<Cmd>VimrcRoot<CR>', maparg('<Space>fd', 'n'))
assert_equal('<Cmd>SimpleRemoteDisconnect<CR>', maparg('<Space>rd', 'n'))
assert_equal('<Cmd>call g:VimrcRemotePromptFind()<CR>', maparg('<Space>rf', 'n'))
assert_equal('<Cmd>SimpleRemoteGit status --short<CR>', maparg('<Space>rg', 'n'))
assert_equal('<Cmd>SimpleRemoteHealth<CR>', maparg('<Space>rh', 'n'))
assert_equal('<Cmd>SimpleRemoteStatus<CR>', maparg('<Space>rs', 'n'))
assert_equal('<Cmd>SimpleRemoteTree<CR>', maparg('<Space>rt', 'n'))
assert_equal('<Cmd>QFToggle<CR>', maparg('<Space>qq', 'n'))
assert_equal('', maparg(',1', 'x'))
assert_equal('', maparg(',1', 'o'))

execute 'edit ' .. fnameescape(ROOT .. '/simplecc.json')
assert_equal('json', &filetype)
assert_equal(2, &shiftwidth)
assert_equal(2, &tabstop)
assert_equal(0, &conceallevel)

execute 'edit ' .. fnameescape(ROOT .. '/README.org')
assert_equal('org', &filetype)
assert_true(&linebreak)
assert_true(&breakindent)

execute 'edit ' .. fnameescape(ROOT .. '/tunel1.sh')
assert_equal('sh', &filetype)
assert_equal(2, &shiftwidth)
assert_equal(0, &conceallevel)
assert_false(&linebreak)

execute 'edit ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal('vim', &filetype)
assert_equal(2, &shiftwidth)
assert_false(&linebreak)

EditTemp('Makefile', ['all:', "\t@true"])
assert_equal('make', &filetype)
assert_false(&expandtab)
assert_equal(8, &tabstop)

EditTemp('sample.py', ['def answer():', '    return 42'])
assert_equal('python', &filetype)
assert_true(&expandtab)
assert_equal(4, &shiftwidth)

EditTemp('sample.go', ['package main', '', 'func main() {}'])
assert_equal('go', &filetype)
assert_false(&expandtab)
assert_equal(4, &shiftwidth)
assert_equal(0, &softtabstop)

# Project root discovery is marker-based and :VimrcRoot changes only the
# current window's directory.
var project = tempname()
mkdir(project .. '/.git', 'p')
mkdir(project .. '/src/deep', 'p')
var editorconfig_file = project .. '/.editorconfig'
writefile(['root = true', '', '[*]', 'indent_style = space', 'indent_size = 3'],
  editorconfig_file)
var project_file = project .. '/src/deep/main.rs'
writefile(['fn main() {}'], project_file)
add(temp_files, project_file)
add(temp_files, editorconfig_file)
add(temp_files, project .. '/src/deep')
add(temp_files, project .. '/src')
add(temp_files, project .. '/.git')
add(temp_files, project)
execute 'edit ' .. fnameescape(project_file)
assert_equal(project, g:VimrcProjectRoot())
if exists(':SimpleEditorConfigReload') == 2
  assert_equal(3, &l:shiftwidth)
endif
var old_cwd = getcwd()
g:VimrcCdRoot()
assert_equal(project, getcwd())
execute 'lcd ' .. fnameescape(old_cwd)

# Large-file mode is buffer-local and can be tested with a tiny threshold.
var old_threshold = g:vimrc_large_file_bytes
g:vimrc_large_file_bytes = 32
EditTemp('large.txt', [repeat('x', 80)])
assert_equal(1, get(b:, 'vimrc_large_file', 0))
assert_equal(1, get(b:, 'simpletreesitter_disable', 0))
assert_false(&l:undofile)
assert_false(&l:swapfile)
assert_equal(100, &l:undolevels)
assert_equal('OFF', &l:syntax)
assert_match('^BIG ', g:VimrcLargeFileStatusline())
g:VimrcLargeFileStatus()
g:vimrc_large_file_bytes = old_threshold

# Quickfix toggle opens an existing list and closes the same window again.
setqflist([{filename: ROOT .. '/.vimrc', lnum: 1, text: 'smoke'}])
QFToggle
assert_true(getqflist({winid: 0}).winid > 0)
QFToggle
assert_equal(0, getqflist({winid: 0}).winid)
setqflist([])

setloclist(0, [{filename: ROOT .. '/.vimrc', lnum: 1, text: 'smoke'}])
LLToggle
assert_true(getloclist(0, {winid: 0}).winid > 0)
LLToggle
assert_equal(0, getloclist(0, {winid: 0}).winid)
setloclist(0, [])

enew!
setline(1, ['alpha  ', 'beta'])
g:VimrcStripWhitespace()
assert_equal(['alpha', 'beta'], getline(1, '$'))

# statusline 段位只读缓存的状态，落后时才渲染。
g:vimrc_update_status = {}
assert_equal('', g:VimrcUpdateStatusline())
g:vimrc_update_status = {behind: 0, ahead: 2}
assert_equal('', g:VimrcUpdateStatusline())
g:vimrc_update_status = {behind: 'many'}
assert_equal('', g:VimrcUpdateStatusline())
g:vimrc_update_status = 'not-a-dict'
assert_equal('', g:VimrcUpdateStatusline())
g:vimrc_update_status = {behind: 3}
assert_match('3$', g:VimrcUpdateStatusline())
g:vimrc_update_status = {}

# The synchronous Git helper must use systemlist()'s string-command API.  An
# untracked marker makes :VimrcUpdate stop before its networked pull while
# still exercising `git status` through that helper.
var update_marker = ROOT .. '/.vimrc-update-smoke-' .. getpid()
writefile(['smoke'], update_marker)
add(temp_files, update_marker)
assert_match('有未提交改动', execute('VimrcUpdate'))

# Reloading must be idempotent: no duplicate commands, functions or autocmds.
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
var ft_autocmds = execute('autocmd vimrc_core FileType')
assert_equal(1, count(ft_autocmds, 'VimrcConfigureFiletype'))
# 重复 source 不得堆积 statusline 段位。
assert_equal(1, len(filter(
  copy(g:simpleline_custom_right),
  (_, value) => get(value, 'fn', '') ==# 'g:VimrcUpdateStatusline')))
assert_equal(1, len(filter(
  copy(g:simpleline_custom_right),
  (_, value) => get(value, 'fn', '') ==# 'g:VimrcLargeFileStatusline')))

g:VimrcHealth()
assert_equal(0, get(get(g:, 'vimrc_health_last', {}), 'fail', -1))

for path in reverse(temp_files)
  if isdirectory(path)
    delete(path, 'rf')
  else
    delete(path)
  endif
endfor

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
