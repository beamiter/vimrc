vim9script

# SimplePlug tracks doc/tags, but regenerates it after every install/update.
# An upstream help edit without refreshed tags therefore blocks the next update.
# Keep the regenerated help in state and restore only a proven generated diff.
def Git(home: string, arguments: list<string>): dict<any>
  var command = 'git -C ' .. shellescape(home)
  for argument in arguments
    command ..= ' ' .. shellescape(argument)
  endfor
  var lines = systemlist(command .. ' 2>/dev/null')
  return {ok: v:shell_error == 0, lines: lines}
enddef

def UseHelpCache(cache: string)
  if index(split(&runtimepath, ','), cache) < 0
    &runtimepath = cache .. ',' .. &runtimepath
  endif
  g:vimrc_simpleplug_help_runtime = cache
enddef

def g:VimrcRepairSimplePlugHelptags(): bool
  var previous = get(g:, 'vimrc_simpleplug_help_runtime', '')
  if !empty(previous)
    &runtimepath = join(filter(split(&runtimepath, ','),
      (_, entry) => entry !=# previous), ',')
    unlet g:vimrc_simpleplug_help_runtime
  endif

  var C = g:vimrc_context
  var home = C.plugin_home .. '/simpleplug'
  var doc = home .. '/doc'
  var cache = C.vim_state .. '/simpleplug-help'
  if !C.plugins_enabled || !executable('git') || getftype(home) !=# 'dir'
        || getftype(doc) !=# 'dir' || getftype(doc .. '/tags') !=# 'file'
        || getftype(doc .. '/simpleplug.txt') !=# 'file'
    return false
  endif

  var status = Git(home, ['status', '--porcelain=v1', '--untracked-files=all'])
  if !status.ok
    return false
  endif
  if empty(status.lines)
    # Reuse the fresh index on the next launch only while its help source
    # still matches this checkout. An upstream update invalidates the cache.
    if filereadable(cache .. '/doc/simpleplug.txt')
          && filereadable(cache .. '/doc/tags')
          && readfile(cache .. '/doc/simpleplug.txt', 'b')
            ==# readfile(doc .. '/simpleplug.txt', 'b')
      UseHelpCache(cache)
    endif
    return false
  endif

  # Never hide staged edits, source changes, untracked work, or custom docs.
  # The fixed source set also keeps temporary helptags generation exact.
  if status.lines !=# [' M doc/tags']
        || sort(readdir(doc)) !=# ['simpleplug.txt', 'tags']
        || !isdirectory(C.vim_state) || filewritable(C.vim_state) != 2
    return false
  endif

  var temporary = tempname()
  try
    mkdir(temporary, 'p', 0o700)
    var source = readfile(doc .. '/simpleplug.txt', 'b')
    var tags = readfile(doc .. '/tags', 'b')
    writefile(source, temporary .. '/simpleplug.txt', 'b')
    execute 'silent helptags ' .. fnameescape(temporary)
    if readfile(temporary .. '/tags', 'b') !=# tags
      return false
    endif

    mkdir(cache .. '/doc', 'p', 0o700)
    writefile(source, cache .. '/doc/simpleplug.txt', 'b')
    writefile(tags, cache .. '/doc/tags', 'b')
    # Recheck after generating the cache; all other local work stays protected.
    var latest = Git(home, ['status', '--porcelain=v1', '--untracked-files=all'])
    if !latest.ok || latest.lines !=# status.lines
          || readfile(doc .. '/simpleplug.txt', 'b') !=# source
          || readfile(doc .. '/tags', 'b') !=# tags
      return false
    endif
    if !Git(home, ['restore', '--worktree', '--', 'doc/tags']).ok
      return false
    endif
    UseHelpCache(cache)
    return true
  catch
    g:VimrcWarn('SimplePlug 帮助索引修复失败: ' .. v:exception)
  finally
    delete(temporary, 'rf')
  endtry
  return false
enddef

augroup vimrc_simpleplug_help
  autocmd!
  if g:vimrc_context.plugins_enabled
    autocmd User SimplePlugComplete call g:VimrcRepairSimplePlugHelptags()
  endif
augroup END

g:VimrcRepairSimplePlugHelptags()
