vim9script

if exists('g:loaded_simpleplug_fixture')
  finish
endif
g:loaded_simpleplug_fixture = 1

def g:VimrcFixturePlugUpdate()
  g:vimrc_test_plugupdate_count = get(g:, 'vimrc_test_plugupdate_count', 0) + 1

  var plugin_dir = g:vimrc_context.plugin_home .. '/simplefinder/plugin'
  mkdir(plugin_dir, 'p')
  writefile([
    'vim9script',
    'command! VimrcFixtureReady g:vimrc_test_fixture_ready = 1',
  ], plugin_dir .. '/fixture.vim')

  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  setlocal filetype=simpleplug
  setline(1, [
    '  SimplePlug                                      ✓  Update Complete',
    '  total 20  installed 19  updated 0  ok 1  frozen 0  errors 0',
  ])
  setlocal nomodified
enddef

command! PlugUpdate call g:VimrcFixturePlugUpdate()
