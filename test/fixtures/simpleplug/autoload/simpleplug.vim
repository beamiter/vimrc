vim9script

var plugin_dirs: list<string> = []

export def Begin(dir: string = '')
  plugin_dirs = []
  if !empty(dir)
    g:simpleplug_dir = substitute(fnamemodify(dir, ':p'), '/\+$', '', '')
  endif
enddef

export def Plug(repo: string, options: dict<any> = {})
  var name = get(options, 'as', split(repo, '/')[-1])
  add(plugin_dirs, get(options, 'dir', g:simpleplug_dir .. '/' .. name))
enddef

export def End()
  for dir in plugin_dirs
    if !isdirectory(dir)
      continue
    endif
    for script in globpath(dir, 'plugin/*.vim', false, true)
      execute 'source ' .. fnameescape(script)
    endfor
  endfor
enddef

export def UIClose()
  for info in getbufinfo()
    if getbufvar(info.bufnr, '&filetype') ==# 'simpleplug'
      execute 'silent! bwipeout! ' .. info.bufnr
    endif
  endfor
enddef
