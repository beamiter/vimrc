vim9script

set nomore

const ROOT = g:vimrc_root
execute 'edit ' .. fnameescape(ROOT .. '/.vimrc')
assert_equal('NONE', &viminfofile)

# Ex mode does not emit VimEnter automatically; reproduce normal startup.
doautocmd VimEnter
sleep 150m

assert_equal(1, get(g:, 'vimrc_plugins_ready', 0))
var plugin_home = g:vimrc_context.plugin_home
var plugin_prefix = substitute(plugin_home, '/\+$', '', '') .. '/'
for runtime_entry in split(&runtimepath, ',')
  if stridx(runtime_entry, plugin_prefix) == 0
    var relative = strpart(runtime_entry, strlen(plugin_prefix))
    var plugin_name = split(relative, '/')[0]
    assert_match('^simple', plugin_name,
      'non-simple plugin reached runtimepath: ' .. runtime_entry)
  endif
endfor
for command_name in [
      'PlugStatus',
      'SimpleFinderFiles',
      'SimpleTree',
      'SimpleLineHealth',
      'SimpleMinimapHealth',
      'SimpleStartify',
      'Startify',
      'SimpleCopyStatus',
      'SimpleCommentHealth',
      'SimpleMotionHealth',
      'SimplePairsHealth',
      'SimpleEditHealth',
      'SimpleMultiHealth',
      'SimpleEditorConfigHealth',
      'SimpleTerminalHealth',
      'TsHlStatus',
      'SimpleCC',
    ]
  assert_equal(2, exists(':' .. command_name), command_name)
endfor

# 健康命令不能只存在，还必须端到端跑通：任何一个抛异常都说明套件装配有问题。
for health_command in [
      'SimpleCommentHealth',
      'SimpleMotionHealth',
      'SimplePairsHealth',
      'SimpleEditHealth',
      'SimpleMultiHealth',
      'SimpleEditorConfigHealth',
      'SimpleTerminalHealth',
      'SimpleLineHealth',
      'SimpleMinimapHealth',
      'SimpleGitHealth',
      'SimpleMarkdownHealth',
      'SimpleCCHealth',
    ]
  var health_error = ''
  try
    execute health_command
  catch
    health_error = v:exception
  endtry
  assert_equal('', health_error, health_command)
endfor

# 启动与健康检查全程必须安静：:messages 里不允许出现 Vim 错误。
for message_line in split(execute('messages'), "\n")
  assert_notmatch('^E\d\+:', message_line)
endfor

# 启动页保留 startify filetype/命令兼容，但实际 UI 每次从 SimpleStartify 的
# renderer 池抽取，并保证紧邻两次不重复。
Startify
assert_equal('startify', &filetype)
assert_equal(1, get(b:, 'simplestartify', 0))
var first_start_style = get(b:, 'simplestartify_style', '')
assert_true(index(g:simplestartify_styles, first_start_style) >= 0)
SimpleStartifyNextStyle
assert_notequal(first_start_style, get(b:, 'simplestartify_style', ''))
execute 'edit ' .. fnameescape(ROOT .. '/.vimrc')

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

# 前缀提示：SimpleWhichKey 必须接管前缀键本身，且不碰前缀下的映射。
for [prefix, mode] in [['<Space>', 'n'], ['<C-w>', 'n'], ['g', 'n'], ['z', 'n'],
      ['[', 'n'], [']', 'n'], ['"', 'n'], ['<Space>', 'x']]
  assert_match('simplewhichkey#Start', maparg(prefix, mode), prefix .. ' ' .. mode)
endfor
assert_equal('<Cmd>SimpleFinderFiles<CR>', maparg('<Space>ff', 'n'))
# 描述来自 g:simplewhichkey_map；面板里 <C-w> 和 ] 要同时有原生命令和映射。
var leader_hints = simplewhichkey#Keys('n', '<leader>')
assert_equal('+git', get(get(leader_hints, 'g', {}), 'desc', ''))
assert_equal('+lsp', get(get(leader_hints, 'l', {}), 'desc', ''))
assert_false(has_key(leader_hints, '1'))
assert_equal('split-vertical',
      get(get(simplewhichkey#Keys('n', '<C-w>'), 'v', {}), 'desc', ''))
var forward_hints = simplewhichkey#Keys('n', ']')
assert_equal('SimpleGitHunkNext', get(get(forward_hints, 'g', {}), 'desc', ''))
assert_equal('next-diff-change', get(get(forward_hints, 'c', {}), 'desc', ''))

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

# Completion confirmation and SimplePairs newline expansion share Enter.
doautocmd InsertEnter
var enter_map = maparg('<CR>', 'i', false, true)
assert_true(get(enter_map, 'expr', 0))
assert_match('simplecc#SelectEnterKey', get(enter_map, 'rhs', ''))
assert_match('simplepairs#Enter', get(enter_map, 'rhs', ''))

enew
noautocmd setlocal filetype=julia
g:VimrcConfigureFiletype()
# SimpleEdit 的 Unicode 补全挂到 <C-x><C-u>，Tab 展开由 SimpleCC 原生组合。
assert_equal('simpleedit#UnicodeComplete', &l:completefunc)
setlocal virtualedit=onemore
setline(1, 'x = \alpha')
cursor(1, strlen(getline(1)) + 1)
assert_equal(repeat("\<BS>", 6) .. 'α', simplecc#SelectTabKey(),
      'SimpleEdit Unicode expansion was not composed into SimpleCC Tab')
setlocal virtualedit=block
execute 'edit ' .. fnameescape(ROOT .. '/.vimrc')

# All migrated mappings point at simple* implementations.
assert_match('simplecomment', maparg('<Space>cc', 'n'))
assert_match('simplecomment', maparg('gc', 'n'))
assert_match('simplecomment', maparg('gcc', 'n'))
assert_match('simplemotion', maparg('<Space>jj', 'n'))
assert_equal('<Cmd>SimpleTerminalToggle<CR>', maparg('<Space>tt', 'n'))
assert_equal('<Cmd>SimpleTerminalKill<CR>', maparg('<Space>tk', 'n'))
assert_match('SendLinesToTerminal', maparg('<Space>tx', 'n'))
assert_match('SendLinesToTerminal', maparg('<Space>tx', 'x'))
assert_match('simplemulti', maparg('<C-n>', 'n'))
assert_equal('<Cmd>SimpleMultiRemove<CR>', maparg('<Space>xr', 'n'))

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
# 断言规范值而不是字面量：minimap 自己会在 BufWinEnter/WinEnter 上重新断言窗口
# 选项，这里要验的是"SimpleLine 改写之后它确实被恢复了"，而不是复制一份字面量
# 等着两边漂移。
assert_equal(simpleminimap#StatuslineExpr(), minimap_status)
assert_notequal('', minimap_status)

# 更新提示接在 SimpleLine 的用户段位上：落后时渲染，最新时消失。
g:vimrc_update_status = {upstream: 'origin/master', ahead: 0, behind: 3}
var behind_status = simpleline#ActiveStatusline()
assert_match('SimpleLineDiagWarn# 󰚰 3 ', behind_status)
g:vimrc_update_status = {upstream: 'origin/master', ahead: 0, behind: 0}
assert_notmatch('󰚰', simpleline#ActiveStatusline())
g:vimrc_update_status = {}

g:VimrcHealth()
assert_equal(0, get(get(g:, 'vimrc_health_last', {}), 'fail', -1))

if !empty(v:errors)
  writefile(v:errors, '/dev/stderr')
  cquit 1
endif
qall!
