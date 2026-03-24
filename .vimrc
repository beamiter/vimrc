vim9script

# ======================================================================
# 基础设置
# ======================================================================
set nocompatible
&t_TI = ""
&t_TE = ""
# 设置 RGB 颜色支持
&t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
&t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
g:netrw_fastbrowse = 0

# 基本编辑器设置
syntax on
filetype off
set autoindent
set backspace=indent,eol,start
set clipboard+=unnamedplus
set encoding=utf-8
set expandtab
set guioptions=
set guifont=SauceCodePro\ Nerd\ Font\ Regular\ 11.5
set guifontwide=Sans\ Regular\ 11.5
set nobackup noswapfile nowritebackup
set number relativenumber
set shiftwidth=4 tabstop=4
set shortmess+=c
set showtabline=2 laststatus=2
set pumheight=10
set termguicolors
set noautochdir
set scrolloff=3 sidescrolloff=3
set timeoutlen=500
set wildmenu
set mouse=a
set hlsearch
set ignorecase smartcase
set updatetime=300
set signcolumn=yes

# ======================================================================
# 自动命令
# ======================================================================
augroup vimrc_settings
  autocmd!
  # 针对不同文件类型的缩进设置
  autocmd FileType c,cpp setlocal shiftwidth=2 tabstop=2

  # 针对不同文件类型的 conceallevel 设置
  autocmd FileType json,markdown g:indentLine_conceallevel = 0
  autocmd FileType javascript,python,c,cpp,java,vim,shell g:indentLine_conceallevel = 2
augroup END

# ======================================================================
# 插件管理 (SimplePlug — Vim9 + Rust 后端)
# ======================================================================
# 自举：自动安装 simpleplug 本身
var simpleplug_home = expand('~/.vim/plugged/simpleplug')
var simpleplug_bootstrapping = false
if !isdirectory(simpleplug_home)
  simpleplug_bootstrapping = true
  echom '正在安装 SimplePlug...'
  silent !mkdir -p ~/.vim/plugged
  silent !git clone --depth 1 https://github.com/beamiter/simpleplug.git ~/.vim/plugged/simpleplug
  if isdirectory(simpleplug_home)
    echom '正在编译 SimplePlug daemon...'
    silent execute '!cd ' .. simpleplug_home .. ' && ./install.sh'
  endif
endif
if isdirectory(simpleplug_home) && stridx(&runtimepath, simpleplug_home) < 0
  &runtimepath = simpleplug_home .. ',' .. &runtimepath
endif

simpleplug#Begin('~/.vim/plugged')

# 编程增强插件
simpleplug#Plug('ludovicchabant/vim-gutentags')
simpleplug#Plug('JuliaEditorSupport/julia-vim')
simpleplug#Plug('kdheepak/JuliaFormatter.vim')
simpleplug#Plug('neovimhaskell/haskell-vim')

# UI 增强插件
simpleplug#Plug('ryanoasis/vim-devicons')
simpleplug#Plug('beamiter/simpleline', {do: './install.sh'})
simpleplug#Plug('Yggdroot/indentLine')
simpleplug#Plug('mhinz/vim-startify')

# 导航和搜索插件
simpleplug#Plug('junegunn/fzf', {dir: '~/.fzf', do: './install --all'})
simpleplug#Plug('junegunn/fzf.vim')
simpleplug#Plug('liuchengxu/vim-clap', {do: 'make install'})
simpleplug#Plug('easymotion/vim-easymotion')

# 编辑增强插件
simpleplug#Plug('cohama/lexima.vim')
simpleplug#Plug('tomtom/tcomment_vim')
simpleplug#Plug('ntpeters/vim-better-whitespace')
simpleplug#Plug('andymass/vim-matchup')
simpleplug#Plug('mg979/vim-visual-multi')
simpleplug#Plug('sheerun/vim-polyglot')

# Git 相关插件
simpleplug#Plug('tpope/vim-fugitive')
simpleplug#Plug('airblade/vim-gitgutter')

# 终端和工具插件
simpleplug#Plug('voldikss/vim-floaterm')
simpleplug#Plug('liuchengxu/vim-which-key')

simpleplug#Plug('beamiter/simpleclipboard', {do: './install.sh'})
simpleplug#Plug('beamiter/simpletree', {do: './install.sh'})
simpleplug#Plug('beamiter/simpletreesitter', {do: './install.sh'})
simpleplug#Plug('beamiter/simpleplug', {do: './install.sh'})
simpleplug#Plug('beamiter/simplecc', {do: './install.sh'})

simpleplug#End()

# 首次自举后自动安装所有插件
if simpleplug_bootstrapping
  autocmd VimEnter * ++once PlugInstall
endif

# ======================================================================
# 颜色主题设置
# ======================================================================
set background=dark
try
  colorscheme spacemacs
catch
  # 插件未安装时静默跳过
endtry

# ======================================================================
# 插件配置
# ======================================================================

# --- lexima 自动补全括号等
try | lexima#init() | catch | endtry

# --- gutentags 代码标签
g:gutentags_enabled = 0

# --- vim-which-key 快捷键提示
g:mapleader = "\<Space>"
g:maplocalleader = ','
try
  which_key#register('<Space>', "g:which_key_map")
catch
endtry
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey ','<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual ','<CR>

nnoremap <silent> <F3> :SimpleTree<CR>
nnoremap <silent> <leader>ft :SimpleTree<CR>

# 定义前缀字典
g:which_key_map = {}
g:which_key_map['w'] = {
  name: '+windows',
  w: ['<C-W>w', 'other-window'],
  d: ['<C-W>c', 'delete-window'],
  '2': ['<C-W>v', 'layout-double-columns'],
  h: ['<C-W>h', 'window-left'],
  j: ['<C-W>j', 'window-below'],
  l: ['<C-W>l', 'window-right'],
  k: ['<C-W>k', 'window-up'],
  o: ['<C-W>o', 'window-only'],
  H: ['<C-W>5<', 'expand-window-left'],
  J: [':resize +5', 'expand-window-below'],
  L: ['<C-W>5>', 'expand-window-right'],
  K: [':resize -5', 'expand-window-up'],
  '=': ['<C-W>=', 'balance-window'],
  s: ['<C-W>s', 'split-window-below'],
  v: ['<C-W>v', 'split-window-right'],
}

# --- gitgutter 代码变更提示
g:gitgutter_map_keys = 0
nmap ]g <Plug>(GitGutterNextHunk)
nmap [g <Plug>(GitGutterPrevHunk)
map <silent><leader>gj :GitGutterNextHunk<CR>
map <silent><leader>gk :GitGutterPrevHunk<CR>

# --- 窗口调整快捷键
nmap ( :vert res -5<CR>
nmap ) :vert res +5<CR>
nmap <C-Left> :vert res -5<CR>
nmap <C-Right> :vert res +5<CR>

# --- tcomment_vim 代码注释
map <silent><leader>cl :TComment<CR>

# --- vim-floaterm 浮动终端
nnoremap <silent> <S-F7> :FloatermPrev<CR>
tnoremap <silent> <S-F7> <C-\><C-n>:FloatermPrev<CR>
nnoremap <silent> <F7> :FloatermNext<CR>
tnoremap <silent> <F7> <C-\><C-n>:FloatermNext<CR>
nnoremap <silent> <F8> :FloatermToggle<CR>
tnoremap <silent> <F8> <C-\><C-n>:FloatermToggle<CR>
nnoremap <silent> <S-F8> :FloatermNew<CR>
tnoremap <silent> <S-F8> <C-\><C-n>:FloatermNew<CR>

# --- vim-clap 搜索工具
nnoremap <leader>st :Clap igrep<CR>
nnoremap <leader>sg :Clap grep<CR>
xnoremap <leader>sg :Clap grep --query=@visual<CR>
nnoremap <leader>sw :Clap grep --query=<cword><CR>
xnoremap <leader>sw :Clap grep --query=@visual<CR>
nnoremap <leader>fr :Clap recent_files<CR>
nnoremap <leader>fo :Clap recent_files<CR>
nnoremap <leader>fh :Clap recent_files<CR>
nnoremap <leader>bb :Clap buffers<CR>
nnoremap <leader>ff :Clap files<CR>
nnoremap <leader><Space> :Clap files<CR>

# --- easymotion 快速移动
g:EasyMotion_do_mapping = 0
nmap s <Plug>(easymotion-overwin-f2)
g:EasyMotion_smartcase = 1
map <localleader>j <Plug>(easymotion-j)
map <localleader>k <Plug>(easymotion-k)

# --- 窗口快速切换
noremap <silent> <localleader>1 :<C-u>1 wincmd w<CR>
noremap <silent> <localleader>2 :<C-u>2 wincmd w<CR>
noremap <silent> <localleader>3 :<C-u>3 wincmd w<CR>
noremap <silent> <localleader>4 :<C-u>4 wincmd w<CR>
noremap <silent> <localleader>5 :<C-u>5 wincmd w<CR>
noremap <silent> <localleader>6 :<C-u>6 wincmd w<CR>
noremap <silent> <localleader>7 :<C-u>7 wincmd w<CR>
noremap <silent> <localleader>8 :<C-u>8 wincmd w<CR>
noremap <silent> <localleader>9 :<C-u>9 wincmd w<CR>
noremap <silent> <localleader>0 :<C-u>10 wincmd w<CR>

# --- simpleline 状态栏
g:simpleline_separator = 'arrow'
g:simpleline_nerdfont = 1
g:simpleline_git_interval = 2000

# 标签页快速切换
nmap <leader>1 :BufferJump1<CR>
nmap <leader>2 :BufferJump2<CR>
nmap <leader>3 :BufferJump3<CR>
nmap <leader>4 :BufferJump4<CR>
nmap <leader>5 :BufferJump5<CR>
nmap <leader>6 :BufferJump6<CR>
nmap <leader>7 :BufferJump7<CR>
nmap <leader>8 :BufferJump8<CR>
nmap <leader>9 :BufferJump9<CR>
nmap <leader>0 :BufferJump0<CR>

# --- JuliaFormatter
nnoremap <localleader>jf :JuliaFormatterFormat<CR>
vnoremap <localleader>jf :JuliaFormatterFormat<CR>

# --- simplecc LSP 客户端
g:simplecc_auto_start = 1
g:simplecc_auto_complete = 1
g:simplecc_complete_delay = 100
g:simplecc_config_path = expand('~/.vim/simplecc.json')
g:simplecc_sign_error = 'E>'
g:simplecc_sign_warn = 'W>'
g:simplecc_sign_info = 'I>'
g:simplecc_sign_hint = 'H>'
g:simplecc_auto_install = 1

# simplecc 快捷键（默认已有 gd/gr/K 等，这里补充 which-key 集成）
g:which_key_map['l'] = {
  name: '+lsp',
  d: [':SimpleCCDefinition', 'definition'],
  r: [':SimpleCCReferences', 'references'],
  n: [':SimpleCCRename', 'rename'],
  a: [':SimpleCCAction', 'code-action'],
  f: [':SimpleCCFormat', 'format'],
  h: [':SimpleCCHover', 'hover'],
  s: [':SimpleCCSignatureHelp', 'signature-help'],
  e: [':SimpleCCDiagnostics', 'diagnostics-list'],
  i: [':SimpleCC', 'status'],
  R: [':SimpleCCRestart', 'restart'],
  l: [':SimpleCCLog', 'show-log'],
  c: [':SimpleCCConfig', 'open-config'],
  I: [':SimpleCCInstall', 'install-server'],
  S: [':SimpleCCServers', 'list-servers'],
  o: [':SimpleCCOutline', 'outline'],
  w: [':SimpleCCWorkspaceSymbol', 'workspace-symbol'],
  t: [':SimpleCCTypeDef', 'type-definition'],
  m: [':SimpleCCImplementation', 'implementation'],
  H: [':SimpleCCHighlight', 'highlight-symbol'],
  p: [':SimpleCCInlayHints', 'toggle-inlay-hints'],
  k: [':SimpleCCIncomingCalls', 'incoming-calls'],
  K: [':SimpleCCOutgoingCalls', 'outgoing-calls'],
  T: [':SimpleCCSemanticTokens', 'semantic-tokens'],
  L: [':SimpleCCCodeLens', 'code-lens'],
  F: [':SimpleCCFold', 'folding-range'],
}

# --- haskell
g:haskell_enable_quantification = 1
g:haskell_enable_recursivedo = 1
g:haskell_enable_arrowsyntax = 1
g:haskell_enable_pattern_synonyms = 1
g:haskell_enable_typeroles = 1
g:haskell_enable_static_pointers = 1
g:haskell_backpack = 1
