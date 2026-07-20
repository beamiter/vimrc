vim9script

set nomore

# State creation was deliberately pointed below a regular file.  Recovery
# features must fail closed instead of writing beside edited source files.
assert_false(&undofile)
assert_false(&swapfile)
assert_false(&backup)
assert_false(&writebackup)
assert_equal('NONE', &viminfofile)
assert_equal(2, exists(':VimrcHealth'))

# The module's own fail-closed NONE is not confused with `vim -i NONE`; it can
# recover after the state path becomes writable in the same session.
mkdir($VIMRC_RECOVERY_STATE, 'p')
$XDG_STATE_HOME = $VIMRC_RECOVERY_STATE
execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
assert_true(&undofile)
assert_true(&swapfile)
assert_true(&writebackup)
assert_match('/vim/viminfo$', &viminfofile)

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
