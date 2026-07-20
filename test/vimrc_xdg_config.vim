vim9script

set nomore

const EXPECTED = substitute(
      fnamemodify($XDG_CONFIG_HOME, ':p'),
      '[\/\\]\+$',
      '',
      '') .. '/simplecc/simplecc.json'
assert_equal(EXPECTED, g:simplecc_config_path)

# Managed defaults are recalculated on reload, while an explicit user override
# remains authoritative.
delete(EXPECTED)
execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
assert_equal(g:vimrc_root .. '/simplecc.json', g:simplecc_config_path)
writefile(['{}'], EXPECTED)
execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
assert_equal(EXPECTED, g:simplecc_config_path)
g:simplecc_config_path = ''
execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')
assert_equal('', g:simplecc_config_path)

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
