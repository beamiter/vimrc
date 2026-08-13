vim9script

# Local UI / remote filesystem bridge.  The remote side is intentionally not
# Vim-specific: it is a small shell agent speaking a line protocol.
var s_remote: dict<any> = {}
var s_next_id = 0
var s_generation = 0
var s_base64_decode_flag = ''
var s_connect_spec: dict<any> = {}
var s_last_spec: dict<any> = {}
var s_tree: dict<any> = {}
var s_previous_cwd = ''

const PROTOCOL = 'simpleremote/2'

g:vimrc_remote_status = 'disconnected'
g:simpleremote_status = 'disconnected'

def SetStatus(status: string)
  g:vimrc_remote_status = status
  g:simpleremote_status = status
enddef

def B64(value: string): string
  # base64 without GNU's -w flag works on both GNU and BSD implementations.
  return system('base64', value)->substitute('\n', '', 'g')
enddef

def Base64DecodeFlag(): string
  if !empty(s_base64_decode_flag)
    return s_base64_decode_flag
  endif
  system('base64 -d', '')
  if v:shell_error == 0
    s_base64_decode_flag = '-d'
    return s_base64_decode_flag
  endif
  system('base64 -D', '')
  s_base64_decode_flag = v:shell_error == 0 ? '-D' : '-d'
  return s_base64_decode_flag
enddef

def UnB64(value: string): string
  return system('base64 ' .. Base64DecodeFlag(), value)
enddef

def Error(message: string)
  echohl ErrorMsg
  echomsg message
  echohl None
enddef

def Emit(event: string, payload: dict<any> = {})
  g:simpleremote_event = extend(copy(payload), {
    event: event,
    status: get(g:, 'simpleremote_status', 'disconnected'),
    time: localtime(),
  })
  execute 'silent! doautocmd <nomodeline> User ' .. event
enddef

def IsCurrent(generation: number): bool
  return !empty(s_remote) && get(s_remote, 'generation', -1) == generation
enddef

def IsReady(): bool
  return !empty(s_remote) && get(s_remote, 'state', '') ==# 'ready'
enddef

def ClearGlobals()
  SetStatus('disconnected')
  unlet! g:vimrc_remote_workspace
  unlet! g:vimrc_remote_simplecc_config
  unlet! g:simpleremote_workspace
enddef

def StopRequestTimer(entry: dict<any>)
  var timer = get(entry, 'timer', 0)
  if timer > 0
    timer_stop(timer)
  endif
enddef

def RequestTimedOut(generation: number, key: string)
  if !IsCurrent(generation) || !has_key(s_remote.pending, key)
    return
  endif
  var entry = remove(s_remote.pending, key)
  var Callback = entry.callback
  call(Callback, [false, 'request timed out: ' .. entry.operation])
enddef

def Send(op: string, payload: string, Callback: func): number
  if empty(s_remote) || get(s_remote, 'channel', v:null) == v:null
    Error('[VimrcRemote] not connected')
    call(Callback, [false, 'not connected'])
    return -1
  endif
  if ch_status(s_remote.channel) !=# 'open'
    Error('[VimrcRemote] transport is not writable')
    call(Callback, [false, 'transport is not writable'])
    return -1
  endif

  s_next_id += 1
  var id = s_next_id
  var key = string(id)
  var generation = s_remote.generation
  var timeout = max([0, get(g:, 'vimrc_remote_request_timeout', 15000)])
  var timer = timeout > 0
        ? timer_start(timeout, (_) => RequestTimedOut(generation, key))
        : 0
  s_remote.pending[key] = {
    callback: Callback,
    operation: op,
    timer: timer,
  }
  try
    ch_sendraw(s_remote.channel,
      id .. "\t" .. op .. "\t" .. B64(payload) .. "\n")
  catch
    var failed_here = false
    if IsCurrent(generation) && has_key(s_remote.pending, key)
      var entry = remove(s_remote.pending, key)
      StopRequestTimer(entry)
      failed_here = true
    endif
    # OnExit may have run while ch_sendraw() was failing.  In that case it
    # already completed every pending callback, so never invoke this one twice.
    if failed_here
      Error('[VimrcRemote] transport is not writable')
      call(Callback, [false, 'transport is not writable'])
    endif
    return -1
  endtry
  return id
enddef

def OnLine(generation: number, _channel: any, line: string)
  if !IsCurrent(generation)
    return
  endif
  var parts = split(line, "\t", 1)
  if len(parts) != 3 || !has_key(s_remote.pending, parts[0])
    return
  endif
  var entry = remove(s_remote.pending, parts[0])
  StopRequestTimer(entry)
  var Callback = entry.callback
  call(Callback, [parts[1] ==# 'ok', UnB64(parts[2])])
enddef

def OnError(generation: number, _channel: any, line: string)
  if !IsCurrent(generation) || empty(line)
    return
  endif
  add(s_remote.stderr, line)
  if len(s_remote.stderr) > 20
    remove(s_remote.stderr, 0)
  endif
enddef

def FailPending(remote: dict<any>, message: string)
  for entry in values(get(remote, 'pending', {}))
    StopRequestTimer(entry)
    var Callback = entry.callback
    call(Callback, [false, message])
  endfor
enddef

def OnExit(generation: number, _job: any, status: number)
  if !IsCurrent(generation)
    return
  endif
  var remote = s_remote
  s_remote = {}
  DeactivateWorkspace(remote)
  ClearGlobals()
  FailPending(remote, printf('connection closed (%d)', status))
  StopSimpleCC(remote)
  var detail = empty(remote.stderr) ? '' : ': ' .. remote.stderr[-1]
  echomsg printf('[VimrcRemote] connection closed (%d)%s', status, detail)
  Emit('SimpleRemoteDisconnected', {reason: 'transport-exit', code: status})
enddef

def AgentPath(): string
  return get(g:, 'simpleremote_agent',
    get(g:, 'vimrc_remote_agent', '~/.cache/vimrc/simpleremote-agent.sh'))
enddef

def ShellLiteral(value: string): string
  return shellescape(value)
enddef

def DockerAgentCommand(agent: string): string
  if strpart(agent, 0, 2) ==# '~/'
    return 'exec "$HOME"/' .. ShellLiteral(strpart(agent, 2))
  endif
  return 'exec ' .. ShellLiteral(agent)
enddef

def TargetCommand(kind: string, target: string, agent: string): list<string>
  if kind ==# 'docker'
    return ['docker', 'exec', '-i', target, 'sh', '-c',
      DockerAgentCommand(agent)]
  endif
  var script = 'exec ' .. (strpart(agent, 0, 2) ==# '~/'
    ? '"$HOME"/' .. ShellLiteral(strpart(agent, 2))
    : ShellLiteral(agent))
  # OpenSSH joins all arguments after the host into one login-shell command.
  # Quote the complete -c script so that boundary survives that re-serialization.
  return ['ssh', '-T', target, 'sh', '-c', ShellLiteral(script)]
enddef

def StopSimpleCC(remote: dict<any>)
  if get(remote, 'simplecc_started', false) && exists(':SimpleCCStop') == 2
    execute 'silent! SimpleCCStop'
  endif
enddef

def Disconnect(show_message: bool = true)
  if empty(s_remote)
    CloseRemoteTree()
    ClearGlobals()
    return
  endif
  var remote = s_remote
  s_generation += 1
  s_remote = {}
  DeactivateWorkspace(remote)
  ClearGlobals()
  FailPending(remote, 'connection closed')
  StopSimpleCC(remote)
  var job = get(remote, 'job', v:null)
  if job != v:null && job_status(job) ==# 'run'
    job_stop(job, 'term')
  endif
  if show_message
    echomsg '[SimpleRemote] disconnected'
  endif
  Emit('SimpleRemoteDisconnected', {reason: 'disconnect'})
enddef

def FinishConnection(generation: number)
  if !IsCurrent(generation)
    return
  endif
  s_remote.state = 'ready'
  s_remote.connection_announced = true
  SetStatus(printf('%s:%s', s_remote.kind, s_remote.target))
  var mounting = ActivateWorkspace(generation)
  RecordRecent()
  echomsg printf('[SimpleRemote] connected %s %s:%s',
    s_remote.kind, s_remote.target, s_remote.root)
  Emit('SimpleRemoteConnected', WorkspaceSnapshot())

  var queued = copy(s_remote.open_queue)
  s_remote.open_queue = []
  for path in queued
    OpenRemote(path)
  endfor
  if get(g:, 'simpleremote_open_tree_on_connect', 1) && !mounting
    timer_start(0, (_) => OpenWorkspaceTree())
  endif
enddef

def FetchRemoteConfig(generation: number, Completion: func)
  if !IsCurrent(generation)
    return
  endif
  s_remote.config_epoch += 1
  var config_epoch = s_remote.config_epoch
  s_remote.state = 'configuring'
  var root = s_remote.root
  var config_path = root ==# '/' ? '/simplecc.json' : root .. '/simplecc.json'
  Send('read-config', config_path, (ok, body) => {
    if !IsCurrent(generation) || s_remote.config_epoch != config_epoch
      return
    endif
    if !ok
      if body =~# '^config not found:'
        unlet! g:vimrc_remote_simplecc_config
        echomsg '[VimrcRemote] no remote simplecc.json; using SimpleCC defaults'
        call(Completion, [true])
      else
        Error('[VimrcRemote] cannot load remote simplecc.json: ' .. body)
        call(Completion, [false])
      endif
      return
    endif
    var config = UnB64(body)
    try
      json_decode(config)
      g:vimrc_remote_simplecc_config = config
      echomsg '[VimrcRemote] remote SimpleCC config loaded'
    catch
      Error('[VimrcRemote] invalid remote simplecc.json: ' .. v:exception)
      call(Completion, [false])
      return
    endtry
    call(Completion, [true])
  })
enddef

def Connect(kind: string, target: string, root: string,
    options: dict<any> = {})
  if kind !=# 'ssh' && kind !=# 'docker'
    Error('[VimrcRemote] transport must be ssh or docker')
    return
  endif
  if empty(target) || target =~# '^-' || root !~# '^/'
    Error('[VimrcRemote] target is required and root must be absolute')
    return
  endif

  Disconnect(false)
  s_connect_spec = copy(options)
  s_generation += 1
  var generation = s_generation
  var job = job_start(TargetCommand(kind, target, AgentPath()), {
    in_io: 'pipe', out_io: 'pipe', err_io: 'pipe', out_mode: 'nl',
    err_mode: 'nl',
    out_cb: (channel, line) => OnLine(generation, channel, line),
    err_cb: (channel, line) => OnError(generation, channel, line),
    exit_cb: (exited_job, status) => OnExit(generation, exited_job, status),
  })
  if job_status(job) ==# 'fail'
    ClearGlobals()
    Error('[VimrcRemote] cannot start transport')
    return
  endif

  s_remote = {
    job: job,
    channel: job_getchannel(job),
    pending: {},
    stderr: [],
    generation: generation,
    kind: kind,
    target: target,
    root: root ==# '/' ? '/' : substitute(root, '/\+$', '', ''),
    state: 'connecting',
    handshake_ready: false,
    connection_announced: false,
    open_queue: [],
    config_epoch: 0,
    simplecc_started: false,
    simplecc_restart_pending: false,
    options: copy(options),
    local_root: '',
    workspace_mode: 'virtual',
    mount_owned: false,
    mount_job: v:null,
  }
  s_last_spec = extend(copy(options), {
    kind: kind,
    target: target,
    root: s_remote.root,
  }, 'force')
  SetStatus(printf('connecting %s:%s', kind, target))
  unlet! g:vimrc_remote_workspace
  unlet! g:vimrc_remote_simplecc_config
  unlet! g:simpleremote_workspace
  Emit('SimpleRemoteConnecting', copy(s_last_spec))

  Send('ping', '', (ok, body) => {
    if !IsCurrent(generation)
      return
    endif
    if !ok || body !=# PROTOCOL
      var reason = ok ? 'unsupported agent: ' .. body : body
      Error('[VimrcRemote] remote agent rejected connection: ' .. reason)
      Disconnect(false)
      return
    endif
    s_remote.handshake_ready = true
    g:vimrc_remote_workspace = {kind: kind, target: target, root: s_remote.root}
    FetchRemoteConfig(generation, (_) => FinishConnection(generation))
  })
enddef

def RemoteLines(content: string): list<string>
  var lines = split(content, "\n", 1)
  if content =~# "\n$" && len(lines) > 1 && lines[-1] ==# ''
    remove(lines, -1)
  endif
  return empty(lines) ? [''] : lines
enddef

def DetectRemoteFiletype(buf: number)
  if bufnr() == buf && &filetype ==# ''
    filetype detect
  endif
enddef

def NotifySimpleCCWhenReady(generation: number, attempts: number)
  if !IsCurrent(generation) || attempts <= 0
    return
  endif
  if get(g:, 'simplecc_status', '') ==# 'ready'
    var seen: dict<bool> = {}
    for win in getwininfo()
      var key = string(win.bufnr)
      var info = getbufvar(win.bufnr, 'vimrc_remote', {})
      if !has_key(seen, key)
            && get(info, 'generation', -1) == generation
        seen[key] = true
        win_execute(win.winid, 'silent! call simplecc#OnBufOpen()')
      endif
    endfor
    return
  endif
  timer_start(100, (_) => NotifySimpleCCWhenReady(generation, attempts - 1))
enddef

def RemoteContextBuffer(preferred: number, generation: number): number
  if preferred > 0 && bufname(preferred) =~# '^remote://'
        && get(getbufvar(preferred, 'vimrc_remote', {}),
          'generation', -1) == generation
        && (bufnr() == preferred || bufwinid(preferred) > 0)
    return preferred
  endif
  for win in getwininfo()
    if bufname(win.bufnr) =~# '^remote://'
          && get(getbufvar(win.bufnr, 'vimrc_remote', {}),
            'generation', -1) == generation
      return win.bufnr
    endif
  endfor
  return -1
enddef

def RestartSimpleCC(generation: number, buf: number)
  if !IsCurrent(generation) || exists(':SimpleCCRestart') != 2
    return
  endif
  var context = RemoteContextBuffer(buf, generation)
  if context < 0
    s_remote.simplecc_restart_pending = true
    return
  endif
  var winid = bufwinid(context)
  if bufnr() == context
    execute 'silent! SimpleCCRestart'
  elseif winid > 0
    win_execute(winid, 'silent! SimpleCCRestart')
  else
    s_remote.simplecc_restart_pending = true
    return
  endif
  s_remote.simplecc_started = true
  s_remote.simplecc_restart_pending = false
  NotifySimpleCCWhenReady(generation, 600)
enddef

def MaybeStartSimpleCC(buf: number)
  if !IsReady() || bufname(buf) !~# '^remote://'
    return
  endif
  var info = getbufvar(buf, 'vimrc_remote', {})
  if get(info, 'generation', -1) != s_remote.generation
    return
  endif
  if !get(s_remote, 'simplecc_started', false)
        || get(s_remote, 'simplecc_restart_pending', false)
    RestartSimpleCC(s_remote.generation, buf)
  elseif get(g:, 'simplecc_status', '') ==# 'ready'
    var winid = bufwinid(buf)
    if winid > 0
      win_execute(winid, 'silent! call simplecc#OnBufOpen()')
    endif
  endif
enddef

def OpenRemote(path: string)
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  if !IsReady()
    add(s_remote.open_queue, path)
    echomsg '[VimrcRemote] opening after connection is ready: ' .. path
    return
  endif

  var remote_path = path =~# '^/' ? path
        : s_remote.root ==# '/' ? '/' .. path : s_remote.root .. '/' .. path
  var uri = 'remote://' .. remote_path
  var existing = bufnr(uri)
  var was_loaded = existing > 0 && bufloaded(existing)
  if existing > 0 && getbufvar(existing, '&modified')
        && get(getbufvar(existing, 'vimrc_remote', {}), 'generation', -1)
          != s_remote.generation
    Error('[VimrcRemote] refusing to replace modified buffer from an old connection')
    return
  endif
  execute 'edit ' .. fnameescape(uri)
  if was_loaded
    ReadRemote(uri)
  endif
enddef

def JoinRemotePath(root: string, path: string): string
  return root ==# '/' ? '/' .. path : root .. '/' .. path
enddef

def ApplyRemoteRead(buf: number, generation: number, request_id: number,
    remote_path: string, uri: string, ok: bool, body: string)
  if !IsCurrent(generation) || !bufexists(buf)
    return
  endif
  var pending = getbufvar(buf, 'vimrc_remote_read', {})
  if get(pending, 'request_id', -1) != request_id
    return
  endif
  setbufvar(buf, 'vimrc_remote_read', {})
  if !ok
    Error('[VimrcRemote] ' .. body)
    return
  endif
  if getbufvar(buf, 'changedtick', -1) != get(pending, 'tick', -2)
        || getbufvar(buf, '&modified')
    Error('[VimrcRemote] read result ignored because the buffer changed')
    return
  endif

  var content = UnB64(body)
  var lines = RemoteLines(content)
  var old_count = len(getbufline(buf, 1, '$'))
  setbufline(buf, 1, lines)
  if old_count > len(lines)
    deletebufline(buf, len(lines) + 1, old_count)
  endif
  setbufvar(buf, '&endofline', content =~# "\n$")
  setbufvar(buf, '&buftype', 'acwrite')
  setbufvar(buf, '&swapfile', 0)
  setbufvar(buf, 'vimrc_remote', {
    path: remote_path,
    uri: uri,
    generation: generation,
  })
  setbufvar(buf, '&modified', 0)
  MaybeStartSimpleCC(buf)
  DetectRemoteFiletype(buf)
enddef

def ReadRemote(uri: string)
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  var buf = bufnr()
  var generation = s_remote.generation
  var remote_path = substitute(uri, '^remote://', '', '')
  var request_id = 0
  request_id = Send('read', remote_path, (ok, body) =>
    ApplyRemoteRead(buf, generation, request_id, remote_path, uri, ok, body))
  if request_id >= 0
    setbufvar(buf, 'vimrc_remote_read', {
      request_id: request_id,
      tick: getbufvar(buf, 'changedtick', -1),
    })
  endif
enddef

def BufferHasFinalEol(buf: number): bool
  return !!(getbufvar(buf, '&endofline')
    || (getbufvar(buf, '&fixendofline') && !getbufvar(buf, '&binary')))
enddef

def FireRemoteWritePost(buf: number, generation: number, tick: number,
    final_eol: bool)
  var winid = bufwinid(buf)
  if winid > 0
    setbufvar(buf, 'vimrc_remote_writepost_pending', {})
    win_execute(winid, 'silent doautocmd <nomodeline> BufWritePost')
  else
    setbufvar(buf, 'vimrc_remote_writepost_pending', {
      generation: generation,
      tick: tick,
      final_eol: final_eol,
    })
  endif
enddef

def FinishRemoteWrite(buf: number, generation: number, tick: number,
    final_eol: bool, ok: bool, body: string)
  if !IsCurrent(generation) || !bufexists(buf)
    return
  endif
  if !ok
    Error('[VimrcRemote] save failed: ' .. body)
    return
  endif
  var same_tick = getbufvar(buf, 'changedtick', -1) == tick
  if same_tick && BufferHasFinalEol(buf) == final_eol
    setbufvar(buf, '&modified', 0)
    FireRemoteWritePost(buf, generation, tick, final_eol)
  else
    # 'endofline'/'fixendofline' can change without advancing changedtick.
    # Mark that byte-level difference pending just like a text edit.
    if same_tick
      setbufvar(buf, '&modified', 1)
    endif
    echomsg '[VimrcRemote] saved an older snapshot; newer changes remain'
  endif
  echomsg '[VimrcRemote] saved ' .. body
enddef

def WriteRemote(buf: number = bufnr())
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  var info = getbufvar(buf, 'vimrc_remote', {})
  if empty(info)
    Error('[VimrcRemote] buffer is not backed by a remote file')
    return
  endif
  var generation = s_remote.generation
  if get(info, 'generation', -1) != generation
    Error('[VimrcRemote] buffer belongs to an old connection; reopen it first')
    return
  endif
  var content = join(getbufline(buf, 1, '$'), "\n")
  if BufferHasFinalEol(buf)
    content ..= "\n"
  endif
  var tick = getbufvar(buf, 'changedtick', -1)
  var final_eol = BufferHasFinalEol(buf)
  Send('write', info.path .. "\t" .. B64(content), (ok, body) =>
    FinishRemoteWrite(buf, generation, tick, final_eol, ok, body))
enddef

def RemoteExec(command: string)
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  var root = s_remote.root
  Send('exec', 'cd ' .. shellescape(root) .. ' && ' .. command,
    (ok, body) => {
      if ok
        echomsg body
      else
        Error('[VimrcRemote] ' .. body)
      endif
    })
enddef

def RemoteFind(query: string)
  var root = s_remote.root
  var command = 'rg --files --hidden --glob ' .. shellescape('!.git/*')
        .. ' | rg --smart-case -- ' .. shellescape(query)
  Send('grep', 'cd ' .. shellescape(root) .. ' && ' .. command,
    (ok, body) => {
      if !ok && !empty(body)
        Error('[VimrcRemote] ' .. body)
        return
      endif
      var entries: list<dict<any>> = []
      for line in split(body, '\n')
        if !empty(line)
          add(entries, {filename: 'remote://' .. JoinRemotePath(root, line)})
        endif
      endfor
      setqflist([], ' ', {title: 'Remote files: ' .. query, items: entries})
      copen
    })
enddef

def RemoteList(path: string)
  var remote_path = path ==# '' ? s_remote.root
        : path =~# '^/' ? path : JoinRemotePath(s_remote.root, path)
  Send('list', remote_path, (ok, body) => {
    if !ok
      Error('[VimrcRemote] ' .. body)
      return
    endif
    var items: list<dict<any>> = []
    for line in split(body, '\n')
      var fields = split(line, "\t", 1)
      if len(fields) < 2 || empty(fields[0])
        continue
      endif
      if fields[1] ==# 'd'
        # Directories are headings, not buffers.  Drill down explicitly with
        # :VimrcRemoteList path instead of opening a guaranteed read error.
        add(items, {text: fields[0] .. '/', valid: 0})
      else
        var child = JoinRemotePath(remote_path, fields[0])
        add(items, {filename: 'remote://' .. child, text: fields[0]})
      endif
    endfor
    setqflist([], ' ', {title: 'Remote tree: ' .. remote_path, items: items})
    copen
  })
enddef

def RemoteHealth()
  var root = s_remote.root
  var command = 'cd ' .. shellescape(root)
        .. ' && { printf "host=%s\\npwd=%s\\n" "$(hostname 2>/dev/null || true)" "$PWD"; '
        .. 'command -v git || true; command -v rg || true; }'
  Send('exec', command, (ok, body) => {
    if ok
      echomsg '[VimrcRemote] ' .. body
    else
      Error('[VimrcRemote] ' .. body)
    endif
  })
enddef

def RemoteGit(command: string)
  var root = s_remote.root
  Send('exec', 'cd ' .. shellescape(root) .. ' && git ' .. command,
    (ok, body) => {
      if !ok
        Error('[VimrcRemote] ' .. body)
        return
      endif
      var items: list<dict<any>> = []
      for line in split(body, '\n')
        if !empty(line)
          add(items, {text: line})
        endif
      endfor
      setqflist([], ' ', {title: 'Remote git ' .. command, items: items})
      copen
    })
enddef

# ---------------------------------------------------------------------------
# SimpleRemote workspace projection, discovery, and UI
# ---------------------------------------------------------------------------

def WorkspaceSnapshot(): dict<any>
  if empty(s_remote)
    return {}
  endif
  return {
    id: get(s_remote, 'generation', -1),
    kind: get(s_remote, 'kind', ''),
    target: get(s_remote, 'target', ''),
    root: get(s_remote, 'root', ''),
    local_root: get(s_remote, 'local_root', ''),
    mode: get(s_remote, 'workspace_mode', 'virtual'),
    uri: 'remote://' .. get(s_remote, 'root', ''),
  }
enddef

def PublishWorkspace(mode: string, local_root: string = '')
  if empty(s_remote)
    return
  endif
  s_remote.workspace_mode = mode
  s_remote.local_root = local_root
  g:simpleremote_workspace = WorkspaceSnapshot()
enddef

def UnderRoot(path: string, root: string): bool
  if empty(path) || empty(root)
    return false
  endif
  var clean_root = root ==# '/' ? '/' : substitute(root, '/\+$', '', '')
  return path ==# clean_root
    || (clean_root ==# '/' ? path =~# '^/' : stridx(path, clean_root .. '/') == 0)
enddef

def NormalizeLocalRoot(path: string): string
  if empty(path)
    return ''
  endif
  var full = fnamemodify(expand(path), ':p')
  if !isdirectory(full)
    return ''
  endif
  return substitute(resolve(full), '[\\/]\+$', '', '')
enddef

def ShellCommand(argv: list<string>): string
  var quoted: list<string> = []
  for value in argv
    add(quoted, shellescape(value))
  endfor
  return join(quoted, ' ')
enddef

def DockerBindRoot(target: string, root: string): string
  if !executable('docker')
    return ''
  endif
  var output = systemlist(ShellCommand([
    'docker', 'inspect', '--format', '{{json .Mounts}}', target,
  ]))
  if v:shell_error != 0 || empty(output)
    return ''
  endif
  var mounts: any
  try
    mounts = json_decode(output[0])
  catch
    return ''
  endtry
  if type(mounts) != v:t_list
    return ''
  endif
  var best_destination = ''
  var best_source = ''
  for mount in mounts
    if type(mount) != v:t_dict
      continue
    endif
    var destination = substitute(get(mount, 'Destination', ''), '/\+$', '', '')
    var source = get(mount, 'Source', '')
    if empty(destination) || empty(source) || !UnderRoot(root, destination)
      continue
    endif
    if len(destination) > len(best_destination)
      best_destination = destination
      best_source = source
    endif
  endfor
  if empty(best_source)
    return ''
  endif
  var suffix = strpart(root, len(best_destination))
  return NormalizeLocalRoot(best_source .. suffix)
enddef

def ExplicitLocalRoot(): string
  var options = get(s_remote, 'options', {})
  var configured = get(options, 'local_root', '')
  if empty(configured)
    var roots = get(g:, 'simpleremote_local_roots', {})
    var key = printf('%s:%s:%s', s_remote.kind, s_remote.target, s_remote.root)
    if type(roots) == v:t_dict
      configured = get(roots, key, '')
    endif
  endif
  return NormalizeLocalRoot(configured)
enddef

def ProjectionStateDir(): string
  var context = get(g:, 'vimrc_context', {})
  var state = get(context, 'vim_state', expand('~/.local/state/vim'))
  return get(g:, 'simpleremote_state_dir', state .. '/simpleremote')
enddef

def ActivateProjection(local_root: string, mode: string, owned: bool = false)
  if empty(s_remote) || !isdirectory(local_root)
    return
  endif
  if empty(s_previous_cwd)
    s_previous_cwd = getcwd()
  endif
  s_remote.mount_owned = owned
  PublishWorkspace(mode, local_root)
  if get(g:, 'simpleremote_change_directory', 'tab') ==# 'global'
    execute 'silent! cd ' .. fnameescape(local_root)
  elseif get(g:, 'simpleremote_change_directory', 'tab') !=# 'none'
    execute 'silent! tcd ' .. fnameescape(local_root)
  endif
  Emit('SimpleRemoteWorkspaceChanged', WorkspaceSnapshot())
enddef

def OnSshfsExit(generation: number, mountpoint: string,
    _job: any, status: number)
  if !IsCurrent(generation)
    return
  endif
  s_remote.mount_job = v:null
  if status == 0 && isdirectory(mountpoint)
    ActivateProjection(mountpoint, 'sshfs', true)
    echomsg '[SimpleRemote] SSHFS workspace ready: ' .. mountpoint
    if get(g:, 'simpleremote_open_tree_on_connect', 1)
      timer_start(0, (_) => OpenWorkspaceTree())
    endif
    return
  endif
  PublishWorkspace('virtual')
  echomsg '[SimpleRemote] SSHFS unavailable; using virtual workspace'
  if get(g:, 'simpleremote_open_tree_on_connect', 1)
    timer_start(0, (_) => OpenWorkspaceTree())
  endif
enddef

def StartSshfs(generation: number): bool
  if s_remote.kind !=# 'ssh' || !executable('sshfs')
    return false
  endif
  var workspace_mode = get(g:, 'simpleremote_workspace_mode', 'auto')
  var sshfs_mode = get(g:, 'simpleremote_use_sshfs', 'auto')
  if workspace_mode ==# 'virtual' || sshfs_mode ==# 'never' || sshfs_mode == 0
    return false
  endif
  var key = substitute(s_remote.target, '[^0-9A-Za-z_.-]', '_', 'g')
    .. '-' .. strpart(sha256(s_remote.root), 0, 12)
  var mountpoint = ProjectionStateDir() .. '/mounts/' .. key
  if mkdir(mountpoint, 'p', 0700) == 0 && !isdirectory(mountpoint)
    return false
  endif
  if executable('mountpoint')
    system('mountpoint -q ' .. shellescape(mountpoint))
    if v:shell_error == 0
      ActivateProjection(mountpoint, 'sshfs', false)
      return false
    endif
  endif
  PublishWorkspace('mounting')
  var job = job_start([
    'sshfs', s_remote.target .. ':' .. s_remote.root, mountpoint,
    '-o', 'reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,BatchMode=yes',
  ], {
    in_io: 'null', out_io: 'null', err_io: 'pipe', err_mode: 'nl',
    err_cb: (channel, line) => OnError(generation, channel, line),
    exit_cb: (exited_job, status) =>
      OnSshfsExit(generation, mountpoint, exited_job, status),
  })
  if job_status(job) ==# 'fail'
    PublishWorkspace('virtual')
    return false
  endif
  s_remote.mount_job = job
  return true
enddef

def ActivateWorkspace(generation: number): bool
  PublishWorkspace('virtual')
  var local_root = ExplicitLocalRoot()
  if empty(local_root) && s_remote.kind ==# 'docker'
        && get(g:, 'simpleremote_workspace_mode', 'auto') !=# 'virtual'
    local_root = DockerBindRoot(s_remote.target, s_remote.root)
  endif
  if !empty(local_root)
    ActivateProjection(local_root,
      s_remote.kind ==# 'docker' ? 'docker-bind' : 'local-map')
    return false
  endif
  return StartSshfs(generation)
enddef

def CloseRemoteTree()
  var buf = get(s_tree, 'buf', -1)
  if buf > 0 && bufexists(buf)
    var winid = bufwinid(buf)
    if winid > 0
      win_execute(winid, 'silent! close')
    endif
  endif
  s_tree = {}
enddef

def DeactivateWorkspace(remote: dict<any>)
  CloseRemoteTree()
  var mount_job = get(remote, 'mount_job', v:null)
  if mount_job != v:null && job_status(mount_job) ==# 'run'
    job_stop(mount_job, 'term')
  endif
  var local_root = get(remote, 'local_root', '')
  if get(remote, 'mount_owned', false) && !empty(local_root)
    if executable('fusermount3')
      system(ShellCommand(['fusermount3', '-u', local_root]))
    elseif executable('fusermount')
      system(ShellCommand(['fusermount', '-u', local_root]))
    elseif executable('umount')
      system(ShellCommand(['umount', local_root]))
    endif
  endif
  if !empty(s_previous_cwd) && isdirectory(s_previous_cwd)
        && (getcwd() ==# local_root || UnderRoot(getcwd(), local_root))
    execute 'silent! tcd ' .. fnameescape(s_previous_cwd)
  endif
  s_previous_cwd = ''
enddef

def HistoryFile(): string
  return get(g:, 'simpleremote_history_file',
    ProjectionStateDir() .. '/recent.json')
enddef

def RecentSpecs(): list<dict<any>>
  var file = HistoryFile()
  if !filereadable(file)
    return []
  endif
  try
    var decoded = json_decode(join(readfile(file), "\n"))
    return type(decoded) == v:t_list ? decoded : []
  catch
    return []
  endtry
enddef

def RecordRecent()
  if empty(s_remote)
    return
  endif
  var current = {
    name: get(s_remote.options, 'name', ''),
    kind: s_remote.kind,
    target: s_remote.target,
    root: s_remote.root,
    local_root: get(s_remote.options, 'local_root', ''),
  }
  var key = printf('%s\t%s\t%s', current.kind, current.target, current.root)
  var recent: list<dict<any>> = [current]
  for spec in RecentSpecs()
    if type(spec) != v:t_dict
      continue
    endif
    var other = printf('%s\t%s\t%s', get(spec, 'kind', ''),
      get(spec, 'target', ''), get(spec, 'root', ''))
    if other !=# key
      add(recent, spec)
    endif
    if len(recent) >= get(g:, 'simpleremote_recent_limit', 12)
      break
    endif
  endfor
  try
    mkdir(fnamemodify(HistoryFile(), ':h'), 'p', 0700)
    writefile([json_encode(recent)], HistoryFile())
  catch
    # History is convenience state and must never break a live connection.
  endtry
enddef

def NormalizeSpec(value: any, name: string = ''): dict<any>
  if type(value) == v:t_string
    return {name: name, kind: 'ssh', target: value, root: ''}
  endif
  if type(value) != v:t_dict
    return {}
  endif
  var spec = copy(value)
  if !empty(name) && empty(get(spec, 'name', ''))
    spec.name = name
  endif
  var kind = get(spec, 'kind', 'ssh')
  var target = get(spec, 'target', '')
  if type(kind) != v:t_string || type(target) != v:t_string
        || (kind !=# 'ssh' && kind !=# 'docker') || empty(target)
    return {}
  endif
  spec.kind = kind
  spec.target = target
  spec.root = get(spec, 'root', '')
  return spec
enddef

def ConfiguredProfiles(): list<dict<any>>
  var profiles = get(g:, 'simpleremote_profiles', [])
  var result: list<dict<any>> = []
  if type(profiles) == v:t_dict
    for [name, value] in items(profiles)
      var spec = NormalizeSpec(value, name)
      if !empty(spec)
        add(result, spec)
      endif
    endfor
  elseif type(profiles) == v:t_list
    for value in profiles
      var spec = NormalizeSpec(value)
      if !empty(spec)
        add(result, spec)
      endif
    endfor
  endif
  return result
enddef

def SshSpecs(): list<dict<any>>
  var result: list<dict<any>> = []
  var files = get(g:, 'simpleremote_ssh_config_files', [expand('~/.ssh/config')])
  for file in files
    var expanded = expand(file)
    if !filereadable(expanded)
      continue
    endif
    for line in readfile(expanded)
      var match = matchlist(line, '^\s*Host\s\+\(.*\)$')
      if empty(match)
        continue
      endif
      for host in split(match[1])
        if host !~# '[*?!]' && host !~# '^-' && !empty(host)
          add(result, {kind: 'ssh', target: host, root: '', source: 'ssh'})
        endif
      endfor
    endfor
  endfor
  return result
enddef

def DockerSpecs(): list<dict<any>>
  if !executable('docker')
    return []
  endif
  var lines = systemlist('docker ps --format '
    .. shellescape('{{.Names}}\t{{.Image}}'))
  if v:shell_error != 0
    return []
  endif
  var result: list<dict<any>> = []
  for line in lines
    var fields = split(line, "\t", 1)
    if !empty(fields) && !empty(fields[0])
      add(result, {
        kind: 'docker',
        target: fields[0],
        root: '',
        detail: len(fields) > 1 ? fields[1] : '',
        source: 'docker',
      })
    endif
  endfor
  return result
enddef

def CandidateSpecs(kinds: list<string> = []): list<dict<any>>
  var result: list<dict<any>> = []
  var seen: dict<bool> = {}
  var candidates = ConfiguredProfiles() + RecentSpecs() + SshSpecs() + DockerSpecs()
  for value in candidates
    var spec = NormalizeSpec(value)
    if empty(spec) || (!empty(kinds) && index(kinds, spec.kind) < 0)
      continue
    endif
    var key = spec.kind .. "\t" .. spec.target .. "\t" .. get(spec, 'root', '')
    if has_key(seen, key)
      continue
    endif
    seen[key] = true
    add(result, spec)
  endfor
  return result
enddef

def SpecLabel(spec: dict<any>): string
  var name = get(spec, 'name', '')
  var root = get(spec, 'root', '')
  var detail = get(spec, 'detail', '')
  return printf('[%s] %s%s%s', spec.kind,
    empty(name) ? spec.target : name .. '  ' .. spec.target,
    empty(root) ? '' : '  ' .. root,
    empty(detail) ? '' : '  ' .. detail)
enddef

def ConnectSpec(spec: dict<any>)
  var root = get(spec, 'root', '')
  if empty(root)
    root = input(printf('%s %s folder: ', spec.kind, spec.target),
      get(g:, 'simpleremote_default_root', '/'))
  endif
  if empty(root)
    return
  endif
  if root !~# '^/'
    Error('[SimpleRemote] workspace folder must be absolute')
    return
  endif
  Connect(spec.kind, spec.target, root, spec)
enddef

def SelectCandidate(specs: list<dict<any>>, result: number)
  if result <= 0 || result > len(specs)
    return
  endif
  ConnectSpec(specs[result - 1])
enddef

def PickTargets(kinds: list<string> = [])
  var specs = CandidateSpecs(kinds)
  if empty(specs)
    var kind_choice = confirm('SimpleRemote transport', "&SSH\n&Docker\n&Cancel", 1)
    if kind_choice == 3 || kind_choice == 0
      return
    endif
    var kind = kind_choice == 1 ? 'ssh' : 'docker'
    var target = input(kind .. ' target: ')
    if !empty(target)
      ConnectSpec({kind: kind, target: target, root: ''})
    endif
    return
  endif
  var labels = mapnew(specs, (_, spec) => SpecLabel(spec))
  if exists('*popup_menu') == 1
    popup_menu(labels, {
      title: ' SimpleRemote targets ',
      callback: (_id, result) => SelectCandidate(specs, result),
      maxheight: min([18, &lines - 4]),
      minwidth: min([72, &columns - 4]),
    })
  else
    SelectCandidate(specs, inputlist(['SimpleRemote targets:'] + labels))
  endif
enddef

def RemoteParent(path: string): string
  if path ==# '/'
    return '/'
  endif
  var parent = substitute(path, '/[^/]\+$', '', '')
  return empty(parent) ? '/' : parent
enddef

def RenderRemoteTree(buf: number, path: string, ok: bool, body: string)
  if !bufexists(buf) || get(s_tree, 'buf', -1) != buf
    return
  endif
  var lines = [
    printf('SimpleRemote  %s:%s', s_remote.kind, s_remote.target),
    path,
    '',
  ]
  var nodes: list<dict<any>> = [{}, {}, {}]
  if !ok
    add(lines, '! ' .. body)
    add(nodes, {})
  else
    if path !=# '/'
      add(lines, '../')
      add(nodes, {name: '..', path: RemoteParent(path), type: 'd'})
    endif
    var directories: list<dict<any>> = []
    var files: list<dict<any>> = []
    for line in split(body, '\n')
      var fields = split(line, "\t", 1)
      if len(fields) < 2 || empty(fields[0])
        continue
      endif
      var node = {
        name: fields[0],
        path: JoinRemotePath(path, fields[0]),
        type: fields[1],
      }
      if fields[1] ==# 'd'
        add(directories, node)
      else
        add(files, node)
      endif
    endfor
    for node in directories + files
      add(lines, (node.type ==# 'd' ? '+ ' : '  ') .. node.name
        .. (node.type ==# 'd' ? '/' : ''))
      add(nodes, node)
    endfor
  endif
  setbufvar(buf, '&modifiable', 1)
  setbufline(buf, 1, lines)
  var old_count = len(getbufline(buf, 1, '$'))
  if old_count > len(lines)
    deletebufline(buf, len(lines) + 1, old_count)
  endif
  setbufvar(buf, 'simpleremote_tree_nodes', nodes)
  setbufvar(buf, 'simpleremote_tree_path', path)
  setbufvar(buf, '&modifiable', 0)
  var reveal = get(s_tree, 'reveal', '')
  if !empty(reveal)
    for index in range(0, len(nodes) - 1)
      if get(nodes[index], 'path', '') ==# reveal
        var winid = bufwinid(buf)
        if winid > 0
          win_execute(winid, printf('cursor(%d, 1)', index + 1))
        endif
        break
      endif
    endfor
    s_tree.reveal = ''
  endif
enddef

def LoadRemoteTree(path: string)
  if !IsReady() || empty(s_tree)
    return
  endif
  var buf = s_tree.buf
  setbufvar(buf, '&modifiable', 1)
  setbufline(buf, 1, [
    printf('SimpleRemote  %s:%s', s_remote.kind, s_remote.target),
    path,
    '',
    '  loading...',
  ])
  setbufvar(buf, '&modifiable', 0)
  Send('list', path, (ok, body) => RenderRemoteTree(buf, path, ok, body))
enddef

def OpenRemoteTree(path: string, reveal: string = '')
  if !IsReady()
    Error('[SimpleRemote] not connected')
    return
  endif
  var existing = get(s_tree, 'buf', -1)
  if existing > 0 && bufexists(existing)
    var winid = bufwinid(existing)
    if winid > 0
      win_gotoid(winid)
    endif
    s_tree.reveal = reveal
    LoadRemoteTree(path)
    return
  endif
  var source_win = win_getid()
  var width = max([24, get(g:, 'simpleremote_tree_width', 40)])
  execute 'silent keepalt leftabove vnew ' .. fnameescape('[SimpleRemote]')
  execute 'vertical resize ' .. width
  var buf = bufnr()
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  setlocal nowrap nonumber norelativenumber signcolumn=no foldcolumn=0
  setlocal cursorline nomodified
  &l:filetype = 'simpleremotetree'
  &l:statusline = '%{g:SimpleRemoteTreeStatusline()}'
  nnoremap <silent><buffer> q <Cmd>call g:SimpleRemoteTreeClose()<CR>
  nnoremap <silent><buffer> <Esc> <Cmd>call g:SimpleRemoteTreeClose()<CR>
  nnoremap <silent><buffer> <CR> <Cmd>call g:SimpleRemoteTreeActivate('edit')<CR>
  nnoremap <silent><buffer> l <Cmd>call g:SimpleRemoteTreeActivate('edit')<CR>
  nnoremap <silent><buffer> s <Cmd>call g:SimpleRemoteTreeActivate('split')<CR>
  nnoremap <silent><buffer> v <Cmd>call g:SimpleRemoteTreeActivate('vsplit')<CR>
  nnoremap <silent><buffer> t <Cmd>call g:SimpleRemoteTreeActivate('tabedit')<CR>
  nnoremap <silent><buffer> h <Cmd>call g:SimpleRemoteTreeParent()<CR>
  nnoremap <silent><buffer> <BS> <Cmd>call g:SimpleRemoteTreeParent()<CR>
  nnoremap <silent><buffer> r <Cmd>call g:SimpleRemoteTreeRefresh()<CR>
  s_tree = {buf: buf, source_win: source_win, reveal: reveal}
  LoadRemoteTree(path)
enddef

def OpenWorkspaceTree()
  if empty(s_remote) || !IsReady()
    if exists(':SimpleTree') == 2
      execute 'SimpleTree'
    elseif exists(':Explore') == 2
      execute 'Explore'
    endif
    return
  endif
  var local_root = get(s_remote, 'local_root', '')
  if !empty(local_root)
    CloseRemoteTree()
    if exists(':SimpleTree') == 2
      execute 'SimpleTree ' .. fnameescape(local_root)
    elseif exists(':Explore') == 2
      execute 'Explore ' .. fnameescape(local_root)
    endif
    return
  endif
  OpenRemoteTree(s_remote.root)
enddef

def RemoteTreeActivate(action: string)
  var nodes = get(b:, 'simpleremote_tree_nodes', [])
  var index = line('.') - 1
  if index < 0 || index >= len(nodes) || empty(nodes[index])
    return
  endif
  var node = nodes[index]
  if node.type ==# 'd'
    LoadRemoteTree(node.path)
    return
  endif
  var source_win = get(s_tree, 'source_win', 0)
  if source_win > 0 && win_id2win(source_win) > 0
    win_gotoid(source_win)
  else
    wincmd p
    s_tree.source_win = win_getid()
  endif
  if action ==# 'edit'
    OpenRemote(node.path)
  else
    execute action .. ' ' .. fnameescape('remote://' .. node.path)
  endif
enddef

def RemoteActions(result: number)
  if result <= 0
    return
  endif
  if result == 1
    OpenWorkspaceTree()
  elseif result == 2
    g:SimpleRemoteTerminal()
  elseif result == 3
    g:VimrcRemotePromptFind()
  elseif result == 4
    g:SimpleRemoteReconnect()
  elseif result == 5
    g:SimpleRemoteShowStatus()
  elseif result == 6
    g:VimrcRemoteHealth()
  elseif result == 7
    g:SimpleRemoteInstallAgent()
  elseif result == 8
    Disconnect()
  endif
enddef

def OpenRemoteUI()
  if !IsReady()
    PickTargets()
    return
  endif
  var actions = [
    'Workspace tree',
    'Remote terminal',
    'Find remote file',
    'Reconnect',
    'Connection status',
    'Health check',
    'Install/update agent',
    'Disconnect',
  ]
  if exists('*popup_menu') == 1
    popup_menu(actions, {
      title: ' SimpleRemote ',
      callback: (_id, result) => RemoteActions(result),
      minwidth: 36,
    })
  else
    RemoteActions(inputlist(['SimpleRemote:'] + actions))
  endif
enddef

def AgentSourcePath(): string
  return fnamemodify(expand('<sfile>:p'), ':h:h')
    .. '/bin/simpleremote-agent.sh'
enddef

def InstallAgent(spec: dict<any>)
  var source = AgentSourcePath()
  if !filereadable(source)
    Error('[SimpleRemote] bundled agent is missing: ' .. source)
    return
  endif
  var agent = AgentPath()
  var destination = strpart(agent, 0, 2) ==# '~/'
    ? '"$HOME"/' .. shellescape(strpart(agent, 2))
    : shellescape(agent)
  var script = 'set -eu; dst=' .. destination
    .. '; dir=$(dirname -- "$dst"); umask 077; mkdir -p "$dir"; '
    .. 'tmp="$dst.tmp.$$"; trap ''rm -f "$tmp"'' EXIT HUP INT TERM; '
    .. 'cat > "$tmp"; chmod 700 "$tmp"; mv -f "$tmp" "$dst"; trap - EXIT'
  var command: list<string>
  if spec.kind ==# 'docker'
    command = ['docker', 'exec', '-i', spec.target, 'sh', '-c', script]
  else
    command = ['ssh', '-T', spec.target, 'sh', '-c', ShellLiteral(script)]
  endif
  var content = join(readfile(source, 'b'), "\n") .. "\n"
  system(ShellCommand(command), content)
  if v:shell_error == 0
    echomsg printf('[SimpleRemote] agent installed on %s:%s',
      spec.kind, spec.target)
  else
    Error('[SimpleRemote] agent installation failed')
  endif
enddef

def g:SimpleRemoteUI()
  OpenRemoteUI()
enddef

def g:SimpleRemoteConnect(kind: string, target: string, root: string)
  Connect(kind, target, root, {kind: kind, target: target, root: root})
enddef

def g:SimpleRemoteConnectCommand(...args: list<string>)
  if empty(args)
    PickTargets()
    return
  endif
  if len(args) == 1
    for spec in ConfiguredProfiles()
      if get(spec, 'name', '') ==# args[0]
        ConnectSpec(spec)
        return
      endif
    endfor
    ConnectSpec({kind: 'ssh', target: args[0], root: ''})
    return
  endif
  if len(args) == 2
    ConnectSpec({kind: args[0], target: args[1], root: ''})
    return
  endif
  ConnectSpec({kind: args[0], target: args[1], root: join(args[2 :], ' ')})
enddef

def g:SimpleRemoteReconnect()
  var spec = !empty(s_remote)
    ? extend(copy(get(s_remote, 'options', {})), {
        kind: s_remote.kind, target: s_remote.target, root: s_remote.root,
      }, 'force')
    : copy(s_last_spec)
  if empty(spec)
    PickTargets()
  else
    ConnectSpec(spec)
  endif
enddef

def g:SimpleRemoteShowStatus()
  if empty(s_remote)
    echomsg '[SimpleRemote] disconnected'
    return
  endif
  var workspace = WorkspaceSnapshot()
  echomsg printf('[SimpleRemote] %s %s:%s [%s]%s',
    workspace.kind, workspace.target, workspace.root, workspace.mode,
    empty(workspace.local_root) ? '' : ' -> ' .. workspace.local_root)
enddef

def g:SimpleRemoteTreeToggle()
  var buf = get(s_tree, 'buf', -1)
  if buf > 0 && bufwinid(buf) > 0
    CloseRemoteTree()
  else
    OpenWorkspaceTree()
  endif
enddef

def g:SimpleRemoteTreeReveal()
  if !IsReady() || bufname() !~# '^remote://'
    if exists(':SimpleTreeReveal') == 2
      execute 'SimpleTreeReveal'
    else
      OpenWorkspaceTree()
    endif
    return
  endif
  var path = get(get(b:, 'vimrc_remote', {}), 'path', '')
  if !empty(path)
    OpenRemoteTree(RemoteParent(path), path)
  endif
enddef

def g:SimpleRemoteTreeActivate(action: string = 'edit')
  RemoteTreeActivate(action)
enddef

def g:SimpleRemoteTreeParent()
  LoadRemoteTree(RemoteParent(get(b:, 'simpleremote_tree_path', s_remote.root)))
enddef

def g:SimpleRemoteTreeRefresh()
  LoadRemoteTree(get(b:, 'simpleremote_tree_path', s_remote.root))
enddef

def g:SimpleRemoteTreeClose()
  CloseRemoteTree()
enddef

def g:SimpleRemoteTreeStatusline(): string
  return empty(s_remote) ? ' SimpleRemote ' : printf(' %s:%s  %s ',
    s_remote.kind, s_remote.target,
    get(b:, 'simpleremote_tree_path', s_remote.root))
enddef

def g:SimpleRemoteTerminal()
  if !IsReady()
    Error('[SimpleRemote] not connected')
    return
  endif
  var command: list<string>
  if s_remote.kind ==# 'docker'
    command = ['docker', 'exec', '-it', '-w', s_remote.root,
      s_remote.target, 'sh']
  else
    var script = 'cd ' .. shellescape(s_remote.root)
      .. ' && exec "${SHELL:-sh}" -l'
    command = ['ssh', '-t', s_remote.target, 'sh', '-lc', ShellLiteral(script)]
  endif
  botright new
  term_start(command, {
    curwin: true,
    term_name: printf('SimpleRemote:%s:%s', s_remote.kind, s_remote.target),
  })
  startinsert
enddef

def g:SimpleRemoteInstallAgent()
  var spec = !empty(s_remote) ? {
    kind: s_remote.kind, target: s_remote.target, root: s_remote.root,
  } : copy(s_last_spec)
  if empty(spec)
    Error('[SimpleRemote] select or connect to a target first')
    return
  endif
  InstallAgent(spec)
enddef

def g:SimpleRemoteWorkspace(path: string = '')
  if !IsReady()
    PickTargets()
  elseif empty(path)
    OpenWorkspaceTree()
  elseif path =~# '^/'
    Connect(s_remote.kind, s_remote.target, path, copy(s_remote.options))
  else
    Error('[SimpleRemote] workspace folder must be absolute')
  endif
enddef

def g:SimpleRemoteActivateLocalBuffer()
  if !IsReady() || empty(get(s_remote, 'local_root', '')) || &buftype !=# ''
    return
  endif
  var local_path = substitute(resolve(expand('%:p')), '[\\/]\+$', '', '')
  if !UnderRoot(local_path, s_remote.local_root)
    return
  endif
  var suffix = strpart(local_path, len(s_remote.local_root))
  b:simpleremote_workspace_id = s_remote.generation
  b:simpleremote_path = s_remote.root ==# '/'
    ? '/' .. substitute(suffix, '^/', '', '')
    : s_remote.root .. suffix
enddef

def g:SimpleRemoteWorkspaceRoot(): string
  return empty(s_remote) ? '' : s_remote.root
enddef

def g:SimpleRemoteProjectRoot(_path: string = ''): string
  if empty(s_remote)
    return ''
  endif
  return empty(get(s_remote, 'local_root', ''))
    ? s_remote.root : s_remote.local_root
enddef

def g:SimpleRemoteIsVirtual(): bool
  return IsReady() && empty(get(s_remote, 'local_root', ''))
enddef

def g:SimpleRemoteLocalPath(remote_path: string): string
  if empty(s_remote) || empty(get(s_remote, 'local_root', ''))
        || !UnderRoot(remote_path, s_remote.root)
    return ''
  endif
  return s_remote.local_root .. strpart(remote_path, len(s_remote.root))
enddef

def g:SimpleRemoteRemotePath(local_path: string): string
  if empty(s_remote) || empty(get(s_remote, 'local_root', ''))
        || !UnderRoot(local_path, s_remote.local_root)
    return ''
  endif
  return s_remote.root .. strpart(local_path, len(s_remote.local_root))
enddef

def g:SimpleRemoteShellCommand(command: string): list<string>
  if !IsReady()
    return []
  endif
  var script = 'cd ' .. shellescape(s_remote.root) .. ' && ' .. command
  return s_remote.kind ==# 'docker'
    ? ['docker', 'exec', '-i', s_remote.target, 'sh', '-c', script]
    : ['ssh', '-T', s_remote.target, 'sh', '-c', ShellLiteral(script)]
enddef

def g:SimpleRemoteStatusline(): string
  return empty(s_remote) ? '' : printf('%s:%s:%s',
    s_remote.kind, s_remote.target, fnamemodify(s_remote.root, ':t'))
enddef

def g:SimpleRemoteComplete(arglead: string, _cmdline: string,
    _cursorpos: number): list<string>
  var values: list<string> = []
  for spec in ConfiguredProfiles() + RecentSpecs() + SshSpecs()
    var value = empty(get(spec, 'name', '')) ? spec.target : spec.name
    if stridx(value, arglead) == 0 && index(values, value) < 0
      add(values, value)
    endif
  endfor
  return values
enddef

def g:VimrcRemoteConnect(kind: string, target: string, root: string)
  Connect(kind, target, root)
enddef

def g:VimrcRemoteDisconnect()
  Disconnect()
enddef

def g:VimrcRemoteOpen(path: string)
  OpenRemote(path)
enddef

def g:VimrcRemoteRead(uri: string)
  ReadRemote(uri)
enddef

def g:VimrcRemoteWrite()
  WriteRemote()
enddef

def g:VimrcRemoteExec(command: string)
  RemoteExec(command)
enddef

def g:VimrcRemoteFind(query: string)
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  RemoteFind(query)
enddef

def g:VimrcRemotePromptFind()
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  var query = input('remote files: ')
  if !empty(query)
    g:VimrcRemoteFind(query)
  endif
enddef

def g:VimrcRemoteList(path: string = '')
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  RemoteList(path)
enddef

def g:VimrcRemoteHealth()
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  RemoteHealth()
enddef

def g:VimrcRemoteReloadConfig()
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  if !get(s_remote, 'handshake_ready', false)
    Error('[VimrcRemote] connection is not ready')
    return
  endif
  var generation = s_remote.generation
  var buf = bufnr()
  FetchRemoteConfig(generation, (applied) => {
    if IsCurrent(generation)
      if !get(s_remote, 'connection_announced', false)
        # A manual reload can supersede the initial config request.  Whichever
        # request owns the newest epoch must also finish the handshake.
        FinishConnection(generation)
      else
        s_remote.state = 'ready'
        var queued = copy(s_remote.open_queue)
        s_remote.open_queue = []
        for path in queued
          OpenRemote(path)
        endfor
      endif
      if applied
        s_remote.simplecc_restart_pending = true
        RestartSimpleCC(generation, buf)
      endif
    endif
  })
enddef

def g:VimrcRemoteGit(command: string)
  if empty(s_remote)
    Error('[VimrcRemote] not connected')
    return
  endif
  RemoteGit(command)
enddef

def g:VimrcRemoteActivateBuffer()
  if bufname() !~# '^remote://'
    return
  endif
  var pending = get(b:, 'vimrc_remote_read', {})
  if !empty(pending)
    if !&modified
      pending.tick = b:changedtick
      b:vimrc_remote_read = pending
    endif
    return
  endif
  DetectRemoteFiletype(bufnr())
  var writepost = get(b:, 'vimrc_remote_writepost_pending', {})
  b:vimrc_remote_writepost_pending = {}
  var info = get(b:, 'vimrc_remote', {})
  if type(writepost) == v:t_dict && !empty(writepost)
    var current_write = IsCurrent(get(writepost, 'generation', -1))
          && get(info, 'generation', -1) == get(writepost, 'generation', -2)
          && b:changedtick == get(writepost, 'tick', -1) && !&modified
    if current_write
          && BufferHasFinalEol(bufnr()) == get(writepost, 'final_eol', false)
      execute 'silent doautocmd <nomodeline> BufWritePost'
    elseif current_write
      # A script may alter EOL/binary options while the buffer is hidden;
      # Vim does not mark that byte-level change modified on its own.
      setlocal modified
    endif
  endif
  MaybeStartSimpleCC(bufnr())
enddef

command! -nargs=+ VimrcRemoteConnect call g:VimrcRemoteConnect(<f-args>)
command! VimrcRemoteDisconnect call g:VimrcRemoteDisconnect()
command! -nargs=1 VimrcRemoteOpen call g:VimrcRemoteOpen(<q-args>)
command! -nargs=0 VimrcRemoteWrite call g:VimrcRemoteWrite()
command! -nargs=+ VimrcRemoteExec call g:VimrcRemoteExec(<q-args>)
command! -nargs=1 VimrcRemoteFind call g:VimrcRemoteFind(<q-args>)
command! -nargs=? VimrcRemoteList call g:VimrcRemoteList(<q-args>)
command! -nargs=+ VimrcRemoteGit call g:VimrcRemoteGit(<q-args>)
command! VimrcRemoteHealth call g:VimrcRemoteHealth()
command! VimrcRemoteReloadConfig call g:VimrcRemoteReloadConfig()
command! VimrcRemoteStatus echo get(g:, 'vimrc_remote_status', 'disconnected')

def g:VimrcConfigureRemote()
  Disconnect(false)
  augroup vimrc_remote
    autocmd!
    autocmd BufReadCmd remote://* call g:VimrcRemoteRead(expand('<amatch>'))
    autocmd BufWriteCmd remote://* call g:VimrcRemoteWrite()
    autocmd BufEnter remote://* call g:VimrcRemoteActivateBuffer()
    autocmd BufEnter * call g:SimpleRemoteActivateLocalBuffer()
    autocmd VimLeavePre * call g:VimrcRemoteDisconnect()
  augroup END
enddef

g:VimrcConfigureRemote()
