vim9script

# ============================================================================
# 大文件保护
# ============================================================================
# 超过阈值后只关闭当前 buffer 的高成本特性。值设为 0 可完全关闭。
if !exists('g:vimrc_large_file_bytes')
  g:vimrc_large_file_bytes = 5 * 1024 * 1024
endif

def DetectLargeFile(path: string)
  var threshold = get(g:, 'vimrc_large_file_bytes', 0)
  if type(threshold) != v:t_number || threshold <= 0 || empty(path)
    b:vimrc_large_file = 0
    return
  endif
  var size = getfsize(path)
  b:vimrc_large_file = size >= threshold ? 1 : 0
  b:vimrc_file_size = size
  if !b:vimrc_large_file
    return
  endif

  # Reading a giant undo tree or swapping the buffer often costs more than the
  # edit itself.  Tree-sitter has an explicit buffer-local opt-out.
  b:simpletreesitter_disable = 1
  setlocal noundofile noswapfile undolevels=100
enddef

def ApplyLargeFileMode()
  if !get(b:, 'vimrc_large_file', 0)
    return
  endif
  setlocal syntax=OFF
  setlocal foldmethod=manual nofoldenable
  setlocal nocursorline norelativenumber
  setlocal synmaxcol=200
enddef

def g:VimrcLargeFileStatus()
  var threshold = get(g:, 'vimrc_large_file_bytes', 0)
  if get(b:, 'vimrc_large_file', 0)
    g:VimrcInfo(printf(
      'large-file mode: ON (%s, threshold %s)',
      FormatBytes(get(b:, 'vimrc_file_size', -1)),
      FormatBytes(threshold)))
  else
    g:VimrcInfo(printf(
      'large-file mode: off (threshold %s)',
      threshold > 0 ? FormatBytes(threshold) : 'disabled'))
  endif
enddef

def g:VimrcLargeFileStatusline(): string
  return get(b:, 'vimrc_large_file', 0) ? 'BIG ' .. FormatBytes(
    get(b:, 'vimrc_file_size', -1)) : ''
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

# ============================================================================
# 项目根目录
# ============================================================================
if !exists('g:vimrc_root_markers')
  g:vimrc_root_markers = [
    '.git',
    '.hg',
    'Cargo.toml',
    'go.mod',
    'pyproject.toml',
    'package.json',
    'Project.toml',
    'Makefile',
  ]
endif

def g:VimrcProjectRoot(path: string = ''): string
  if exists('*g:SimpleRemoteProjectRoot') == 1
    var remote_root = g:SimpleRemoteProjectRoot(path)
    if !empty(remote_root)
      return remote_root
    endif
  endif
  var candidate = empty(path) ? expand('%:p') : fnamemodify(path, ':p')
  var dir = isdirectory(candidate) ? candidate : fnamemodify(candidate, ':h')
  if empty(dir) || !isdirectory(dir)
    dir = getcwd()
  endif
  dir = resolve(fnamemodify(dir, ':p'))
  var fallback = dir

  while !empty(dir)
    for marker in get(g:, 'vimrc_root_markers', [])
      if isdirectory(dir .. '/' .. marker) || filereadable(dir .. '/' .. marker)
        return substitute(dir, '[\\/]\+$', '', '')
      endif
    endfor
    var parent = fnamemodify(dir, ':h')
    if parent ==# dir
      break
    endif
    dir = parent
  endwhile
  return substitute(fallback, '[\\/]\+$', '', '')
enddef

def g:VimrcCdRoot(global: bool = false)
  var root = g:VimrcProjectRoot()
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
def ToggleQuickfix()
  var info = getqflist({winid: 0, size: 0})
  if info.winid > 0
    cclose
  elseif info.size == 0
    g:VimrcWarn('quickfix list 为空')
  else
    botright copen
  endif
enddef

def ToggleLocationList()
  var info = getloclist(0, {winid: 0, size: 0})
  if info.winid > 0
    lclose
  elseif info.size == 0
    g:VimrcWarn('location list 为空')
  else
    botright lopen
  endif
enddef

command! VimrcLargeFile call g:VimrcLargeFileStatus()
command! -bang VimrcRoot call g:VimrcCdRoot(<bang>0 == 1)
command! QFToggle call ToggleQuickfix()
command! LLToggle call ToggleLocationList()

# 与 update.vim 的段位共用 config/lib.vim 的同一注册接口；按函数名去重保证
# 反复 source 幂等。
const STATUSLINE_SEGMENT = {
  fn: 'g:VimrcLargeFileStatusline',
  hl: 'SimpleLineDiagWarn',
}
g:VimrcRegisterStatuslineSegment(STATUSLINE_SEGMENT)

augroup vimrc_workflow
  autocmd!
  autocmd BufReadPre * call DetectLargeFile(expand('<afile>:p'))
  autocmd BufReadPost * call ApplyLargeFileMode()
augroup END
