vim9script

set nomore

assert_false(g:VimrcSimplePlugReady())
assert_equal('scheduled', g:vimrc_simpleplug_bootstrap_state.phase)

# Ex mode does not emit VimEnter automatically; reproduce a normal launch and
# keep servicing jobs/timers until the entire bootstrap -> update -> reload
# chain reports ready.
execute 'edit ' .. fnameescape(g:vimrc_root .. '/.vimrc')
doautocmd VimEnter
var started = reltime()
while get(g:vimrc_simpleplug_bootstrap_state, 'phase', '') !=# 'ready'
      && reltimefloat(reltime(started)) < 8.0
  sleep 20m
endwhile

assert_equal('ready', g:vimrc_simpleplug_bootstrap_state.phase)
assert_true(g:VimrcSimplePlugReady())
assert_equal(1, get(g:, 'vimrc_test_plugupdate_count', 0))
assert_equal(1, get(g:, 'vimrc_plugins_ready', 0))
assert_equal(2, exists(':VimrcFixtureReady'))
assert_equal(0, len(filter(
      getbufinfo(),
      (_, info) => getbufvar(info.bufnr, '&filetype') ==# 'simpleplug')))

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
