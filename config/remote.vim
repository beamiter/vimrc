vim9script

# SimpleRemote is installed and loaded by SimplePlug.  This module remains in
# the vimrc load order only to preserve the controller's deliberate reload
# lifecycle without embedding the plugin implementation in this repository.
if exists('*g:VimrcConfigureRemote') == 1
  g:VimrcConfigureRemote()
endif

# Core-only sessions still bind <leader>rf; keep a fallback until the plugin
# (or a previous definition) supplies the real prompt.
if exists('*g:VimrcRemotePromptFind') != 1
  def g:VimrcRemotePromptFind()
    if exists(':SimpleRemoteFind') == 2
      execute 'SimpleRemoteFind'
      return
    endif
    g:VimrcWarn('SimpleRemote 尚未就绪')
  enddef
endif
