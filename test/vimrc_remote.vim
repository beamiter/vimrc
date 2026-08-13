vim9script

set nomore hidden

if exists(':VimrcRemoteConnect') != 2
      && filereadable($VIMRC_TEST_SIMPLEREMOTE_ROOT .. '/plugin/simpleremote.vim')
  execute 'set runtimepath^=' .. fnameescape($VIMRC_TEST_SIMPLEREMOTE_ROOT)
  execute 'source ' .. fnameescape(
    $VIMRC_TEST_SIMPLEREMOTE_ROOT .. '/plugin/simpleremote.vim')
endif

const REMOTE_ROOT = $VIMRC_TEST_REMOTE_ROOT
const REMOTE_TARGET = $VIMRC_TEST_REMOTE_TARGET
const REMOTE_FILE = REMOTE_ROOT .. '/notes.txt'
const REMOTE_URI = 'remote://' .. REMOTE_FILE
const SCRATCH_FILE = $VIMRC_TEST_SCRATCH_FILE
const GATE_DIR = $VIMRC_TEST_GATE_DIR

g:vimrc_test_remote_writepost_count = 0
g:vimrc_test_simplecc_restart_bufs = []
command! SimpleCCRestart call add(g:vimrc_test_simplecc_restart_bufs, bufnr())
augroup VimrcRemoteIntegration
  autocmd!
  autocmd BufWritePost remote://* g:vimrc_test_remote_writepost_count += 1
augroup END

def Status(): string
  return trim(execute('VimrcRemoteStatus'))
enddef

def WaitForReady(timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if Status() ==# 'ssh:' .. REMOTE_TARGET
          && exists('g:vimrc_remote_simplecc_config')
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

def WaitForRead(buf: number, timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if getbufline(buf, 1, '$') ==# ['first line', 'second line']
          && getbufvar(buf, '&buftype') ==# 'acwrite'
          && !getbufvar(buf, '&modified')
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

def WaitForWrite(buf: number, timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if readfile(REMOTE_FILE, 'b') ==# ['changed', 'trailing newline kept', '']
          && !getbufvar(buf, '&modified')
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

def WaitForMarker(name: string, timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if filereadable(GATE_DIR .. '/' .. name)
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

def Require(condition: bool, message: string)
  if !condition
    throw 'remote integration timeout: ' .. message
  endif
enddef

def ExpectNotConnected(command: string)
  var before = execute('messages')
  execute command
  var after = execute('messages')
  assert_match('not connected', strpart(after, len(before)))
enddef

def WaitForSavedMessage(previous_count: number, timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if count(execute('messages'), '[VimrcRemote] saved') > previous_count
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

def WaitForMessage(needle: string, previous_count: number,
    timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if count(execute('messages'), needle) > previous_count
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

def WaitForConfig(expected: any, timeout: float = 4.0): bool
  var started = reltime()
  while reltimefloat(reltime(started)) < timeout
    if exists('g:vimrc_remote_simplecc_config')
          && json_decode(g:vimrc_remote_simplecc_config) ==# expected
      return true
    endif
    sleep 10m
  endwhile
  return false
enddef

def RunTests()
  # Commands are useful and harmless before a connection exists.
  assert_equal('disconnected', Status())
  ExpectNotConnected('VimrcRemoteOpen nowhere.txt')
  ExpectNotConnected('VimrcRemoteExec pwd')
  var disconnect_error = ''
  try
    execute 'VimrcRemoteDisconnect'
  catch
    disconnect_error = v:exception
  endtry
  assert_equal('', disconnect_error)
  assert_equal('disconnected', Status())

  g:vimrc_remote_agent = $VIMRC_TEST_REMOTE_AGENT_COMMAND
  execute 'VimrcRemoteConnect ssh ' .. REMOTE_TARGET .. ' '
        .. fnameescape(REMOTE_ROOT)

  # A reload issued before the protocol handshake completes must not promote
  # the connection to ready or supersede the initial config request.
  Require(WaitForMarker('handshake.pending'),
        'handshake response was not captured')
  const not_ready_message = '[VimrcRemote] connection is not ready'
  const not_ready_messages = count(execute('messages'), not_ready_message)
  execute 'VimrcRemoteReloadConfig'
  Require(WaitForMessage(not_ready_message, not_ready_messages),
        'pre-handshake config reload was not rejected')
  assert_match('^connecting ssh:' .. REMOTE_TARGET, Status())
  assert_false(exists('g:vimrc_remote_workspace'))
  assert_false(exists('g:vimrc_remote_simplecc_config'))
  writefile(['release'], GATE_DIR .. '/handshake.release')

  Require(WaitForReady(), 'remote connection/config did not become ready')
  assert_equal('ssh:' .. REMOTE_TARGET, Status())
  assert_equal({kind: 'ssh', target: REMOTE_TARGET, root: REMOTE_ROOT},
        g:vimrc_remote_workspace)
  assert_equal({fixture: true}, json_decode(g:vimrc_remote_simplecc_config))

  # Read through remote://, then leave that buffer before the delayed reply.
  # The callback must update its captured buffer, never whichever buffer happens
  # to be current when the channel becomes readable.
  execute 'VimrcRemoteOpen notes.txt'
  const remote_buf = bufnr()
  assert_equal(REMOTE_URI, bufname(remote_buf))
  Require(WaitForMarker('read.pending'), 'read response was not captured')

  execute 'edit ' .. fnameescape(SCRATCH_FILE)
  const scratch_buf = bufnr()
  setlocal bufhidden=hide
  setline(1, 'scratch sentinel (modified)')
  assert_true(&modified)
  writefile(['release'], GATE_DIR .. '/read.release')

  Require(WaitForRead(remote_buf), 'remote read did not finish')
  assert_equal(scratch_buf, bufnr())
  assert_equal(['scratch sentinel (modified)'], getline(1, '$'))
  assert_true(&modified)
  assert_equal('', &buftype)
  assert_equal({}, get(b:, 'vimrc_remote', {}))
  assert_equal(['first line', 'second line'], getbufline(remote_buf, 1, '$'))
  assert_true(getbufvar(remote_buf, '&endofline'))
  assert_equal('acwrite', getbufvar(remote_buf, '&buftype'))
  assert_false(getbufvar(remote_buf, '&modified'))

  # Write exact bytes, including the final LF.  Switching back to a modified
  # scratch buffer before the ACK also verifies that the write callback clears
  # only the originating remote buffer's modified flag.
  execute 'buffer ' .. remote_buf
  setline(1, ['changed', 'trailing newline kept'])
  if line('$') > 2
    execute '3,$delete _'
  endif
  setlocal endofline fixendofline
  write
  Require(WaitForMarker('write.pending'), 'write response was not captured')
  assert_true(getbufvar(remote_buf, '&modified'))
  execute 'buffer ' .. scratch_buf
  assert_true(&modified)
  writefile(['release'], GATE_DIR .. '/write.release')

  Require(WaitForWrite(remote_buf), 'remote write/ack did not finish')
  assert_equal(scratch_buf, bufnr())
  assert_equal(['scratch sentinel (modified)'], getline(1, '$'))
  assert_true(&modified)
  assert_false(getbufvar(remote_buf, '&modified'))
  var writepost = getbufvar(remote_buf, 'vimrc_remote_writepost_pending', {})
  assert_equal(get(getbufvar(remote_buf, 'vimrc_remote', {}),
        'generation', -1), get(writepost, 'generation', -2))
  assert_equal(getbufvar(remote_buf, 'changedtick'), get(writepost, 'tick', -1))
  assert_true(get(writepost, 'final_eol', false))

  const hidden_writepost_count = g:vimrc_test_remote_writepost_count
  const hidden_tick = getbufvar(remote_buf, 'changedtick')
  setbufvar(remote_buf, '&binary', true)
  setbufvar(remote_buf, '&endofline', false)
  assert_equal(hidden_tick, getbufvar(remote_buf, 'changedtick'))
  execute 'buffer ' .. remote_buf
  assert_equal({}, getbufvar(remote_buf, 'vimrc_remote_writepost_pending', {}))
  assert_true(&modified)
  assert_equal(hidden_writepost_count, g:vimrc_test_remote_writepost_count)
  setlocal nobinary endofline fixendofline
  setlocal nomodified
  execute 'buffer ' .. scratch_buf

  # A successful ACK belongs to the snapshot that was sent.  If the user
  # edits that same buffer while the request is in flight, the old ACK must
  # leave the newer edit modified even though the remote snapshot was saved.
  execute 'buffer ' .. remote_buf
  setline(1, ['sent snapshot', 'waiting for ack'])
  setlocal endofline fixendofline
  write
  Require(WaitForMarker('stale-write.pending'),
        'second write response was not captured')
  const saved_messages = count(execute('messages'), '[VimrcRemote] saved')
  setline(1, ['new unsaved edit', 'must stay modified'])
  const edited_tick = b:changedtick
  execute 'buffer ' .. scratch_buf
  writefile(['release'], GATE_DIR .. '/stale-write.release')

  Require(WaitForSavedMessage(saved_messages),
        'second write ACK was not handled')
  assert_equal(['sent snapshot', 'waiting for ack', ''],
        readfile(REMOTE_FILE, 'b'))
  assert_equal(edited_tick, getbufvar(remote_buf, 'changedtick'))
  assert_equal(['new unsaved edit', 'must stay modified'],
        getbufline(remote_buf, 1, '$'))
  assert_true(getbufvar(remote_buf, '&modified'))
  assert_equal(scratch_buf, bufnr())
  assert_equal(['scratch sentinel (modified)'], getline(1, '$'))
  assert_true(&modified)

  # Buffer byte semantics are part of the write snapshot even though changing
  # 'binary'/'endofline'/'fixendofline' does not advance changedtick.  In
  # binary mode fixeol must not append LF.  Delay the ACK, change the effective
  # final-EOL state, and make sure it neither clears nor fires BufWritePost.
  execute 'buffer ' .. remote_buf
  setline(1, ['eol snapshot', 'binary mode omits final newline'])
  if line('$') > 2
    execute '3,$delete _'
  endif
  setlocal binary noendofline fixendofline
  const eol_writepost_count = g:vimrc_test_remote_writepost_count
  const eol_saved_messages = count(execute('messages'), '[VimrcRemote] saved')
  write
  Require(WaitForMarker('eol-write.pending'),
        'endofline write response was not captured')
  const eol_snapshot_tick = b:changedtick
  setlocal nobinary noendofline fixendofline
  assert_equal(eol_snapshot_tick, b:changedtick)
  assert_false(&endofline)
  assert_true(&fixendofline)
  execute 'buffer ' .. scratch_buf
  writefile(['release'], GATE_DIR .. '/eol-write.release')

  Require(WaitForSavedMessage(eol_saved_messages),
        'endofline write ACK was not handled')
  assert_equal(['eol snapshot', 'binary mode omits final newline'],
        readfile(REMOTE_FILE, 'b'))
  assert_equal(eol_snapshot_tick, getbufvar(remote_buf, 'changedtick'))
  assert_false(getbufvar(remote_buf, '&endofline'))
  assert_true(getbufvar(remote_buf, '&fixendofline'))
  assert_true(getbufvar(remote_buf, '&modified'))
  assert_equal({}, getbufvar(remote_buf,
        'vimrc_remote_writepost_pending', {}))
  assert_equal(eol_writepost_count, g:vimrc_test_remote_writepost_count)
  assert_equal(scratch_buf, bufnr())

  # Reload a changed SimpleCC config without replacing the transport.
  # A malformed replacement must keep the last known-good value, while a
  # deliberately removed file switches back to SimpleCC's defaults.
  const config_path = REMOTE_ROOT .. '/simplecc.json'
  writefile(['{"fixture": "reloaded", "version": 2}'], config_path)
  execute 'VimrcRemoteReloadConfig'
  Require(WaitForConfig({fixture: 'reloaded', version: 2}),
        'valid config reload did not replace the active config')
  assert_equal('ssh:' .. REMOTE_TARGET, Status())
  const last_good_config = g:vimrc_remote_simplecc_config

  const invalid_message = '[VimrcRemote] invalid remote simplecc.json:'
  const invalid_messages = count(execute('messages'), invalid_message)
  writefile(['{"fixture":'], config_path)
  execute 'VimrcRemoteReloadConfig'
  Require(WaitForMessage(invalid_message, invalid_messages),
        'invalid config reload was not handled')
  assert_equal(last_good_config, g:vimrc_remote_simplecc_config)
  assert_equal({fixture: 'reloaded', version: 2},
        json_decode(g:vimrc_remote_simplecc_config))
  assert_equal('ssh:' .. REMOTE_TARGET, Status())

  const defaults_message =
        '[VimrcRemote] no remote simplecc.json; using SimpleCC defaults'
  const defaults_messages = count(execute('messages'), defaults_message)
  assert_equal(0, delete(config_path))
  execute 'VimrcRemoteReloadConfig'
  Require(WaitForMessage(defaults_message, defaults_messages),
        'deleted config did not switch to defaults')
  assert_false(exists('g:vimrc_remote_simplecc_config'))
  assert_equal('ssh:' .. REMOTE_TARGET, Status())

  # Exercise concurrent reloads with deliberately reversed replies.  The
  # fixture captures request 10, then emits request 11 before it; only the
  # newest config is allowed to win.
  writefile(['{"fixture": "stale", "version": 3}'], config_path)
  execute 'VimrcRemoteReloadConfig'
  Require(WaitForMarker('config-stale.pending'),
        'stale config response was not captured')
  writefile(['{"fixture": "latest", "version": 4}'], config_path)
  execute 'VimrcRemoteReloadConfig'
  Require(WaitForConfig({fixture: 'latest', version: 4}),
        'latest concurrent config reload did not win')
  sleep 50m
  assert_equal({fixture: 'latest', version: 4},
        json_decode(g:vimrc_remote_simplecc_config))
  assert_equal('ssh:' .. REMOTE_TARGET, Status())

  # Leave a successful write's deferred BufWritePost in a hidden buffer, then
  # reconnect.  Entering that old-generation buffer must discard the pending
  # event, and a config reload must not use it as SimpleCCRestart's context.
  execute 'buffer ' .. remote_buf
  setline(1, ['generation snapshot', 'pending across reconnect'])
  if line('$') > 2
    execute '3,$delete _'
  endif
  setlocal endofline fixendofline
  const generation_saved_messages =
        count(execute('messages'), '[VimrcRemote] saved')
  write
  Require(WaitForMarker('generation-write.pending'),
        'generation write response was not captured')
  execute 'buffer ' .. scratch_buf
  writefile(['release'], GATE_DIR .. '/generation-write.release')
  Require(WaitForSavedMessage(generation_saved_messages),
        'generation write ACK was not handled')
  assert_false(getbufvar(remote_buf, '&modified'))
  assert_false(empty(getbufvar(remote_buf,
        'vimrc_remote_writepost_pending', {})))
  const writepost_count = g:vimrc_test_remote_writepost_count
  const restart_count = len(g:vimrc_test_simplecc_restart_bufs)

  execute 'VimrcRemoteDisconnect'
  Require(WaitForMarker('ssh.exit'),
        'transport did not exit before generation reconnect')
  assert_equal('disconnected', Status())
  assert_equal(0, delete(GATE_DIR .. '/ssh.exit'))
  execute 'VimrcRemoteConnect ssh ' .. REMOTE_TARGET .. ' '
        .. fnameescape(REMOTE_ROOT)
  Require(WaitForReady(), 'generation reconnect did not become ready')
  assert_equal(scratch_buf, bufnr())

  execute 'buffer ' .. remote_buf
  assert_equal({}, getbufvar(remote_buf,
        'vimrc_remote_writepost_pending', {}))
  assert_equal(writepost_count, g:vimrc_test_remote_writepost_count)

  const reload_message = '[VimrcRemote] remote SimpleCC config loaded'
  const reload_messages = count(execute('messages'), reload_message)
  execute 'VimrcRemoteReloadConfig'
  Require(WaitForMessage(reload_message, reload_messages),
        'post-reconnect config reload did not finish')
  assert_equal(restart_count, len(g:vimrc_test_simplecc_restart_bufs))
  assert_equal('ssh:' .. REMOTE_TARGET, Status())
  execute 'buffer ' .. scratch_buf

  # Reload through the existing controller so its live job is stopped before
  # autocmds are rewired; the transport must never be orphaned by :VimrcReload.
  execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
  Require(WaitForMarker('ssh.exit'), 'transport did not exit on vimrc reload')
  assert_equal('disconnected', Status())
  ExpectNotConnected('VimrcRemoteOpen after-reload.txt')

  delete(GATE_DIR .. '/ssh.exit')
  execute 'VimrcRemoteConnect ssh ' .. REMOTE_TARGET .. ' '
        .. fnameescape(REMOTE_ROOT)
  Require(WaitForReady(), 'reconnected transport did not become ready')
  execute 'VimrcRemoteDisconnect'
  Require(WaitForMarker('ssh.exit'), 'transport did not exit on disconnect')
  var disconnected_started = reltime()
  while Status() !=# 'disconnected'
        && reltimefloat(reltime(disconnected_started)) < 4.0
    sleep 10m
  endwhile
  assert_equal('disconnected', Status())
  ExpectNotConnected('VimrcRemoteOpen after-disconnect.txt')
enddef

var test_exception = ''
try
  RunTests()
catch
  test_exception = v:exception .. ' @ ' .. v:throwpoint
finally
  if exists(':VimrcRemoteDisconnect') == 2
    silent! execute 'VimrcRemoteDisconnect'
  endif
endtry
if !empty(test_exception)
  add(v:errors, test_exception)
endif

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
