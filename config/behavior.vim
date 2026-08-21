vim9script

var C = g:vimrc_context

# ============================================================================
# Vim9 辅助函数
# ============================================================================
# 只有测试和键位依赖的入口保留为全局函数；其余为脚本局部，重新 source 时
# 由 Vim9 自动重定义。

# SimpleCC buffer 键位：同一张表负责按 filetype 安装，以及在 filetype 切换
# 后清理残留的 buffer-local 映射。
const SIMPLECC_NMAPS = [
  ['gd', '<Plug>(simplecc-definition)'],
  ['gr', '<Plug>(simplecc-references)'],
  ['K', '<Plug>(simplecc-hover)'],
  ['gi', '<Plug>(simplecc-implementation)'],
  ['gy', '<Plug>(simplecc-type-definition)'],
  ['[d', '<Plug>(simplecc-prev-diagnostic)'],
  [']d', '<Plug>(simplecc-next-diagnostic)'],
]
const SIMPLECC_IMAPS = [
  ['<Tab>', '<Plug>(simplecc-select-tab)'],
  ['<S-Tab>', '<Plug>(simplecc-select-shift-tab)'],
  ['<Down>', '<Plug>(simplecc-select-down)'],
  ['<Up>', '<Plug>(simplecc-select-up)'],
]

# 配置了语言服务器的 filetype 才接管 gd/gr/gi/K 等原生动作。
const LSP_FILETYPES = [
  'rust',
  'c',
  'cpp',
  'objc',
  'objcpp',
  'python',
  'go',
  'gomod',
  'gowork',
  'typescript',
  'javascript',
  'typescriptreact',
  'javascriptreact',
  'lua',
  'julia',
]

# [filetypes, setlocal 参数]；未命中的 filetype 使用基线缩进。
const INDENT_RULES = [
  [['go', 'gomod', 'gowork'],
    ['noexpandtab', 'shiftwidth=4', 'softtabstop=0', 'tabstop=4']],
  [['c', 'cpp', 'javascript', 'javascriptreact', 'typescript',
    'typescriptreact', 'json', 'jsonc', 'yaml', 'lua', 'sh', 'bash',
    'zsh', 'haskell', 'vim'],
    ['shiftwidth=2', 'softtabstop=2', 'tabstop=2']],
  [['make'],
    ['noexpandtab', 'shiftwidth=8', 'softtabstop=0', 'tabstop=8']],
]

const PROSE_FILETYPES = ['markdown', 'org', 'text', 'gitcommit']

const SIDEBAR_FILETYPES = [
  'help',
  'qf',
  'startify',
  'simpletree',
  'simpleminimap',
  'terminal',
]

def ApplyHighlights()
  highlight ExtraWhitespace ctermbg=red guibg=#5f0000
enddef

def ClearStaleSimpleccMaps()
  for [mode, mappings] in [['n', SIMPLECC_NMAPS], ['i', SIMPLECC_IMAPS]]
    for mapping in mappings
      var existing = maparg(mapping[0], mode, false, true)
      if get(existing, 'buffer', 0) == 1
            \ && get(existing, 'rhs', '') ==# mapping[1]
        execute $'silent! {mode}unmap <buffer> ' .. mapping[0]
      endif
    endfor
  endfor
  var enter_mapping = maparg('<CR>', 'i', false, true)
  var enter_rhs = get(enter_mapping, 'rhs', '')
  if get(enter_mapping, 'buffer', 0) == 1
        \ && enter_rhs =~# 'simplecc#SelectEnterKey'
        \ && enter_rhs =~# 'simplepairs#Enter'
    silent! iunmap <buffer> <CR>
  endif
enddef

def ApplyBufferBaseline()
  # 先恢复稳定基线，避免同一 buffer 改 filetype 后局部设置泄漏。
  setlocal expandtab
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal tabstop=4
  setlocal wrap
  setlocal nolinebreak
  setlocal nobreakindent
  setlocal textwidth=0
  setlocal colorcolumn=
  setlocal conceallevel=0
  setlocal formatoptions-=c
  setlocal formatoptions-=r
  setlocal formatoptions-=o
  setlocal formatoptions+=j
  setlocal completefunc=
enddef

def ApplyFiletypeOverrides()
  for [filetypes, arguments] in INDENT_RULES
    if index(filetypes, &filetype) >= 0
      execute 'setlocal ' .. join(arguments)
      break
    endif
  endfor

  if index(PROSE_FILETYPES, &filetype) >= 0
    setlocal linebreak
    setlocal breakindent
  endif

  if &filetype ==# 'gitcommit'
    setlocal textwidth=72
    setlocal colorcolumn=73
  endif

  # SimpleEdit 的 LaTeX/emoji 序列补全挂到 <C-x><C-u>；SimpleCC 走自己的
  # 补全通道，不经过 completefunc，两者互不干扰。
  if &filetype ==# 'julia' && exists('g:loaded_simpleedit')
    setlocal completefunc=simpleedit#UnicodeComplete
  endif
enddef

def ApplyLspMappings()
  # Keep Vim's native gd/gr/gi/K motions everywhere except buffers covered by
  # the configured language-server set.
  if !C.plugins_ready
        \ || get(b:, 'vimrc_large_file', 0)
        \ || index(LSP_FILETYPES, &filetype) < 0
    return
  endif
  for mapping in SIMPLECC_NMAPS
    execute $'nmap <buffer> <silent> {mapping[0]} {mapping[1]}'
  endfor
  for mapping in SIMPLECC_IMAPS
    execute $'imap <buffer> <silent> {mapping[0]} {mapping[1]}'
  endfor
enddef

def g:VimrcConfigureFiletype()
  ClearStaleSimpleccMaps()
  ApplyBufferBaseline()
  ApplyFiletypeOverrides()
  # FileType can run after SimpleEditorConfig's BufReadPost hook. Reapply it so
  # project policy wins over this configuration's fallback indentation rules.
  if exists('g:loaded_simpleeditorconfig') && !empty(bufname())
    simpleeditorconfig#Apply(bufnr())
  endif
  ApplyLspMappings()
enddef

def RestoreCursor()
  var last_line = line('''"')
  if last_line > 1 && last_line <= line('$') && &filetype !=# 'gitcommit'
    execute 'normal! g`"'
  endif
enddef

def ClearWhitespaceMatch()
  var match_id = get(w:, 'vimrc_trailing_ws_match', -1)
  if type(match_id) == v:t_number && match_id > 0
    try
      matchdelete(match_id)
    catch
    endtry
  endif
  w:vimrc_trailing_ws_match = -1
enddef

def ShowWhitespaceMatch()
  ClearWhitespaceMatch()
  if &buftype !=# ''
        \ || !&modifiable
        \ || get(b:, 'vimrc_large_file', 0)
        \ || index(SIDEBAR_FILETYPES, &filetype) >= 0
    return
  endif
  w:vimrc_trailing_ws_match = matchadd('ExtraWhitespace', '\s\+$', 10)
enddef

def g:VimrcStripWhitespace()
  if !&modifiable || &readonly || &binary
    g:VimrcWarn('当前 buffer 不允许清理尾随空白')
    return
  endif

  var view = winsaveview()
  try
    silent! keepjumps keeppatterns :%substitute/\s\+$//e
  finally
    winrestview(view)
    ShowWhitespaceMatch()
  endtry
enddef

command! StripWhitespace call g:VimrcStripWhitespace()

# ============================================================================
# 自动命令
# ============================================================================
augroup vimrc_core
  autocmd!
  autocmd FileType * call g:VimrcConfigureFiletype()
  autocmd BufReadPost * call RestoreCursor()
  autocmd FocusGained,BufEnter * silent! checktime
  autocmd VimResized * wincmd =
  autocmd ColorScheme * call ApplyHighlights()
  autocmd InsertEnter * call ClearWhitespaceMatch()
  autocmd InsertLeave,BufWinEnter,WinEnter * call ShowWhitespaceMatch()
  autocmd BufWinLeave * call ClearWhitespaceMatch()
  autocmd FileType help,man
        \ nnoremap <buffer> <silent> q <Cmd>close<CR>
  autocmd FileType qf
        \ nnoremap <buffer> <silent> q <Cmd>close<CR>
  if exists('##TerminalOpen')
    autocmd TerminalOpen *
          \ setlocal nonumber norelativenumber signcolumn=no
  endif
augroup END

if &filetype !=# ''
  g:VimrcConfigureFiletype()
endif
ApplyHighlights()
