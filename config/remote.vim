vim9script

# SimpleRemote is installed and loaded by SimplePlug.  This module remains in
# the vimrc load order only to preserve the controller's deliberate reload
# lifecycle without embedding the plugin implementation in this repository.
if exists('*g:VimrcConfigureRemote') == 1
  g:VimrcConfigureRemote()
endif

# Plugins may load after vimrc.  Keep this entry point separate from the
# plugin's global function, and resolve that function only when invoked.
def g:VimrcPromptRemoteFind()
  if exists('*g:VimrcRemotePromptFind') == 1
    execute 'call g:VimrcRemotePromptFind()'
    return
  endif
  g:VimrcWarn('SimpleRemote 尚未就绪')
enddef
