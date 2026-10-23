vim9script

# Keep closed-file history across configuration reloads, bounded and in memory.
if !exists('g:vimrc_closed_buffers')
  g:vimrc_closed_buffers = []
endif
if !exists('g:vimrc_closed_serial')
  g:vimrc_closed_serial = 0
endif

def FileBuffer(number: number): bool
  return index(['', 'acwrite'], getbufvar(number, '&buftype')) >= 0
enddef

def Replacement(number: number): number
  var alternate = bufnr('#')
  if alternate > 0 && alternate != number && buflisted(alternate) && FileBuffer(alternate)
    return alternate
  endif
  for info in getbufinfo({buflisted: 1})
    if info.bufnr != number && FileBuffer(info.bufnr)
      return info.bufnr
    endif
  endfor
  var replacement = bufadd('')
  setbufvar(replacement, '&buflisted', 1)
  return replacement
enddef

def g:VimrcCloseBuffer(number: number = 0)
  var target = number > 0 ? number : bufnr()
  if !bufexists(target) || !buflisted(target)
    throw 'The requested buffer is no longer open'
  endif
  if get(getbufvar(target, 'vimrc_remote_write_state', {}), 'status', '') ==# 'pending'
    throw 'Remote write pending: wait for its acknowledgement before closing this buffer'
  endif
  if getbufvar(target, '&modified')
    throw 'Unsaved changes: save this buffer before closing it'
  endif
  if !FileBuffer(target)
    throw 'This buffer belongs to a plugin; close its window with :close'
  endif
  var origin = win_getid()
  var name = getbufinfo(target)[0].name
  g:vimrc_closed_serial += 1
  var entry: dict<any> = {name: name, buffer: target, serial: g:vimrc_closed_serial, view: {lnum: 1, col: 0}}
  var windows = win_findbuf(target)
  if index(windows, origin) >= 0
    entry.view = winsaveview()
  elseif !empty(windows)
    var position = getcurpos(windows[0])
    entry.view = {lnum: position[1], col: position[2] - 1}
  endif
  try
    # Switch each existing window before bdelete so Vim keeps split/tab geometry.
    for window in windows
      var replacement = Replacement(target)
      win_execute(window, 'keepalt keepjumps buffer ' .. replacement)
    endfor
    if !empty(win_findbuf(target))
      throw 'A plugin kept the buffer visible; close was cancelled'
    endif
    execute 'bdelete ' .. target
    if !empty(name)
      filter(g:vimrc_closed_buffers, (_, closed) => closed.name !=# name)
      insert(g:vimrc_closed_buffers, entry)
      if len(g:vimrc_closed_buffers) > 20
        remove(g:vimrc_closed_buffers, 20, -1)
      endif
    endif
  finally
    win_gotoid(origin)
  endtry
enddef

def g:VimrcCanReopenBuffer(): bool
  return type(g:vimrc_closed_buffers) == v:t_list && !empty(g:vimrc_closed_buffers)
enddef

def g:VimrcReopenBuffer()
  if !g:VimrcCanReopenBuffer()
    throw 'No recently closed file'
  endif
  var entry = g:vimrc_closed_buffers[0]
  if entry.name =~# '^remote://'
    # Arm before :edit so both synchronous and asynchronous transports can
    # acknowledge success. A failed/no-op BufReadCmd must not consume history.
    var target = bufadd(entry.name)
    setbufvar(target, 'vimrc_reopen_pending', deepcopy(entry))
    try
      execute 'edit ' .. fnameescape(entry.name)
      if empty(getbufvar(target, 'vimrc_reopen_pending', {})) && bufnr() == target
        winrestview(entry.view)
      endif
    catch
      setbufvar(target, 'vimrc_reopen_pending', {})
      throw v:exception
    endtry
    return
  endif
  if !filereadable(entry.name) && !bufloaded(entry.buffer)
    throw 'The closed file is no longer available on disk'
  endif
  # :edit retains Vim's unsaved-buffer checks and remote BufReadCmd transport.
  execute 'edit ' .. fnameescape(entry.name)
  winrestview(entry.view)
  remove(g:vimrc_closed_buffers, 0)
enddef

def RestoreReopenView(number: number)
  if number <= 0 || !bufloaded(number)
    return
  endif
  var entry = getbufvar(number, 'vimrc_reopen_pending', {})
  if empty(entry) || getbufvar(number, '&modified') || getbufinfo(number)[0].name !=# entry.name
    return
  endif
  for window in win_findbuf(number)
    win_execute(window, 'call winrestview(' .. string(entry.view) .. ')')
  endfor
  filter(g:vimrc_closed_buffers, (_, closed) => get(closed, 'serial', -1) != entry.serial)
  setbufvar(number, 'vimrc_reopen_pending', {})
enddef

def RestoreRemoteReopen()
  var event: any = get(g:, 'simpleremote_event', {})
  var number: any = type(event) == v:t_dict ? get(event, 'bufnr', 0) : 0
  if type(number) == v:t_number
    RestoreReopenView(number)
  endif
enddef

augroup vimrc_buffer_history
  autocmd!
  autocmd User SimpleRemoteBufferRead call RestoreRemoteReopen()
augroup END

command! VimrcCloseBuffer call g:VimrcCloseBuffer()
command! VimrcReopenBuffer call g:VimrcReopenBuffer()
