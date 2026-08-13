vim9script

# Compatibility loader.  The implementation now lives in the standalone
# simpleremote plugin; this module remains in the vimrc load order so existing
# installations and :VimrcReload keep the old lifecycle contract.
const PLUGIN_ROOT = g:vimrc_root .. '/simpleremote'
if index(split(&runtimepath, ','), PLUGIN_ROOT) < 0
  &runtimepath = PLUGIN_ROOT .. ',' .. &runtimepath
endif
execute 'source ' .. fnameescape(PLUGIN_ROOT .. '/plugin/simpleremote.vim')
