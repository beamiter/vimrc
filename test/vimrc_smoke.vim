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
assert_equal(ROOT .. '/simplecc.json', g:simplecc_config_path)

colorscheme habamax
assert_notmatch('cleared', execute('highlight ExtraWhitespace'))

# Native editing motions must remain native.
assert_equal('', maparg('s', 'n'))
assert_equal('', maparg('(', 'n'))
assert_equal('', maparg(')', 'n'))
assert_equal('<Cmd>update<CR>', maparg('<Space>fs', 'n'))
assert_equal('<Cmd>VimrcHealth<CR>', maparg('<Space>vh', 'n'))
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

enew!
setline(1, ['alpha  ', 'beta'])
g:VimrcStripWhitespace()
assert_equal(['alpha', 'beta'], getline(1, '$'))

# Reloading must be idempotent: no duplicate commands, functions or autocmds.
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
execute 'source ' .. fnameescape(ROOT .. '/.vimrc')
var ft_autocmds = execute('autocmd vimrc_core FileType')
assert_equal(1, count(ft_autocmds, 'VimrcConfigureFiletype'))

g:VimrcHealth()
assert_equal(0, get(get(g:, 'vimrc_health_last', {}), 'fail', -1))

for path in reverse(temp_files)
  if isdirectory(path)
    delete(path, 'd')
  else
    delete(path)
  endif
endfor

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
