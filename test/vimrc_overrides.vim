vim9script

set nomore

assert_equal(';', g:mapleader)
assert_equal('<Cmd>update<CR>', maparg(';fs', 'n'))
assert_equal('', maparg('<Space>fs', 'n'))
assert_equal(0, get(g:, 'vimrc_editorconfig', -1))
assert_equal('before-loaded', get(g:, 'vimrc_before_test', ''))
assert_equal('after-loaded', get(g:, 'vimrc_after_test', ''))
assert_equal(g:vimrc_root, get(g:, 'vimrc_before_root', ''))
assert_match('/.vimrc.before$', g:vimrc_context.local_before)
assert_match('/.vimrc.local$', g:vimrc_context.local_after)

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
