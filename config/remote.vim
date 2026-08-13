vim9script

# Local UI / remote filesystem bridge.  The remote side is intentionally not
# Vim-specific: it is a small shell agent speaking a line protocol.
var s_remote: dict<any> = {}
var s_next_id = 0
var s_generation = 0
var s_base64_decode_flag = ''

const PROTOCOL = 'simpleremote/2'

g:vimrc_remote_status = 'disconnected'

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

def IsCurrent(generation: number): bool
  return !empty(s_remote) && get(s_remote, 'generation', -1) == generation
enddef

def IsReady(): bool
  return !empty(s_remote) && get(s_remote, 'state', '') ==# 'ready'
enddef

def ClearGlobals()
  g:vimrc_remote_status = 'disconnected'
  unlet! g:vimrc_remote_workspace
  unlet! g:vimrc_remote_simplecc_config
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
  ClearGlobals()
  FailPending(remote, printf('connection closed (%d)', status))
  StopSimpleCC(remote)
  var detail = empty(remote.stderr) ? '' : ': ' .. remote.stderr[-1]
  echomsg printf('[VimrcRemote] connection closed (%d)%s', status, detail)
enddef

def AgentPath(): string
  return get(g:, 'vimrc_remote_agent', '~/.cache/vimrc/simpleremote-agent.sh')
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
    return ['docker', 'exec', '-i', target, 'sh', '-lc',
      DockerAgentCommand(agent)]
  endif
  var script = 'exec ' .. (strpart(agent, 0, 2) ==# '~/'
    ? '"$HOME"/' .. ShellLiteral(strpart(agent, 2))
    : ShellLiteral(agent))
  # OpenSSH joins all arguments after the host into one login-shell command.
  # Quote the complete -c script so that boundary survives that re-serialization.
  return ['ssh', '-T', target, 'sh', '-lc', ShellLiteral(script)]
enddef

def StopSimpleCC(remote: dict<any>)
  if get(remote, 'simplecc_started', false) && exists(':SimpleCCStop') == 2
    execute 'silent! SimpleCCStop'
  endif
enddef

def Disconnect(show_message: bool = true)
  if empty(s_remote)
    ClearGlobals()
    return
  endif
  var remote = s_remote
  s_generation += 1
  s_remote = {}
  ClearGlobals()
  FailPending(remote, 'connection closed')
  StopSimpleCC(remote)
  var job = get(remote, 'job', v:null)
  if job != v:null && job_status(job) ==# 'run'
    job_stop(job, 'term')
  endif
  if show_message
    echomsg '[VimrcRemote] disconnected'
  endif
enddef

def FinishConnection(generation: number)
  if !IsCurrent(generation)
    return
  endif
  s_remote.state = 'ready'
  s_remote.connection_announced = true
  g:vimrc_remote_status = printf('%s:%s', s_remote.kind, s_remote.target)
  echomsg printf('[VimrcRemote] connected %s:%s', s_remote.target, s_remote.root)

  var queued = copy(s_remote.open_queue)
  s_remote.open_queue = []
  for path in queued
    OpenRemote(path)
  endfor
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

def Connect(kind: string, target: string, root: string)
  if kind !=# 'ssh' && kind !=# 'docker'
    Error('[VimrcRemote] transport must be ssh or docker')
    return
  endif
  if empty(target) || target =~# '^-' || root !~# '^/'
    Error('[VimrcRemote] target is required and root must be absolute')
    return
  endif

  Disconnect(false)
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
  }
  g:vimrc_remote_status = printf('connecting %s:%s', kind, target)
  unlet! g:vimrc_remote_workspace
  unlet! g:vimrc_remote_simplecc_config

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
    autocmd VimLeavePre * call g:VimrcRemoteDisconnect()
  augroup END
enddef

g:VimrcConfigureRemote()
