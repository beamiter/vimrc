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
simpleplug#Plug('neoclide/coc.nvim', {branch: 'release'})
simpleplug#Plug('ludovicchabant/vim-gutentags')
simpleplug#Plug('JuliaEditorSupport/julia-vim')
simpleplug#Plug('kdheepak/JuliaFormatter.vim')
simpleplug#Plug('neovimhaskell/haskell-vim')

# UI 增强插件
simpleplug#Plug('ryanoasis/vim-devicons')
simpleplug#Plug('vim-airline/vim-airline')
simpleplug#Plug('vim-airline/vim-airline-themes')
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

# --- 代码格式化
xmap <silent><leader>fm <Plug>(coc-format-selected)
nmap <silent><leader>fm :call CocActionAsync('format')<CR>
xmap <silent><leader>lf <Plug>(coc-format-selected)
nmap <silent><leader>lf :call CocActionAsync('format')<CR>
xmap <silent><leader>cf <Plug>(coc-format-selected)
nmap <silent><leader>cf :call CocActionAsync('format')<CR>

# --- vim-floaterm 浮动终端
nnoremap <silent> <S-F7> :FloatermPrev<CR>
tnoremap <silent> <S-F7> <C-\><C-n>:FloatermPrev<CR>
nnoremap <silent> <F7> :FloatermNext<CR>
tnoremap <silent> <F7> <C-\><C-n>:FloatermNext<CR>
nnoremap <silent> <F8> :FloatermToggle<CR>
tnoremap <silent> <F8> <C-\><C-n>:FloatermToggle<CR>
nnoremap <silent> <S-F8> :FloatermNew<CR>
tnoremap <silent> <S-F8> <C-\><C-n>:FloatermNew<CR>

# ======================================================================
# coc.nvim 配置 - 使用传统 function! 定义 (仅在 coc 加载后生效)
# ======================================================================
if get(g:, 'did_coc_loaded', 0)

# 使用 Tab 触发补全并导航
function! g:CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ g:CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

g:coc_snippet_next = '<tab>'
g:coc_snippet_prev = '<c-k>'

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

# 使用回车确认选中的补全项
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

# 使用 <c-space> 触发补全
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

# 代码导航
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

# 显示文档
function! g:ShowDocumentation() abort
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

nnoremap <silent> K :call g:ShowDocumentation()<CR>

# 高亮光标下的符号及其引用
autocmd CursorHold * silent call CocActionAsync('highlight')

# 重命名符号
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ln <Plug>(coc-rename)

# 代码操作
xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>ac <Plug>(coc-codeaction)
nmap <leader>ca <Plug>(coc-codeaction)
nmap <leader>la <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)

# 函数和类的文本对象
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

# 使用 CTRL-S 进行选择范围
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

# 添加命令
command! -nargs=0 Format call CocActionAsync('format')
command! -nargs=? Fold call CocAction('fold', <f-args>)
command! -nargs=0 OR call CocActionAsync('runCommand', 'editor.action.organizeImport')

# 状态栏支持
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

endif  # coc.nvim guard

# 禁用启动警告 (这些 g: 变量设在 guard 外面，coc 加载时会读取)
g:coc_disable_startup_warning = 1

# 扩展
g:coc_global_extensions = [
  'coc-rust-analyzer',
  'coc-yank',
  'coc-snippets',
  'coc-json',
  'coc-clangd',
  'coc-pyright',
]

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

# --- airline 状态栏
g:airline_theme = 'onedark'
g:airline_powerline_fonts = 1

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

# --- haskell
g:haskell_enable_quantification = 1
g:haskell_enable_recursivedo = 1
g:haskell_enable_arrowsyntax = 1
g:haskell_enable_pattern_synonyms = 1
g:haskell_enable_typeroles = 1
g:haskell_enable_static_pointers = 1
g:haskell_backpack = 1
