vim9script

set nomore

def Status(): string
  return trim(execute('VimrcRemoteStatus'))
enddef

def WaitForStatus(expected: string, timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if Status() ==# expected
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

g:vimrc_remote_agent = '~/.cache/vimrc/agent dir/simpleremote-agent.sh'
execute 'VimrcRemoteConnect docker ' .. $VIMRC_TEST_REMOTE_TARGET .. ' '
      .. fnameescape($VIMRC_TEST_REMOTE_ROOT)
assert_true(WaitForStatus('docker:' .. $VIMRC_TEST_REMOTE_TARGET),
      'docker transport did not become ready')
assert_equal({kind: 'docker', target: $VIMRC_TEST_REMOTE_TARGET,
      root: $VIMRC_TEST_REMOTE_ROOT}, g:vimrc_remote_workspace)
VimrcRemoteDisconnect

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
