vim9script

var C = g:vimrc_context

# SimpleMarkdown 的渲染选项是 g: 变量，没有命令可以翻转。改完要重绘才看得见，
# 而重绘是 SimpleMarkdownRefresh 的事，所以两步绑在一起；没有预览窗口时它什么
# 也不做，因此不必先判断。
def ToggleMarkdown(option: string, label: string)
  var name = 'simplemarkdown_' .. option
  g:[name] = get(g:, name, 0) ? 0 : 1
  silent! SimpleMarkdownRefresh
  echo printf('[SimpleMarkdown] %s%s', label, g:[name] ? '：开' : '：关')
enddef

# ============================================================================
# 原生键位
# ============================================================================

# 保存 / 配置 / 健康
nnoremap <silent> <leader>fs <Cmd>update<CR>
nnoremap <silent> <leader>fS <Cmd>wall<CR>
nnoremap <silent> <leader>ve <Cmd>execute 'edit ' .. fnameescape(g:vimrc_root .. '/.vimrc')<CR>
nnoremap <silent> <leader>vr <Cmd>execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')<CR>
nnoremap <silent> <leader>vh <Cmd>VimrcHealth<CR>
nnoremap <silent> <leader>vc <Cmd>VimrcUpdateCheck<CR>
nnoremap <silent> <leader>vu <Cmd>VimrcUpdate<CR>
nnoremap <silent> <leader>h <Cmd>nohlsearch<CR>

# 保留 Vim 原生 s / ( / )；快速跳转统一放到 leader 下。
xnoremap < <gv
xnoremap > >gv
xnoremap p "_dP
nnoremap Y y$
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

# 窗口
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l
nnoremap <silent> <leader>ww <C-w>w
nnoremap <silent> <leader>wd <Cmd>close<CR>
nnoremap <silent> <leader>ws <C-w>s
nnoremap <silent> <leader>wv <C-w>v
nnoremap <silent> <leader>wo <C-w>o
nnoremap <silent> <leader>w= <C-w>=
nnoremap <silent> <leader>wh <C-w>h
nnoremap <silent> <leader>wj <C-w>j
nnoremap <silent> <leader>wk <C-w>k
nnoremap <silent> <leader>wl <C-w>l
nnoremap <silent> <leader>wH <C-w>5<
nnoremap <silent> <leader>wJ <Cmd>resize +5<CR>
nnoremap <silent> <leader>wK <Cmd>resize -5<CR>
nnoremap <silent> <leader>wL <C-w>5>
nnoremap <silent> <C-Left> <C-w>5<
nnoremap <silent> <C-Down> <Cmd>resize +5<CR>
nnoremap <silent> <C-Up> <Cmd>resize -5<CR>
nnoremap <silent> <C-Right> <C-w>5>

# Buffer / quickfix
nnoremap <silent> <leader>bn <Cmd>bnext<CR>
nnoremap <silent> <leader>bk <Cmd>bprevious<CR>
nnoremap <silent> <leader>bl <Cmd>buffer #<CR>
nnoremap <silent> <leader>bd <Cmd>confirm bdelete<CR>
nnoremap <silent> ]q <Cmd>cnext<CR>
nnoremap <silent> [q <Cmd>cprevious<CR>
nnoremap <silent> ]l <Cmd>lnext<CR>
nnoremap <silent> [l <Cmd>lprevious<CR>

# 仅 Normal 模式：按窗口编号跳转，0 表示第 10 个窗口。
for window_nr in range(1, 10)
  execute $'nnoremap <silent> <localleader>{window_nr % 10} <Cmd>{window_nr}wincmd w<CR>'
endfor

# 尾随空白
nnoremap <silent> <leader>cw <Cmd>StripWhitespace<CR>

# 终端模式
tnoremap <silent> <Esc><Esc> <C-\><C-n>

# ============================================================================
# 插件键位
# ============================================================================
if get(C, 'plugins_ready', false)
  # 文件 / 搜索
  nnoremap <silent> <leader>ff <Cmd>SimpleFinderFiles<CR>
  nnoremap <silent> <leader>fr <Cmd>SimpleFinderRecent<CR>
  nnoremap <silent> <leader>fo <Cmd>SimpleFinderRecent<CR>
  nnoremap <silent> <leader>fh <Cmd>SimpleFinderRecent<CR>
  nnoremap <silent> <leader>fb <Cmd>SimpleFinderBuffers<CR>
  nnoremap <silent> <leader>bb <Cmd>SimpleFinderBuffers<CR>
  nnoremap <silent> <leader>fg <Cmd>SimpleFinderIGrep<CR>
  nnoremap <silent> <leader>fw <Cmd>SimpleFinderGrepWord<CR>
  xnoremap <silent> <leader>fg <Cmd>SimpleFinderGrepVisual<CR>
  xnoremap <silent> <leader>fw <Cmd>SimpleFinderGrepVisual<CR>
  nnoremap <silent> <leader>st <Cmd>SimpleFinderIGrep<CR>
  nnoremap <silent> <leader>sg <Cmd>SimpleFinderGrep<CR>
  nnoremap <silent> <leader>sw <Cmd>SimpleFinderGrepWord<CR>
  xnoremap <silent> <leader>sg <Cmd>SimpleFinderGrepVisual<CR>
  xnoremap <silent> <leader>sw <Cmd>SimpleFinderGrepVisual<CR>
  nnoremap <silent> <leader><Space> <Cmd>SimpleFinderFiles<CR>

  nmap <silent> <leader>e <Plug>(simpletree-toggle)
  nmap <silent> <leader>ft <Plug>(simpletree-toggle)
  nnoremap <silent> <leader>fT <Cmd>SimpleTreeReveal<CR>
  nmap <silent> <F3> <Plug>(simpletree-toggle)

  # Buffer tabline：数字表示可见 buffer 索引，不是 Vim tabpage。
  nmap <silent> <leader>bp <Plug>(simpleline-buffer-pick)
  for buffer_nr in range(0, 9)
    execute $'nmap <silent> <leader>{buffer_nr} <Plug>(simpleline-buffer-jump-{buffer_nr})'
  endfor

  # LSP；显式映射规避 SimpleCC 旧版默认 RHS 尾随空格。
  nmap <silent> <leader>rn <Plug>(simplecc-rename)
  nmap <silent> <leader>ca <Plug>(simplecc-code-action)
  nmap <silent> <leader>fm <Plug>(simplecc-format)
  nmap <silent> <leader>cf <Plug>(simplecc-format)
  nmap <silent> <leader>lo <Plug>(simplecc-outline)
  nmap <silent> <leader>ih <Plug>(simplecc-inlay-hints)

  nnoremap <silent> <leader>ld <Cmd>SimpleCCDefinition<CR>
  nnoremap <silent> <leader>lr <Cmd>SimpleCCReferences<CR>
  nnoremap <silent> <leader>ln <Cmd>SimpleCCRename<CR>
  nnoremap <silent> <leader>la <Cmd>SimpleCCAction<CR>
  nnoremap <silent> <leader>lf <Cmd>SimpleCCFormat<CR>
  nnoremap <silent> <leader>lh <Cmd>SimpleCCHover<CR>
  nnoremap <silent> <leader>ls <Cmd>SimpleCCSignatureHelp<CR>
  nnoremap <silent> <leader>le <Cmd>SimpleCCDiagnostics<CR>
  nnoremap <silent> <leader>li <Cmd>SimpleCC<CR>
  nnoremap <silent> <leader>lR <Cmd>SimpleCCRestart<CR>
  nnoremap <silent> <leader>ll <Cmd>SimpleCCLog<CR>
  nnoremap <silent> <leader>lc <Cmd>SimpleCCConfig<CR>
  nnoremap <silent> <leader>lC <Cmd>SimpleCCReloadConfig<CR>
  nnoremap <silent> <leader>lI <Cmd>SimpleCCInstall<CR>
  nnoremap <silent> <leader>lS <Cmd>SimpleCCServers<CR>
  nnoremap <silent> <leader>lw <Cmd>SimpleCCWorkspaceSymbolLive<CR>
  nnoremap <silent> <leader>lt <Cmd>SimpleCCTypeDef<CR>
  nnoremap <silent> <leader>lm <Cmd>SimpleCCImplementation<CR>
  nnoremap <silent> <leader>lp <Cmd>SimpleCCInlayHints<CR>
  nnoremap <silent> <leader>lH <Cmd>SimpleCCHighlight<CR>
  nnoremap <silent> <leader>lk <Cmd>SimpleCCIncomingCalls<CR>
  nnoremap <silent> <leader>lK <Cmd>SimpleCCOutgoingCalls<CR>
  nnoremap <silent> <leader>lT <Cmd>SimpleCCSemanticTokens<CR>
  nnoremap <silent> <leader>lL <Cmd>SimpleCCCodeLens<CR>
  nnoremap <silent> <leader>lF <Cmd>SimpleCCFold<CR>

  # Git
  nnoremap <silent> ]g <Cmd>SimpleGitHunkNext<CR>
  nnoremap <silent> [g <Cmd>SimpleGitHunkPrev<CR>
  nnoremap <silent> <leader>gj <Cmd>SimpleGitHunkNext<CR>
  nnoremap <silent> <leader>gk <Cmd>SimpleGitHunkPrev<CR>
  nnoremap <silent> <leader>gp <Cmd>SimpleGitHunkPreview<CR>
  nnoremap <silent> <leader>ga <Cmd>SimpleGitHunkStage<CR>
  nnoremap <silent> <leader>gu <Cmd>SimpleGitHunkUndo<CR>
  nnoremap <silent> <leader>gb <Cmd>SimpleGitBlame<CR>
  nnoremap <silent> <leader>gm <Cmd>SimpleGitBlameLine<CR>
  nnoremap <silent> <leader>gh <Cmd>SimpleGitHistory<CR>
  nnoremap <silent> <leader>gd <Cmd>SimpleGitDiff<CR>
  nnoremap <silent> <leader>gs <Cmd>SimpleGitStatus<CR>
  nnoremap <silent> <leader>gt <Cmd>SimpleGitToggleLineBlame<CR>
  nnoremap <silent> <leader>gH <Cmd>SimpleGitHealth<CR>

  # 注释
  nnoremap <silent> <leader>cc <Cmd>TComment<CR>
  xnoremap <silent> <leader>cc :TComment<CR>
  nnoremap <silent> <leader>cl <Cmd>TComment<CR>
  xnoremap <silent> <leader>cl :TComment<CR>

  # EasyMotion：不再覆盖原生 s。
  nmap <leader>jj <Plug>(easymotion-overwin-f2)
  nmap <localleader>j <Plug>(easymotion-j)
  nmap <localleader>k <Plug>(easymotion-k)

  # Tree-sitter
  nmap <silent> <leader>th <Plug>(simpletreesitter-toggle)
  nmap <silent> <leader>to <Plug>(simpletreesitter-outline-toggle)
  nnoremap <silent> <leader>ta <Cmd>TsHlDumpAST<CR>
  nnoremap <silent> <leader>ts <Cmd>TsHlStatus<CR>

  # Minimap
  nmap <silent> <leader>mm <Plug>(simpleminimap-toggle)
  nmap <silent> <leader>mf <Plug>(simpleminimap-focus)
  nnoremap <silent> <leader>ms <Cmd>SimpleMinimapStyle<CR>
  nnoremap <silent> <leader>mh <Cmd>SimpleMinimapHealth<CR>

  # Markdown 预览（终端内）
  nmap <silent> <leader>pp <Plug>(simplemarkdown-toggle)
  nmap <silent> <leader>pf <Plug>(simplemarkdown-focus)
  nmap <silent> <leader>po <Plug>(simplemarkdown-toc)
  nnoremap <silent> <leader>pr <Cmd>SimpleMarkdownRefresh<CR>
  nnoremap <silent> <leader>ps <Cmd>SimpleMarkdownStyle<CR>
  nnoremap <silent> <leader>ph <Cmd>SimpleMarkdownHealth<CR>

  # Markdown 预览（浏览器，由 omd 提供）。两个预览是并存的：终端里的那个随
  # 打字更新、光标同步，浏览器里的那个才有图片和排版好的公式，跟的是 :w。
  # 需要先 `cargo install omd`；没装时只会提示，终端预览不受影响。
  nmap <silent> <leader>pb <Plug>(simplemarkdown-external)
  nnoremap <silent> <leader>pB <Cmd>SimpleMarkdownExternalStatic<CR>
  nnoremap <silent> <leader>pq <Cmd>SimpleMarkdownExternalClose!<CR>

  # 这几个渲染开关只有 g: 变量，没有对应命令：就地翻转再重绘。默认关着的两个
  # 都会占掉正文的列宽，所以是按需打开而不是常驻。
  nnoremap <silent> <leader>pn <ScriptCmd>ToggleMarkdown('code_numbers', '代码行号')<CR>
  nnoremap <silent> <leader>pz <ScriptCmd>ToggleMarkdown('table_zebra', '表格斑马纹')<CR>
  nnoremap <silent> <leader>pu <ScriptCmd>ToggleMarkdown('show_urls', '链接目标')<CR>

  # Clipboard
  nmap <silent> <leader>y <Plug>(SimpleCopyYank)
  xmap <silent> <leader>y <Plug>(SimpleCopyVisual)
  nnoremap <silent> <leader>cs <Cmd>SimpleCopyStatus<CR>

  # 浮动终端：保留 F7/F8，并提供可移植 leader 键。
  nnoremap <silent> <leader>tt <Cmd>FloatermToggle<CR>
  nnoremap <silent> <leader>tn <Cmd>FloatermNew<CR>
  nnoremap <silent> <leader>tp <Cmd>FloatermPrev<CR>
  nnoremap <silent> <leader>tN <Cmd>FloatermNext<CR>
  nnoremap <silent> <S-F7> <Cmd>FloatermPrev<CR>
  tnoremap <silent> <S-F7> <C-\><C-n><Cmd>FloatermPrev<CR>
  nnoremap <silent> <F7> <Cmd>FloatermNext<CR>
  tnoremap <silent> <F7> <C-\><C-n><Cmd>FloatermNext<CR>
  nnoremap <silent> <F8> <Cmd>FloatermToggle<CR>
  tnoremap <silent> <F8> <C-\><C-n><Cmd>FloatermToggle<CR>
  nnoremap <silent> <S-F8> <Cmd>FloatermNew<CR>
  tnoremap <silent> <S-F8> <C-\><C-n><Cmd>FloatermNew<CR>

  # 键位描述只写 Normal 模式这一份：Visual 模式的映射 SimpleWhichKey 自己从
  # maplist() 里读，Vim 原生的 g/z/<C-w>/[/] 由插件内置表覆盖，这里都不重复。
  g:simplewhichkey_map = {
    e: 'file-tree',
    h: 'clear-search-highlight',
    y: 'copy-to-clipboard',
    i: {
      name: '+inlay',
      h: 'inlay-hints',
    },
    r: {
      name: '+refactor',
      n: 'rename',
    },
    b: {
      name: '+buffer',
      b: 'find-buffers',
      d: 'delete-buffer',
      k: 'previous-buffer',
      l: 'alternate-buffer',
      n: 'next-buffer',
      p: 'pick-buffer',
    },
    c: {
      name: '+code',
      a: 'code-action',
      c: 'comment',
      f: 'format',
      l: 'comment-compat',
      s: 'clipboard-status',
      w: 'strip-whitespace',
    },
    f: {
      name: '+file',
      b: 'find-buffers',
      f: 'find-files',
      g: 'live-grep',
      h: 'recent-files-compat',
      m: 'format',
      o: 'recent-files-compat',
      r: 'recent-files',
      s: 'save',
      S: 'save-all',
      t: 'file-tree',
      T: 'reveal-in-tree',
      w: 'grep-word',
    },
    g: {
      name: '+git',
      a: 'stage-hunk',
      b: 'blame-sidebar',
      d: 'diff-head',
      h: 'file-history',
      H: 'health',
      j: 'next-hunk',
      k: 'previous-hunk',
      m: 'line-blame',
      p: 'preview-hunk',
      s: 'status',
      t: 'toggle-line-blame',
      u: 'undo-hunk',
    },
    j: {
      name: '+jump',
      j: 'easymotion',
    },
    l: {
      name: '+lsp',
      a: 'code-action',
      c: 'open-config',
      C: 'reload-config',
      d: 'definition',
      e: 'diagnostics',
      f: 'format',
      h: 'hover',
      H: 'highlight-symbol',
      i: 'status',
      I: 'install-server',
      k: 'incoming-calls',
      K: 'outgoing-calls',
      l: 'show-log',
      m: 'implementation',
      n: 'rename',
      o: 'outline',
      p: 'inlay-hints',
      r: 'references',
      R: 'restart',
      s: 'signature-help',
      S: 'list-servers',
      t: 'type-definition',
      T: 'semantic-tokens',
      w: 'workspace-symbol',
      L: 'code-lens',
      F: 'folding-range',
    },
    m: {
      name: '+minimap',
      f: 'focus',
      h: 'health',
      m: 'toggle',
      s: 'style',
    },
    p: {
      name: '+preview',
      b: 'browser-preview',
      B: 'browser-render-once',
      f: 'focus',
      h: 'health',
      n: 'toggle-code-numbers',
      o: 'contents',
      p: 'toggle',
      q: 'browser-close-all',
      r: 'refresh',
      s: 'style',
      u: 'toggle-link-targets',
      z: 'toggle-table-zebra',
    },
    s: {
      name: '+search',
      g: 'grep',
      t: 'live-grep',
      w: 'grep-word',
    },
    t: {
      name: '+tools',
      a: 'treesitter-ast',
      h: 'treesitter-toggle',
      n: 'new-terminal',
      N: 'next-terminal',
      o: 'treesitter-outline',
      p: 'previous-terminal',
      s: 'treesitter-status',
      t: 'toggle-terminal',
    },
    v: {
      name: '+vimrc',
      c: 'check-update',
      e: 'edit-vimrc',
      h: 'health',
      r: 'reload-vimrc',
      u: 'update-vimrc',
    },
    w: {
      name: '+window',
      d: 'close',
      h: 'left',
      j: 'down',
      k: 'up',
      l: 'right',
      H: 'resize-left',
      J: 'resize-down',
      K: 'resize-up',
      L: 'resize-right',
      o: 'only',
      s: 'split-below',
      v: 'split-right',
      w: 'other-window',
      '=': 'balance',
    },
  }
  g:simplewhichkey_map[' '] = 'find-files'

  # 前缀键由插件自己接管（<leader>、<localleader>，以及 g/z/Z/<C-w>/[/]/"/'/`），
  # 这里只补描述。localleader 下的数字跳窗从 rhs 就能看懂，不必再写一遍。
  try
    simplewhichkey#Register('<leader>', 'g:simplewhichkey_map', 'n')
    simplewhichkey#Describe({
      '<localleader>j': 'easymotion-down',
      '<localleader>k': 'easymotion-up',
    })
  catch /^Vim\%((\a\+)\)\=:E117/
    echohl WarningMsg
    echomsg '[vimrc] SimpleWhichKey 注册失败'
    echohl None
  endtry
endif
