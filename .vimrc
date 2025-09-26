" ======================================================================
" 基础设置
" ======================================================================
set nocompatible
let &t_TI = ""
let &t_TE = ""
" 设置 RGB 颜色支持
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
let g:netrw_fastbrowse = 0

" 基本编辑器设置
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
set pumheight=10 " 弹出菜单高度
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

" ======================================================================
" 自动命令
" ======================================================================
augroup vimrc_settings
  autocmd!
  " 针对不同文件类型的缩进设置
  autocmd FileType c,cpp setlocal shiftwidth=2 tabstop=2

  " 针对不同文件类型的 conceallevel 设置
  autocmd FileType json,markdown let g:indentLine_conceallevel=0
  autocmd FileType javascript,python,c,cpp,java,vim,shell let g:indentLine_conceallevel=2
augroup END

" ======================================================================
" 插件管理
" ======================================================================
" 自动安装 vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" 指定插件目录
call plug#begin('~/.vim/plugged')

" 编程增强插件
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ludovicchabant/vim-gutentags'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'kdheepak/JuliaFormatter.vim'
Plug 'neovimhaskell/haskell-vim'

" UI 增强插件
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'liuchengxu/vista.vim'
Plug 'preservim/tagbar'
Plug 'mhinz/vim-startify'

" 导航和搜索插件
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary!' }
Plug 'easymotion/vim-easymotion'
Plug 't9md/vim-choosewin'
Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-grepper'

" 编辑增强插件
Plug 'cohama/lexima.vim'
Plug 'tomtom/tcomment_vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 'andymass/vim-matchup'
Plug 'mg979/vim-visual-multi'
Plug 'jdhao/better-escape.vim'
Plug 'sheerun/vim-polyglot'

" Git 相关插件
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" 终端和工具插件
Plug 'voldikss/vim-floaterm'
Plug 'liuchengxu/vim-which-key'

" 颜色主题
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'rafi/awesome-vim-colorschemes'
Plug 'bluz71/vim-moonfly-colors'
Plug 'bluz71/vim-nightfly-guicolors'
Plug 'iandwelker/rose-pine-vim'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'dracula/vim'
Plug 'srcery-colors/srcery-vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'morhetz/gruvbox'
Plug 'luisiacc/gruvbox-baby', {'branch': 'main'}
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/everforest'
Plug 'sainnhe/edge'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
Plug 'arzg/vim-colors-xcode'
Plug 'rakr/vim-one'
Plug 'felipec/vim-felipec'

Plug 'beamiter/simpleclipboard', { 'do': './install.sh' }

call plug#end()

" ======================================================================
" 颜色主题设置
" ======================================================================
set background=dark
colorscheme nvcode

" ======================================================================
" 插件配置
" ======================================================================

" --- lexima 自动补全括号等
call lexima#init()

" --- gutentags 代码标签
let g:gutentags_enabled = 0

let g:simpletree_debug = 0
let g:simpletree_dir_guifg = '#61afef'   " 例如蓝色
let g:simpletree_dir_ctermfg = 75        " 终端蓝
nnoremap <silent> <F3> :SimpleTree<CR>
nnoremap <silent> <leader>ft :SimpleTree<CR>

" --- vim-which-key 快捷键提示
let g:mapleader = "\<Space>"
let g:maplocalleader = ','
call which_key#register('<Space>', "g:which_key_map")
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey ','<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual ','<CR>

" 定义前缀字典
let g:which_key_map =  {}
let g:which_key_map['w'] = {
      \ 'name' : '+windows' ,
      \ 'w' : ['<C-W>w'        , 'other-window'],
      \ 'd' : ['<C-W>c'        , 'delete-window'],
      \ '2' : ['<C-W>v'        , 'layout-double-columns'],
      \ 'h' : ['<C-W>h'        , 'window-left'],
      \ 'j' : ['<C-W>j'        , 'window-below'],
      \ 'l' : ['<C-W>l'        , 'window-right'],
      \ 'k' : ['<C-W>k'        , 'window-up'],
      \ 'o' : ['<C-W>o'        , 'window-only'],
      \ 'H' : ['<C-W>5<'       , 'expand-window-left'],
      \ 'J' : [':resize +5'    , 'expand-window-below'],
      \ 'L' : ['<C-W>5>'       , 'expand-window-right'],
      \ 'K' : [':resize -5'    , 'expand-window-up'],
      \ '=' : ['<C-W>='        , 'balance-window'],
      \ 's' : ['<C-W>s'        , 'split-window-below'],
      \ 'v' : ['<C-W>v'        , 'split-window-right'],
      \ }

" --- gitgutter 代码变更提示
let g:gitgutter_map_keys = 0
nmap ]g <Plug>(GitGutterNextHunk)
nmap [g <Plug>(GitGutterPrevHunk)
map <silent><leader>gj :GitGutterNextHunk<CR>
map <silent><leader>gk :GitGutterPrevHunk<CR>

" --- Vista/Tagbar 代码大纲
nmap <F4> :Vista!!<CR>

" --- 窗口调整快捷键
nmap ( :vert res -5<CR>
nmap ) :vert res +5<CR>
nmap <C-Left> :vert res -5<CR>
nmap <C-Right> :vert res +5<CR>

" --- tcomment_vim 代码注释
map <silent><leader>cl :TComment<CR>

" --- 代码格式化
xmap <silent><leader>fm <Plug>(coc-format-selected)
nmap <silent><leader>fm :call CocActionAsync('format')<CR>
xmap <silent><leader>lf <Plug>(coc-format-selected)
nmap <silent><leader>lf :call CocActionAsync('format')<CR>
xmap <silent><leader>cf <Plug>(coc-format-selected)
nmap <silent><leader>cf :call CocActionAsync('format')<CR>

" --- vim-floaterm 浮动终端
nnoremap <silent> <S-F7> :FloatermPrev<CR>
tnoremap <silent> <S-F7> <C-\><C-n>:FloatermPrev<CR>
nnoremap <silent> <F7> :FloatermNext<CR>
tnoremap <silent> <F7> <C-\><C-n>:FloatermNext<CR>
nnoremap <silent> <F8> :FloatermToggle<CR>
tnoremap <silent> <F8> <C-\><C-n>:FloatermToggle<CR>
nnoremap <silent> <S-F8> :FloatermNew<CR>
tnoremap <silent> <S-F8> <C-\><C-n>:FloatermNew<CR>

" --- coc.nvim 智能补全
" 使用 Tab 触发补全并导航
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<c-k>'

inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" 使用回车确认选中的补全项
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" 使用 <c-space> 触发补全
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" 代码导航
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" 显示文档
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" 高亮光标下的符号及其引用
autocmd CursorHold * silent call CocActionAsync('highlight')

" 重命名符号
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ln <Plug>(coc-rename)

" 代码操作
xmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>a <Plug>(coc-codeaction-selected)
nmap <leader>ac <Plug>(coc-codeaction)
nmap <leader>ca <Plug>(coc-codeaction)
nmap <leader>la <Plug>(coc-codeaction)
nmap <leader>qf <Plug>(coc-fix-current)

" 函数和类的文本对象
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" 浮动窗口滚动
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" 使用 CTRL-S 进行选择范围
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" 添加命令
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=? Fold :call CocAction('fold', <f-args>)
command! -nargs=0 OR :call CocActionAsync('runCommand', 'editor.action.organizeImport')

" 状态栏支持
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" 禁用启动警告
let g:coc_disable_startup_warning = 1

" 扩展
let g:coc_global_extensions = [
      \ 'coc-cmake',
      \ 'coc-floaterm',
      \ 'coc-highlight',
      \ 'coc-rust-analyzer',
      \ 'coc-vimlsp',
      \ 'coc-yank',
      \ 'coc-snippets',
      \ 'coc-json',
      \ 'coc-clangd',
      \ 'coc-pyright',
      \ ]

" --- vim-clap 搜索工具
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

" --- easymotion 快速移动
let g:EasyMotion_do_mapping = 0 " 禁用默认映射
nmap s <Plug>(easymotion-overwin-f2)
let g:EasyMotion_smartcase = 1
map <localleader>j <Plug>(easymotion-j)
map <localleader>k <Plug>(easymotion-k)

" --- vim-choosewin 窗口选择
nmap _ <Plug>(choosewin)

" --- 窗口快速切换
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

" --- airline 状态栏
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#bufferline#enabled = 1
let g:airline_theme='onedark'
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline_powerline_fonts = 1

" 标签页快速切换
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>0 <Plug>AirlineSelectTab0
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>= <Plug>AirlineSelectNextTab

" --- JuliaFormatter
nnoremap <localleader>jf :JuliaFormatterFormat<CR>
vnoremap <localleader>jf :JuliaFormatterFormat<CR>

" --- haskell
let g:haskell_enable_quantification = 1
let g:haskell_enable_recursivedo = 1
let g:haskell_enable_arrowsyntax = 1
let g:haskell_enable_pattern_synonyms = 1
let g:haskell_enable_typeroles = 1
let g:haskell_enable_static_pointers = 1
let g:haskell_backpack = 1

" ======================================================================
" OPAM 设置 (OCaml)
" ======================================================================
let s:opam_share_dir = system("opam config var share")
let s:opam_share_dir = substitute(s:opam_share_dir, '[\r\n]*$', '', '')

let s:opam_configuration = {}

function! OpamConfOcpIndent()
  execute "set rtp^=" . s:opam_share_dir . "/ocp-indent/vim"
endfunction
let s:opam_configuration['ocp-indent'] = function('OpamConfOcpIndent')

function! OpamConfOcpIndex()
  execute "set rtp+=" . s:opam_share_dir . "/ocp-index/vim"
endfunction
let s:opam_configuration['ocp-index'] = function('OpamConfOcpIndex')

function! OpamConfMerlin()
  let l:dir = s:opam_share_dir . "/merlin/vim"
  execute "set rtp+=" . l:dir
endfunction
let s:opam_configuration['merlin'] = function('OpamConfMerlin')

let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
let s:opam_check_cmdline = ["opam list --installed --short --safe --color=never"] + s:opam_packages
let s:opam_available_tools = split(system(join(s:opam_check_cmdline)))
for tool in s:opam_packages
  " Respect package order (merlin should be after ocp-index)
  if count(s:opam_available_tools, tool) > 0
    call s:opam_configuration[tool]()
  endif
endfor

" ocp-indent
if count(s:opam_available_tools,"ocp-indent") == 0
  source "/home/mm/.opam/default/share/ocp-indent/vim/indent/ocaml.vim"
endif
