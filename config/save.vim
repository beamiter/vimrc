vim9script

def SavePayloadEol(buffer: number): bool
  return !!(getbufvar(buffer, '&endofline')
    || (getbufvar(buffer, '&fixendofline') && !getbufvar(buffer, '&binary')))
enddef

# Exact canonical project root -> filetype policy. Nothing is enabled globally.
# g:vimrc_save_projects = {'/path/project': {'rust': {format: true, imports: true}}}
# b:vimrc_save_pipeline overrides project policy for the current buffer only.
def g:VimrcSavePolicy(): dict<any>
  var root = g:VimrcProjectRoot()
  var projects = get(g:, 'vimrc_save_projects', {})
  var policy = get(b:, 'vimrc_save_pipeline',
    get(get(projects, root, {}), &filetype, {}))
  return type(policy) == v:t_dict ? copy(policy) : {}
enddef

def g:VimrcSave(): number
  var policy = g:VimrcSavePolicy()
  if empty(policy)
    update
    return 0
  endif
  return simplecc#save#Start(policy)
enddef

command! VimrcSave call g:VimrcSave()
# Users can route their own save key to <Plug>; existing mappings stay intact.
nnoremap <silent> <Plug>(VimrcSave) <Cmd>VimrcSave<CR>

# Explicit bounded wait for save-before-build. Does not retry commands or
# infer success from another buffer/newer request. Timeout means unknown/pending.
def g:VimrcSaveWait(timeout_ms: number = 5000): dict<any>
  var buffer = bufnr()
  var window = win_getid()
  var prior_remote = get(b:, 'vimrc_remote_write_state', {})
  var needed_write = &modified
  var token = 0
  var already_pending = type(prior_remote) == v:t_dict && get(prior_remote, 'status', '') ==# 'pending'
  if already_pending
    if get(prior_remote, 'tick', -1) != b:changedtick
      return {status: 'error', message: 'document changed during pending remote write; build not started'}
    endif
    # Wait for the existing payload instead of repeating remote writes or LSP
    # save commands while that payload is still awaiting acknowledgement.
    needed_write = false
  else
    try
      token = g:VimrcSave()
    catch
      return {status: 'error', message: v:exception}
    endtry
  endif
  if token == 0
    if bufnr() != buffer || win_getid() != window
      return {status: 'error', message: 'write changed the save buffer or window'}
    endif
    var tick = b:changedtick
    var remote = get(b:, 'vimrc_remote_write_state', {})
    var identity = type(remote) == v:t_dict && has_key(remote, 'serial') ? copy(remote) : {}
    if needed_write && !empty(identity) && get(identity, 'serial', 0) <= get(prior_remote, 'serial', 0)
      return {status: 'error', message: 'remote write did not start a new acknowledged request'}
    endif
    var started_write = reltime()
    while true
      if bufnr() != buffer || win_getid() != window || b:changedtick != tick
        return {status: 'error', message: 'remote save context changed while writing'}
      endif
      if !empty(identity)
        remote = get(b:, 'vimrc_remote_write_state', {})
        if get(remote, 'serial', -1) != identity.serial
            || get(remote, 'generation', -1) != get(identity, 'generation', -1)
            || get(remote, 'tick', -1) != get(identity, 'tick', -1)
            || (has_key(identity, 'final_eol') &&
              (!!get(remote, 'final_eol', false) != !!identity.final_eol
                || SavePayloadEol(buffer) != !!identity.final_eol))
            || (get(identity, 'path', '') != '' &&
              (get(remote, 'path', '') != identity.path
                || get(getbufvar(buffer, 'vimrc_remote', {}), 'path', '') != identity.path))
          return {status: 'error', message: 'remote write superseded or connection changed'}
        endif
        if index(['error', 'stale'], get(remote, 'status', '')) >= 0
          return {status: 'error', message: get(remote, 'message', 'remote write failed')}
        endif
        if get(remote, 'status', '') ==# 'success'
          return {status: !&modified && get(remote, 'tick', -1) == tick ? 'success' : 'error',
            message: !&modified && get(remote, 'tick', -1) == tick ? '' : 'remote acknowledgement does not match buffer'}
        endif
      elseif !&modified
        return {status: 'success', message: ''}
      elseif &buftype !=# 'acwrite'
        return {status: 'error', message: 'write did not save the buffer'}
      endif
      if reltimefloat(reltime(started_write)) * 1000 >= min([30000, max([0, timeout_ms])])
        return {status: 'pending', message: 'write acknowledgement still pending; build not started'}
      endif
      sleep 10m
    endwhile
  endif
  var started = reltime()
  while reltimefloat(reltime(started)) * 1000 < min([30000, max([0, timeout_ms])])
    if bufnr() != buffer || win_getid() != window
      return {status: 'error', message: 'save buffer changed'}
    endif
    var result = simplecc#save#Status(buffer, token)
    if index(['success', 'error'], result.status) >= 0
      return result
    endif
    sleep 10m
  endwhile
  return {status: 'pending', message: 'save still pending; build not started'}
enddef

# Save-all/build uses the same policy for each modified file, with one total
# deadline. A failed/pending write prevents a build; no save action is bypassed.
def g:VimrcSaveAllWait(timeout_ms: number = 5000): dict<any>
  var origin = win_getid()
  var original_buffer = bufnr()
  var view = winsaveview()
  var started = reltime()
  var last = original_buffer
  try
    for info in getbufinfo({buflisted: 1})
      var remote = getbufvar(info.bufnr, 'vimrc_remote_write_state', {})
      var remote_unfinished = type(remote) == v:t_dict && index(['pending', 'error', 'stale'], get(remote, 'status', '')) >= 0
      if (!getbufvar(info.bufnr, '&modified') && !remote_unfinished)
          || index(['', 'acwrite'], getbufvar(info.bufnr, '&buftype')) < 0
        continue
      endif
      var remaining = timeout_ms - float2nr(reltimefloat(reltime(started)) * 1000)
      if remaining <= 0
        return {status: 'pending', message: 'Save-all deadline reached; build not started'}
      endif
      execute 'keepalt keepjumps hide buffer ' .. info.bufnr
      last = info.bufnr
      var result = g:VimrcSaveWait(remaining)
      if result.status !=# 'success'
        return result
      endif
    endfor
    if !empty(filter(getbufinfo({buflisted: 1}), (_, info) =>
      (info.changed || get(getbufvar(info.bufnr, 'vimrc_remote_write_state', {}), 'status', '') ==# 'pending')
      && index(['', 'acwrite'], getbufvar(info.bufnr, '&buftype')) >= 0))
      return {status: 'error', message: 'A buffer changed while saving; build not started'}
    endif
    return {status: 'success', message: ''}
  catch
    return {status: 'error', message: v:exception}
  finally
    if win_getid() == origin && bufnr() == last && bufexists(original_buffer)
      execute 'keepalt keepjumps hide buffer ' .. original_buffer
      winrestview(view)
    endif
  endtry
  return {status: 'error', message: 'save-all did not complete'}
enddef
