vim9script
set nomore

if !exists('*g:VimrcProjectRoot')
  def g:VimrcProjectRoot(): string
    return '/project'
  enddef
endif
const ROOT = expand('<sfile>:p:h:h')
if !exists('*g:VimrcSave')
  execute 'source ' .. fnameescape(ROOT .. '/config/save.vim')
endif
const file = tempname()
writefile(['before'], file)
execute 'edit ' .. fnameescape(file)
setfiletype rust
assert_equal({}, g:VimrcSavePolicy())
setline(1, 'after')
assert_equal({status: 'success', message: ''}, g:VimrcSaveWait(100))
assert_equal(['after'], readfile(file))
g:vimrc_save_projects = {[g:VimrcProjectRoot()]: {'rust': {format: true, imports: true}}}
assert_equal({format: true, imports: true}, g:VimrcSavePolicy())
b:vimrc_save_pipeline = {format: false}
assert_equal({format: false}, g:VimrcSavePolicy())
# A normal write failure is an error, never a successful build prerequisite.
b:vimrc_save_pipeline = {}
setlocal buftype=acwrite
augroup SaveFailure
  autocmd!
  autocmd BufWriteCmd <buffer> throw 'transport failure'
augroup END
setline(1, 'dirty')
assert_equal('error', g:VimrcSaveWait(100).status)
assert_true(&modified)
if !empty(v:errors)
  writefile(v:errors, ROOT .. '/test/save-errors.log')
  cquit
endif
qa!
