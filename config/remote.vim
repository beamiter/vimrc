vim9script

# Local UI / remote filesystem bridge.  The remote side is intentionally not
# Vim-specific: it is a small POSIX-shell agent speaking a line protocol.
var C = g:vimrc_context
var s_remote: dict<any> = {}
var s_next_id = 0
var s_remote_config_ready = false

def B64(value: string): string
  return system('base64 -w 0', value)->substitute('\n', '', 'g')
enddef

def UnB64(value: string): string
  return system('base64 -d', value)
enddef

def Send(op: string, payload: string, Callback: func): number
  if empty(s_remote) || get(s_remote, 'job', v:null) == v:null
    echoerr '[VimrcRemote] not connected'
    return -1
  endif
  s_next_id += 1
  var id = s_next_id
  s_remote.pending[string(id)] = Callback
  ch_sendraw(s_remote.channel, id .. "\t" .. op .. "\t" .. B64(payload) .. "\n")
  return id
enddef

def OnLine(_channel: any, line: string)
  var parts = split(line, "\t", 1)
  if len(parts) < 3 || !has_key(s_remote.pending, parts[0])
    return
  endif
  var Callback = s_remote.pending[parts[0]]
  remove(s_remote.pending, parts[0])
  call(Callback, [parts[1] ==# 'ok', UnB64(parts[2])])
enddef

def OnExit(_job: any, status: number)
  s_remote = {}
  s_remote_config_ready = false
  unlet! g:vimrc_remote_workspace
  echomsg printf('[VimrcRemote] connection closed (%d)', status)
enddef

def AgentPath(): string
  return get(g:, 'vimrc_remote_agent', '~/.cache/vimrc/simpleremote-agent.sh')
enddef

def TargetCommand(kind: string, target: string, agent: string): list<string>
  if kind ==# 'docker'
    return ['docker', 'exec', '-i', target, 'sh', '-lc',
      'exec "$HOME/.cache/vimrc/simpleremote-agent.sh"']
  endif
  return ['ssh', '-T', target, 'sh', agent]
enddef

def Connect(kind: string, target: string, root: string)
  if kind !=# 'ssh' && kind !=# 'docker'
    echoerr '[VimrcRemote] transport must be ssh or docker'
    return
  endif
  var job = job_start(TargetCommand(kind, target, AgentPath()), {
    in_io: 'pipe', out_io: 'pipe', err_io: 'pipe', out_mode: 'nl',
    out_cb: OnLine, exit_cb: OnExit})
  if job_status(job) ==# 'fail'
    echoerr '[VimrcRemote] cannot start transport'
    return
  endif
  s_remote = {job: job, channel: job_getchannel(job), pending: {},
    kind: kind, target: target, root: root}
  s_remote_config_ready = false
  g:vimrc_remote_workspace = {kind: kind, target: target, root: root}
  Send('ping', '', (ok, body) => {
    if ok
      echomsg printf('[VimrcRemote] connected %s:%s (%s)', target, root, body)
      g:vimrc_remote_status = printf('%s:%s', kind, target)
      FetchRemoteConfig()
    else
      echoerr '[VimrcRemote] remote agent rejected connection: ' .. body
    endif
  })
enddef

def FetchRemoteConfig()
  Send('read-config', s_remote.root .. '/simplecc.json', (ok, body) => {
    if !ok
      s_remote_config_ready = true
      echomsg '[VimrcRemote] no remote simplecc.json; using SimpleCC defaults'
      return
    endif
    var config = UnB64(body)
    try
      json_decode(config)
      g:vimrc_remote_simplecc_config = config
      s_remote_config_ready = true
      echomsg '[VimrcRemote] remote SimpleCC config loaded'
    catch
      echoerr '[VimrcRemote] invalid remote simplecc.json: ' .. v:exception
    endtry
  })
enddef

def CachePath(remote_path: string): string
  var key = substitute(remote_path, '[^A-Za-z0-9_.-]', '_', 'g')
  return C.vim_state .. '/remote/' .. key
enddef

def OpenRemote(path: string)
  if empty(s_remote)
    echoerr '[VimrcRemote] not connected'
    return
  endif
  var remote_path = path =~# '^/' ? path : s_remote.root .. '/' .. path
  if !s_remote_config_ready
    timer_start(50, (_) => OpenRemote(path))
    return
  endif
  execute 'edit ' .. fnameescape('remote://' .. remote_path)
enddef

def ReadRemote(uri: string)
  var remote_path = substitute(uri, '^remote://', '', '')
  Send('read', remote_path, (ok, body) => {
    if !ok
      echoerr '[VimrcRemote] ' .. body
      return
    endif
    body = UnB64(body)
    setline(1, split(body, '\n', 1))
    setlocal nomodified buftype=acwrite
    b:vimrc_remote = {path: remote_path, local: CachePath(remote_path)}
    execute 'file ' .. fnameescape(uri)
    filetype detect
  })
enddef

def WriteRemote()
  var info = get(b:, 'vimrc_remote', {})
  if empty(info)
    return
  endif
  var content = join(getbufline(bufnr(), 1, '$'), "\n")
  if &fixendofline
    content ..= "\n"
  endif
  Send('write', info.path .. "\t" .. content, (ok, body) => {
    if ok
      setlocal nomodified
      echomsg '[VimrcRemote] saved ' .. body
    else
      echoerr '[VimrcRemote] save failed: ' .. body
    endif
  })
enddef

def RemoteExec(command: string)
  Send('exec', 'cd ' .. shellescape(s_remote.root) .. ' && ' .. command,
    (ok, body) => {
      if ok
        echomsg body
      else
        echoerr '[VimrcRemote] ' .. body
      endif
    })
enddef

def RemoteFind(query: string)
  var command = 'rg --files --hidden --glob ' .. shellescape('!.git/*')
        .. ' | rg --smart-case ' .. shellescape(query)
  Send('grep', 'cd ' .. shellescape(s_remote.root) .. ' && ' .. command,
    (ok, body) => {
      if !ok
        echoerr '[VimrcRemote] ' .. body
        return
      endif
      var entries: list<dict<any>> = []
      for line in split(body, '\n')
        if !empty(line)
          add(entries, {filename: 'remote://' .. s_remote.root .. '/' .. line})
        endif
      endfor
      setqflist([], ' ', {title: 'Remote files: ' .. query, items: entries})
      copen
    })
enddef

def RemoteList(path: string)
  var remote_path = path ==# '' ? s_remote.root
        : path =~# '^/' ? path : s_remote.root .. '/' .. path
  Send('list', remote_path, (ok, body) => {
    if !ok
      echoerr '[VimrcRemote] ' .. body
      return
    endif
    var items: list<dict<any>> = []
    for line in split(body, '\n')
      var fields = split(line, "\t", 1)
      if len(fields) < 2 || empty(fields[0])
        continue
      endif
      var child = remote_path .. '/' .. fields[0]
      add(items, {filename: 'remote://' .. child,
        text: fields[0] .. (fields[1] ==# 'd' ? '/' : '')})
    endfor
    setqflist([], ' ', {title: 'Remote tree: ' .. remote_path, items: items})
    copen
  })
enddef

def RemoteHealth()
  Send('exec', 'printf "host=%s\\npwd=%s\\n" "$(hostname 2>/dev/null || true)" "$PWD"; '
        .. 'command -v git || true; command -v rg || true', (ok, body) => {
    if ok
      echomsg '[VimrcRemote] ' .. body
    else
      echoerr '[VimrcRemote] ' .. body
    endif
  })
enddef

def RemoteGit(command: string)
  Send('exec', 'cd ' .. shellescape(s_remote.root) .. ' && git ' .. command,
    (ok, body) => {
      if !ok
        echoerr '[VimrcRemote] ' .. body
        return
      endif
      var lines = split(body, '\n')
      var items: list<dict<any>> = []
      for line in lines
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
    echoerr '[VimrcRemote] not connected'
    return
  endif
  RemoteFind(query)
enddef

def g:VimrcRemoteList(path: string = '')
  if empty(s_remote)
    echoerr '[VimrcRemote] not connected'
    return
  endif
  RemoteList(path)
enddef

def g:VimrcRemoteHealth()
  if empty(s_remote)
    echoerr '[VimrcRemote] not connected'
    return
  endif
  RemoteHealth()
enddef

def g:VimrcRemoteReloadConfig()
  if empty(s_remote)
    echoerr '[VimrcRemote] not connected'
    return
  endif
  FetchRemoteConfig()
  silent! SimpleCCRestart
enddef

def g:VimrcRemoteGit(command: string)
  if empty(s_remote)
    echoerr '[VimrcRemote] not connected'
    return
  endif
  RemoteGit(command)
enddef

command! -nargs=+ VimrcRemoteConnect call g:VimrcRemoteConnect(<f-args>)
command! -nargs=1 VimrcRemoteOpen call g:VimrcRemoteOpen(<q-args>)
command! -nargs=0 VimrcRemoteWrite call g:VimrcRemoteWrite()
command! -nargs=+ VimrcRemoteExec call g:VimrcRemoteExec(<q-args>)
command! -nargs=1 VimrcRemoteFind call g:VimrcRemoteFind(<q-args>)
command! -nargs=? VimrcRemoteList call g:VimrcRemoteList(<q-args>)
command! -nargs=+ VimrcRemoteGit call g:VimrcRemoteGit(<q-args>)
command! VimrcRemoteHealth call g:VimrcRemoteHealth()
command! VimrcRemoteReloadConfig call g:VimrcRemoteReloadConfig()
command! VimrcRemoteStatus echo get(g:, 'vimrc_remote_status', 'disconnected')

augroup vimrc_remote
  autocmd!
  autocmd BufReadCmd remote://* call g:VimrcRemoteRead(expand('<amatch>'))
  autocmd BufWriteCmd remote://* call g:VimrcRemoteWrite()
augroup END
