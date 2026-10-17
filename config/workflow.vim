vim9script

# ============================================================================
# 大文件保护
# ============================================================================
# bytes=0 retains the original opt-out for all automatic protection.  The other
# two thresholds can be disabled independently with 0.  Manual on still works.
for [name, value] in items({
  vimrc_large_file_bytes: 5 * 1024 * 1024,
  vimrc_large_file_lines: 100000,
  vimrc_large_file_line_bytes: 20000,
  vimrc_quickfix_height: 10,
})
  if !has_key(g:, name)
    g:[name] = value
  endif
endfor

const WINDOW_LIMITS = {
  foldmethod: 'manual',
  foldenable: false,
  cursorline: false,
  relativenumber: false,
  spell: false,
  conceallevel: 0,
  wrap: false,
}
const BUFFER_LIMITS = {syntax: 'OFF', synmaxcol: 200, indentexpr: ''}
var last_window = 0

def Threshold(name: string): number
  var value = get(g:, name, 0)
  return type(value) == v:t_number && value > 0 ? value : 0
enddef

def IsFileBuffer(): bool
  return &buftype ==# '' || &buftype ==# 'acwrite'
enddef

def SetBufferOption(name: string, value: any)
  if eval('&l:' .. name) != value
    setbufvar(bufnr(), '&' .. name, value)
  endif
enddef

def SaveBufferOption(name: string)
  if !exists('b:vimrc_large_file_saved')
    b:vimrc_large_file_saved = {}
  endif
  if !has_key(b:vimrc_large_file_saved, name)
    b:vimrc_large_file_saved[name] = eval('&l:' .. name)
  endif
enddef

def ProtectReadOptions()
  if !exists('b:vimrc_large_file_treesitter')
    b:vimrc_large_file_treesitter = {
      existed: exists('b:simpletreesitter_disable') == 1,
      value: get(b:, 'simpletreesitter_disable', 0),
    }
  endif
  b:simpletreesitter_disable = 1
  for name in ['undofile', 'swapfile', 'undolevels']
    SaveBufferOption(name)
  endfor
  # Keep deliberately disabled/short undo histories at least as restrictive.
  var undo_limit = min([100, &undolevels])
  setlocal noundofile noswapfile
  SetBufferOption('undolevels', undo_limit)
enddef

def RestoreWindowOptions()
  var saved = get(w:, 'vimrc_large_file_window', {})
  if empty(saved)
    return
  endif
  # BufWinLeave may describe a buffer other than the current one; never apply
  # another buffer's saved view to a sidebar or an unrelated editing window.
  if get(saved, 'buffer', -1) == bufnr()
    for [name, value] in items(saved.options)
      setwinvar(0, '&' .. name, value)
    endfor
  endif
  unlet! w:vimrc_large_file_window
enddef

def ApplyWindowOptions()
  if !get(b:, 'vimrc_large_file', 0) || !IsFileBuffer()
    return
  endif
  var saved = get(w:, 'vimrc_large_file_window', {})
  if get(saved, 'buffer', -1) != bufnr()
    var options: dict<any> = {}
    for name in keys(WINDOW_LIMITS)
      options[name] = eval('&l:' .. name)
    endfor
    w:vimrc_large_file_window = {buffer: bufnr(), options: options}
  endif
  for [name, value] in items(WINDOW_LIMITS)
    if eval('&l:' .. name) != value
      setwinvar(0, '&' .. name, value)
    endif
  endfor
enddef

# New splits inherit disabled local options but not window variables.  Copy
# the source window's original view before WinEnter can snapshot that view.
def InheritWindowOptions()
  if last_window <= 0 || !get(b:, 'vimrc_large_file', 0)
    return
  endif
  var source_windows = getwininfo(last_window)
  if empty(source_windows)
    return
  endif
  var source_window = source_windows[0]
  var source = gettabwinvar(source_window.tabnr, source_window.winnr,
    'vimrc_large_file_window', {})
  if get(source, 'buffer', -1) == bufnr()
    w:vimrc_large_file_window = deepcopy(source)
  endif
enddef

def g:VimrcApplyLargeFileMode()
  if !get(b:, 'vimrc_large_file', 0) || !IsFileBuffer()
    return
  endif
  ProtectReadOptions()
  for [name, value] in items(BUFFER_LIMITS)
    SaveBufferOption(name)
    SetBufferOption(name, value)
  endfor
  ApplyWindowOptions()
enddef

def NotifyLargeFileChange()
  if exists('#User#VimrcLargeFileChanged')
    for winid in win_findbuf(bufnr())
      win_execute(winid, 'doautocmd <nomodeline> User VimrcLargeFileChanged')
    endfor
  endif
enddef

def SetLargeFileMode(enabled: bool, reason: string = '', before_read: bool = false)
  var was_enabled = get(b:, 'vimrc_large_file', 0) == 1
  b:vimrc_large_file = enabled ? 1 : 0
  b:vimrc_large_file_reason = reason
  if enabled
    ProtectReadOptions()
    if !before_read
      # Every visible copy of this buffer needs its own view snapshot.  The
      # command runs only at a transition, never in a statusline expression.
      for winid in win_findbuf(bufnr())
        win_execute(winid, 'call g:VimrcApplyLargeFileMode()')
      endfor
    endif
  elseif was_enabled || exists('b:vimrc_large_file_saved')
    var saved = get(b:, 'vimrc_large_file_saved', {})
    for [name, value] in items(saved)
      SetBufferOption(name, value)
    endfor
    unlet! b:vimrc_large_file_saved
    var treesitter = get(b:, 'vimrc_large_file_treesitter', {})
    if get(treesitter, 'existed', false)
      b:simpletreesitter_disable = treesitter.value
    else
      unlet! b:simpletreesitter_disable
    endif
    unlet! b:vimrc_large_file_treesitter
    for winid in win_findbuf(bufnr())
      win_execute(winid, 'call g:VimrcRestoreLargeFileWindow()')
    endfor
  endif
  if was_enabled != enabled
    NotifyLargeFileChange()
  endif
enddef

# Used by win_execute() for windows in other tabpages as well as this one.
def g:VimrcRestoreLargeFileWindow()
  RestoreWindowOptions()
enddef

def ReadBufferSize()
  b:vimrc_file_lines = line('$')
  b:vimrc_file_size = max([0, line2byte(line('$') + 1) - 1])
  if line('$') == 1 && empty(getline(1))
    b:vimrc_file_size = 0
  endif
enddef

def FindLongLine(full: bool): number
  var threshold = Threshold('vimrc_large_file_line_bytes')
  if threshold == 0
    return 0
  endif
  if strlen(getline('.')) >= threshold
    return line('.')
  endif
  if !full
    return 0
  endif
  # Bound startup work: inspect up to 10,000 lines at the beginning/end, in
  # small chunks.  Large line-count/byte thresholds are checked before this.
  # CursorHold also checks an unsampled line when the user visits it.
  var count = line('$')
  var ranges = count <= 10000 ? [[1, count]] : [[1, 5000], [count - 4999, count]]
  b:vimrc_large_file_scan_limited = count > 10000
  for [first, last] in ranges
    for start in range(first, last, 256)
      var lnum = start
      for text in getline(start, min([start + 255, last]))
        if strlen(text) >= threshold
          return lnum
        endif
        lnum += 1
      endfor
    endfor
  endfor
  return 0
enddef

def DetectBuffer(full: bool = false, reset: bool = false)
  if !IsFileBuffer()
    return
  endif
  if !full && !reset && get(b:, 'vimrc_large_file_tick', -1) == b:changedtick
    return
  endif
  b:vimrc_large_file_tick = b:changedtick
  ReadBufferSize()
  var policy = get(b:, 'vimrc_large_file_policy', 'auto')
  if policy ==# 'off'
    SetLargeFileMode(false)
    return
  elseif policy ==# 'on'
    if reset || !get(b:, 'vimrc_large_file', 0)
      SetLargeFileMode(true, 'manual')
    endif
    return
  endif
  var byte_limit = Threshold('vimrc_large_file_bytes')
  if byte_limit == 0
    SetLargeFileMode(false)
    return
  endif
  # Once triggered, keep protection until a deliberate auto/off or reread.
  # Undo/paste near a threshold must not repeatedly restart expensive features.
  if get(b:, 'vimrc_large_file', 0) && !reset
    return
  endif
  var reason = ''
  if b:vimrc_file_size >= byte_limit
    reason = 'bytes'
  elseif Threshold('vimrc_large_file_lines') > 0
        && b:vimrc_file_lines >= Threshold('vimrc_large_file_lines')
    reason = 'lines'
  else
    var long_line = FindLongLine(full)
    if long_line > 0
      reason = 'long line ' .. long_line
    endif
  endif
  SetLargeFileMode(!empty(reason), reason)
enddef

def PrepareRead(path: string)
  if !IsFileBuffer()
    return
  endif
  var size = getfsize(path)
  var policy = get(b:, 'vimrc_large_file_policy', 'auto')
  var limit = Threshold('vimrc_large_file_bytes')
  var enabled = policy ==# 'on'
        || (policy ==# 'auto' && limit > 0 && size >= limit)
  SetLargeFileMode(enabled, policy ==# 'on' ? 'manual' : 'bytes', true)
  b:vimrc_file_size = size
  b:vimrc_large_file_tick = -1
enddef

def EnterBuffer()
  DetectBuffer()
  g:VimrcApplyLargeFileMode()
enddef

def CheckCursorLine()
  if IsFileBuffer() && !get(b:, 'vimrc_large_file', 0)
        && get(b:, 'vimrc_large_file_policy', 'auto') ==# 'auto'
        && Threshold('vimrc_large_file_bytes') > 0
    var long_line = FindLongLine(false)
    if long_line > 0
      ReadBufferSize()
      SetLargeFileMode(true, 'long line ' .. long_line)
    endif
  endif
enddef

def g:VimrcRefreshLargeFile()
  DetectBuffer(true, true)
enddef

def FormatBytes(bytes: number): string
  if bytes < 0
    return 'unknown'
  elseif bytes >= 1024 * 1024
    return printf('%.1f MiB', bytes / 1024.0 / 1024.0)
  elseif bytes >= 1024
    return printf('%.1f KiB', bytes / 1024.0)
  endif
  return bytes .. ' B'
enddef

def g:VimrcLargeFileStatus()
  var enabled = get(b:, 'vimrc_large_file', 0) ? 'ON' : 'off'
  var reason = get(b:, 'vimrc_large_file_reason', '')
  g:VimrcInfo(printf('large-file mode: %s (%s; %s; %d lines%s)', enabled,
    get(b:, 'vimrc_large_file_policy', 'auto'),
    FormatBytes(get(b:, 'vimrc_file_size', -1)),
    get(b:, 'vimrc_file_lines', line('$')), empty(reason) ? '' : '; ' .. reason))
enddef

def g:VimrcLargeFileStatusline(): string
  return get(b:, 'vimrc_large_file', 0) ? 'BIG ' .. FormatBytes(
    get(b:, 'vimrc_file_size', -1)) : ''
enddef

def SetLargeFilePolicy(policy: string)
  if empty(policy) || policy ==# 'status'
    g:VimrcLargeFileStatus()
    return
  endif
  if index(['on', 'off', 'auto'], policy) < 0
    g:VimrcWarn('用法: VimrcLargeFile [on|off|auto|status]')
    return
  endif
  if !IsFileBuffer()
    g:VimrcWarn('大文件模式只用于文件 buffer')
    return
  endif
  b:vimrc_large_file_policy = policy
  g:VimrcRefreshLargeFile()
  g:VimrcLargeFileStatus()
enddef

def CompleteLargeFile(lead: string, cmdline: string, pos: number): list<string>
  return filter(['on', 'off', 'auto', 'status'], (_, item) => stridx(item, lead) == 0)
enddef

# ============================================================================
# 项目根目录
# ============================================================================
if !exists('g:vimrc_root_markers')
  g:vimrc_root_markers = [
    '.git', '.hg', '.svn', 'Cargo.toml', 'go.mod', 'pyproject.toml',
    'package.json', 'Project.toml', 'Makefile', 'CMakeLists.txt',
    'compile_commands.json',
  ]
endif

def NormalizeRoot(dir: string): string
  var trimmed = substitute(dir, '\m[\\/]\+$', '', '')
  return empty(trimmed) ? dir : trimmed
enddef

def g:VimrcProjectRoot(path: string = ''): string
  if exists('*g:SimpleRemoteProjectRoot') == 1
    var remote_root = g:SimpleRemoteProjectRoot(path)
    if !empty(remote_root)
      return remote_root
    endif
  endif
  var candidate = empty(path) ? expand('%:p') : fnamemodify(path, ':p')
  var dir = empty(candidate) ? getcwd()
        : (isdirectory(candidate) ? candidate : fnamemodify(candidate, ':h'))
  dir = NormalizeRoot(resolve(fnamemodify(dir, ':p')))
  # New files can have several not-yet-created parent directories.  Search
  # their existing ancestors instead of falling back to an unrelated cwd.
  while !isdirectory(dir)
    var parent = fnamemodify(dir, ':h')
    if parent ==# dir
      dir = getcwd()
      break
    endif
    dir = parent
  endwhile
  var fallback = dir
  var markers = get(g:, 'vimrc_root_markers', [])
  if type(markers) != v:t_list
    return fallback
  endif
  while !empty(dir)
    for marker in markers
      if type(marker) == v:t_string && !empty(marker)
            && (isdirectory(dir .. '/' .. marker) || filereadable(dir .. '/' .. marker))
        # .git may be a file in a Git worktree, not only a directory.
        return NormalizeRoot(dir)
      endif
    endfor
    var parent = fnamemodify(dir, ':h')
    if parent ==# dir
      break
    endif
    dir = parent
  endwhile
  return NormalizeRoot(fallback)
enddef

def g:VimrcCdRoot(global: bool = false, path: string = '')
  var root = g:VimrcProjectRoot(path)
  if exists('*g:SimpleRemoteIsVirtual') == 1 && g:SimpleRemoteIsVirtual()
    echomsg '[SimpleRemote] virtual cwd -> ' .. root
    return
  endif
  execute (global ? 'cd ' : 'lcd ') .. fnameescape(root)
  g:VimrcInfo('cwd → ' .. root)
enddef

# ============================================================================
# Quickfix / location list
# ============================================================================
def ToggleList(location: bool, focus: bool)
  var info = location ? getloclist(0, {winid: 0, size: 0}) : getqflist({winid: 0, size: 0})
  if info.winid > 0
    execute location ? 'lclose' : 'cclose'
  elseif info.size == 0
    g:VimrcWarn(location ? 'location list 为空' : 'quickfix list 为空')
  else
    var origin = win_getid()
    var limit = max([1, Threshold('vimrc_quickfix_height')])
    var height = min([info.size, limit, max([1, &lines - 4])])
    execute 'botright ' .. (location ? 'lopen ' : 'copen ') .. height
    if !focus
      win_gotoid(origin)
    endif
  endif
enddef

command! -nargs=? -complete=customlist,CompleteLargeFile VimrcLargeFile call SetLargeFilePolicy(<q-args>)
command! -bang -nargs=? -complete=dir VimrcRoot call g:VimrcCdRoot(<bang>0 ? true : false, <f-args>)
command! -bang QFToggle call ToggleList(false, <bang>0 ? true : false)
command! -bang LLToggle call ToggleList(true, <bang>0 ? true : false)

const STATUSLINE_SEGMENT = {
  fn: 'g:VimrcLargeFileStatusline',
  hl: 'SimpleLineDiagWarn',
}
g:VimrcRegisterStatuslineSegment(STATUSLINE_SEGMENT)

augroup vimrc_workflow
  autocmd!
  autocmd BufReadPre * call PrepareRead(expand('<afile>:p'))
  autocmd BufReadPost,StdinReadPost,FileReadPost,FilterReadPost * call DetectBuffer(true)
  autocmd TextChanged,TextChangedI * call DetectBuffer()
  autocmd BufWinEnter * call EnterBuffer()
  autocmd WinEnter * call g:VimrcApplyLargeFileMode()
  autocmd WinLeave * last_window = win_getid()
  autocmd WinNew * call InheritWindowOptions()
  autocmd BufWinLeave * call RestoreWindowOptions()
  autocmd CursorHold * call CheckCursorLine()
augroup END

# Reloading core.vim may reset managed local options.  Reassert protection
# without replacing the original snapshot, which must survive :VimrcReload.
g:VimrcApplyLargeFileMode()
