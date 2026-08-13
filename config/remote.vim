vim9script

# SimpleRemote is installed and loaded by SimplePlug.  This module remains in
# the vimrc load order only to preserve the controller's deliberate reload
# lifecycle without embedding the plugin implementation in this repository.
if exists('*g:VimrcConfigureRemote') == 1
  g:VimrcConfigureRemote()
endif
