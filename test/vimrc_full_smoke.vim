vim9script

set nomore

const ROOT = g:vimrc_root
execute 'edit ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal('NONE', &viminfofile)

# Ex mode does not emit VimEnter automatically; reproduce normal startup.
doautocmd VimEnter
sleep 150m

assert_equal(1, get(g:, 'vimrc_plugins_ready', 0))
for command_name in [
      'PlugStatus',
      'SimpleFinderFiles',
      'SimpleTree',
      'SimpleLineHealth',
      'SimpleMinimapHealth',
      'SimpleCopyStatus',
      'TsHlStatus',
      'SimpleCC',
    ]
  assert_equal(2, exists(':' .. command_name), command_name)
endfor

# Explicit SimpleCC mappings must not inherit the upstream trailing-space bug.
assert_equal(
      '<Plug>(simplecc-outline)',
      maparg('<Space>lo', 'n'))
assert_equal(
      '<Plug>(simplecc-inlay-hints)',
      maparg('<Space>ih', 'n'))
assert_equal('', maparg('s', 'n'))
assert_equal('', maparg('(', 'n'))
assert_equal('', maparg(')', 'n'))
assert_equal('', maparg('gd', 'n'))
assert_equal('', maparg('gr', 'n'))
assert_equal('', maparg('gi', 'n'))
assert_notequal('<Plug>(simplecc-select-tab)', maparg('<Tab>', 'i'))

&l:filetype = 'julia'
g:VimrcConfigureFiletype()
assert_equal('<Cmd>JuliaFormatterFormat<CR>', maparg(',jf', 'n'))
assert_equal(':JuliaFormatterFormat<CR>', maparg(',jf', 'x'))
&l:filetype = 'vim'
g:VimrcConfigureFiletype()
assert_equal('', maparg(',jf', 'n'))
assert_equal('', maparg(',jf', 'x'))

# LSP-like native overrides are buffer-local and disappear with the filetype.
&l:filetype = 'rust'
g:VimrcConfigureFiletype()
assert_equal('<Plug>(simplecc-definition)', maparg('gd', 'n'))
assert_equal('<Plug>(simplecc-references)', maparg('gr', 'n'))
assert_equal('<Plug>(simplecc-implementation)', maparg('gi', 'n'))
assert_equal('<Plug>(simplecc-select-tab)', maparg('<Tab>', 'i'))
&l:filetype = 'vim'
g:VimrcConfigureFiletype()
assert_equal('', maparg('gd', 'n'))
assert_equal('', maparg('gr', 'n'))
assert_equal('', maparg('gi', 'n'))
assert_notequal('<Plug>(simplecc-select-tab)', maparg('<Tab>', 'i'))

# Initialize lexima once, then verify the combined completion/newline mapping.
lexima#init()
doautocmd InsertEnter
var enter_map = maparg('<CR>', 'i', false, true)
assert_true(get(enter_map, 'expr', 0))
assert_match('simplecc#SelectEnterKey', get(enter_map, 'rhs', ''))
assert_match('lexima#expand', get(enter_map, 'rhs', ''))

# SimpleLine must not steal the two sidebar-specific statuslines.
execute 'SimpleTree ' .. fnameescape(ROOT)
sleep 100m
var tree_status = ''
var edit_winid = 0
for info in getwininfo()
  var ft = getbufvar(info.bufnr, '&filetype')
  if ft ==# 'simpletree'
    tree_status = gettabwinvar(info.tabnr, info.winnr, '&statusline')
  elseif getbufvar(info.bufnr, '&buftype') ==# ''
    edit_winid = info.winid
  endif
endfor
assert_equal('%{simpletree#StatusLine()}', tree_status)

if edit_winid > 0
  win_gotoid(edit_winid)
endif
SimpleMinimapOpen
sleep 100m
var minimap_status = ''
for info in getwininfo()
  if getbufvar(info.bufnr, '&filetype') ==# 'simpleminimap'
    minimap_status = gettabwinvar(info.tabnr, info.winnr, '&statusline')
  endif
endfor
assert_equal(
      '%#SimpleMinimapTitle#%{simpleminimap#Statusline()}%*',
      minimap_status)

g:VimrcHealth()
assert_equal(0, get(get(g:, 'vimrc_health_last', {}), 'fail', -1))

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
