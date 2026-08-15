vim9script

set nomore

# Headless :PlugUpdate driver: start the update, then poll the SimplePlug UI
# buffer for its completion banner.  Exits 0 only when the update finished
# without errors; timeouts and error counts go to stderr.

var timeout_seconds = 1800
if exists('g:vimrc_plugupdate_timeout')
  timeout_seconds = g:vimrc_plugupdate_timeout
endif

if exists(':PlugUpdate') != 2
  echoerr 'PlugUpdate command is not available'
  cquit 2
endif

PlugUpdate

var started = localtime()
var done = false
var errors = -1
while localtime() - started < timeout_seconds
  sleep 2
  for info in getbufinfo()
    if getbufvar(info.bufnr, '&filetype') ==# 'simpleplug'
      var lines = getbufline(info.bufnr, 1, 3)
      if !empty(lines) && lines[0] =~# 'Update Complete'
        done = true
        errors = len(lines) > 1
              \ ? str2nr(matchstr(lines[1], '\<errors\s\+\zs\d\+'))
              \ : 0
      endif
      break
    endif
  endfor
  if done
    break
  endif
endwhile

if !done
  echoerr 'PlugUpdate did not finish within ' .. timeout_seconds .. 's'
  cquit 1
endif
if errors != 0
  echoerr 'PlugUpdate finished with ' .. errors .. ' error(s)'
  cquit 1
endif
qall!
