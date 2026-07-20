vim9script

var C = g:vimrc_context

# ============================================================================
# 原生键位
# ============================================================================

# 保存 / 配置 / 健康
nnoremap <silent> <leader>fs <Cmd>update<CR>
nnoremap <silent> <leader>fS <Cmd>wall<CR>
nnoremap <silent> <leader>ve <Cmd>execute 'edit ' .. fnameescape(g:vimrc_root .. '/.vimrc')<CR>
nnoremap <silent> <leader>vr <Cmd>execute 'source ' .. fnameescape(g:vimrc_root .. '/.vimrc')<CR>
nnoremap <silent> <leader>vh <Cmd>VimrcHealth<CR>
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

# 仅 Normal 模式：按窗口编号跳转。
nnoremap <silent> <localleader>1 <Cmd>1wincmd w<CR>
nnoremap <silent> <localleader>2 <Cmd>2wincmd w<CR>
nnoremap <silent> <localleader>3 <Cmd>3wincmd w<CR>
nnoremap <silent> <localleader>4 <Cmd>4wincmd w<CR>
nnoremap <silent> <localleader>5 <Cmd>5wincmd w<CR>
nnoremap <silent> <localleader>6 <Cmd>6wincmd w<CR>
nnoremap <silent> <localleader>7 <Cmd>7wincmd w<CR>
nnoremap <silent> <localleader>8 <Cmd>8wincmd w<CR>
nnoremap <silent> <localleader>9 <Cmd>9wincmd w<CR>
nnoremap <silent> <localleader>0 <Cmd>10wincmd w<CR>

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
  nmap <silent> <leader>1 <Plug>(simpleline-buffer-jump-1)
  nmap <silent> <leader>2 <Plug>(simpleline-buffer-jump-2)
  nmap <silent> <leader>3 <Plug>(simpleline-buffer-jump-3)
  nmap <silent> <leader>4 <Plug>(simpleline-buffer-jump-4)
  nmap <silent> <leader>5 <Plug>(simpleline-buffer-jump-5)
  nmap <silent> <leader>6 <Plug>(simpleline-buffer-jump-6)
  nmap <silent> <leader>7 <Plug>(simpleline-buffer-jump-7)
  nmap <silent> <leader>8 <Plug>(simpleline-buffer-jump-8)
  nmap <silent> <leader>9 <Plug>(simpleline-buffer-jump-9)
  nmap <silent> <leader>0 <Plug>(simpleline-buffer-jump-0)

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
  nmap <silent> ]g <Plug>(GitGutterNextHunk)
  nmap <silent> [g <Plug>(GitGutterPrevHunk)
  nnoremap <silent> <leader>gj <Cmd>GitGutterNextHunk<CR>
  nnoremap <silent> <leader>gk <Cmd>GitGutterPrevHunk<CR>
  nnoremap <silent> <leader>gh <Cmd>GitGutterPreviewHunk<CR>
  nnoremap <silent> <leader>ga <Cmd>GitGutterStageHunk<CR>
  nnoremap <silent> <leader>gu <Cmd>GitGutterUndoHunk<CR>
  nnoremap <silent> <leader>gs <Cmd>Git<CR>
  nnoremap <silent> <leader>gb <Cmd>Git blame<CR>
  nnoremap <silent> <leader>gd <Cmd>Gdiffsplit<CR>

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

  # WhichKey 只注册 Normal 模式，避免 Visual range 污染普通命令。
  g:which_key_map = {
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
      b: 'blame',
      d: 'diff',
      h: 'preview-hunk',
      j: 'next-hunk',
      k: 'previous-hunk',
      s: 'status',
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
      e: 'edit-vimrc',
      h: 'health',
      r: 'reload-vimrc',
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
  g:which_key_map[' '] = 'find-files'
  for index in range(0, 9)
    g:which_key_map[string(index)] = 'buffer-' .. string(index)
  endfor

  try
    which_key#register('<Space>', 'g:which_key_map', 'n')
    nnoremap <silent> <leader> <Cmd>WhichKey '<Space>'<CR>
    nnoremap <silent> <localleader> <Cmd>WhichKey ','<CR>
  catch /^Vim\%((\a\+)\)\=:E117/
    echohl WarningMsg
    echomsg '[vimrc] WhichKey 注册失败'
    echohl None
  endtry
endif
