vim9script

set nomore

const HOME_DIR = substitute(
      resolve(fnamemodify($HOME, ':p')),
      '[\/\\]\+$',
      '',
      '')
assert_equal(HOME_DIR .. '/.local/state', g:vimrc_context.state_home)
assert_equal(HOME_DIR .. '/.config', g:vimrc_context.config_home)
assert_equal(HOME_DIR .. '/.vim/plugged', g:vimrc_context.plugin_home)

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
