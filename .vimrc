set nocompatible
let &t_TI = ""
let &t_TE = ""
" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

"imap jk <ESC>

filetype off
syntax on

set autoindent
set backspace=indent,eol,start
set clipboard+=unnamedplus
set colorcolumn=120
set encoding=utf-8
set expandtab
set guioptions=
set guifont=SauceCodePro\ Nerd\ Font\ Regular\ 11.5
set guifontwide=Sans\ Regular\ 11.5
set nobackup
set noswapfile
set nowritebackup
set number
set relativenumber
set shiftwidth=4
set shortmess+=c
set showtabline=2
set laststatus=2
set tabstop=4
set pumheight=10 " popup menu height
set termguicolors
set noautochdir
set scrolloff=3
set sidescrolloff=3
set timeoutlen=500
set wildmenu

autocmd FileType c,cpp setlocal shiftwidth=2
autocmd FileType c,cpp setlocal tabstop=2

autocmd FileType json,markdown let g:indentLine_conceallevel=0
autocmd FileType javascript,python,c,cpp,java,vim,shell let g:indentLine_conceallevel=2

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" According to plug name alphabetical order
Plug 'neoclide/coc.nvim', {'branch': 'release'}
if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
"Plug 'prabirshrestha/vim-lsp'
"Plug 'mattn/vim-lsp-settings'

Plug 'dyng/ctrlsf.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'liuchengxu/vim-clap', { 'do': ':Clap install-binary' }
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'morhetz/gruvbox'
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/everforest'
Plug 'sainnhe/edge'
Plug 'sainnhe/sonokai'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
Plug 'srcery-colors/srcery-vim'
Plug 'neovimhaskell/haskell-vim'
Plug 'Yggdroot/indentLine'
Plug 'kdheepak/JuliaFormatter.vim'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'cohama/lexima.vim'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'sbdchd/neoformat'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'lambdalisue/fern.vim'
Plug 'dracula/vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 't9md/vim-choosewin'
Plug 'arzg/vim-colors-xcode'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'
Plug 'felipec/vim-felipec'
Plug 'voldikss/vim-floaterm'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-grepper'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'andymass/vim-matchup'
Plug 'bluz71/vim-moonfly-colors'
Plug 'bluz71/vim-nightfly-guicolors'
Plug 'rakr/vim-one'
Plug 'sheerun/vim-polyglot'
"Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-startify'
Plug 'sheerun/vim-polyglot'
Plug 'mg979/vim-visual-multi'
Plug 'liuchengxu/vim-which-key'

call plug#end()

"""""""""""""""" sonokai themes
let g:sonokai_style = 'andromeda'
let g:sonokai_better_performance = 1
let g:edge_style = 'aura'
let g:edge_better_performance = 1
let g:everforest_background = 'soft'
let g:everforest_better_performance = 1
let g:gruvbox_material_background = 'soft'
let g:gruvbox_material_better_performance = 1

"set background=light
set background=dark
"colorscheme xcodelight
"colorscheme gruvbox-material
"colorscheme felipec
"colorscheme dracula
"colorscheme srcery
"colorscheme nvcode
"colorscheme edge
colorscheme lunar

" insert this line above imap
call lexima#init()

"""""""""""""""" vim-rooter
"let g:rooter_manual_only = 1

"""""""""""""""" vim-visual-multi
"let g:VM_maps = {}
"let g:VM_maps['Find Under']         = '<C-s>'           " replace C-n
"let g:VM_maps['Find Subword Under'] = '<C-s>'           " replace visual C-n

"""""""""""""""" nerdtree
" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
" Close the tab if NERDTree is the only window remaining in it.
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
function MyNerdToggle()
    if &filetype == 'nerdtree' || exists("g:NERDTree") && g:NERDTree.IsOpen()
        :NERDTreeToggle
    else
        :NERDTreeFind
    endif
endfunction


"""""""""""""""" which-key
let g:mapleader = "\<Space>"
let g:maplocalleader = ','
call which_key#register('<Space>', "g:which_key_map")
"call which_key#register(',', "g:which_key_map")
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey ','<CR>
vnoremap <silent> <localleader> :<c-u>WhichKeyVisual ','<CR>
" leaderf
let g:Lf_ShortcutF = ''
let g:Lf_ShortcutB = ''
let g:Lf_WindowHeight = 0.3

" Define prefix dictionary
let g:which_key_map =  {}
let g:which_key_map['c'] = {
     \ 'name' : 'Clap' ,
     \ 'c' : [':Clap'          , 'clap'],
     \ }
let g:which_key_map['s'] = {
     \ 'name' : 'leaderf' ,
     \ 'b' : [':LeaderfBuffer'                           , 'buffer'],
     \ 'f' : [':LeaderfFile'                             , 'file'],
     \ 'h' : [':LeaderfMru'                              , 'mru'],
     \ 's' : [':LeaderfSelf'                             , 'self'],
     \ 'w' : ['<Plug>LeaderfRgCwordLiteralBoundary'      , 'rg'],
     \ }
let g:which_key_map['w'] = {
      \ 'name' : '+windows' ,
      \ 'w' : ['<C-W>w'        , 'other-window']          ,
      \ 'd' : ['<C-W>c'        , 'delete-window']         ,
      \ '2' : ['<C-W>v'        , 'layout-double-columns'] ,
      \ 'h' : ['<C-W>h'        , 'window-left']           ,
      \ 'j' : ['<C-W>j'        , 'window-below']          ,
      \ 'l' : ['<C-W>l'        , 'window-right']          ,
      \ 'k' : ['<C-W>k'        , 'window-up']             ,
      \ 'o' : ['<C-W>o'        , 'window-only']             ,
      \ 'H' : ['<C-W>5<'       , 'expand-window-left']    ,
      \ 'J' : [':resize +5'    , 'expand-window-below']   ,
      \ 'L' : ['<C-W>5>'       , 'expand-window-right']   ,
      \ 'K' : [':resize -5'    , 'expand-window-up']      ,
      \ '=' : ['<C-W>='        , 'balance-window']        ,
      \ 's' : ['<C-W>s'        , 'split-window-below']    ,
      \ 'v' : ['<C-W>v'        , 'split-window-right']    ,
      \ }

"""""""""""""""" gitgutter
nmap [g <Plug>(GitGutterPrevHunk)
nmap ]g <Plug>(GitGutterNextHunk)

"""""""""""""""""" nerdcommenter
let g:NERDCreateDefaultMappings = 0
map <silent><leader>cl <plug>NERDCommenterToggle
xmap <silent><leader>fm <Plug>(coc-format-selected)
nmap <silent><leader>fm :call CocActionAsync('format')<CR>

"""""""""""""""" vim-floaterm
nnoremap   <silent>   <F5>    :FloatermNew<CR>
tnoremap   <silent>   <F5>    <C-\><C-n>:FloatermNew<CR>
nnoremap   <silent>   <F6>    :FloatermPrev<CR>
tnoremap   <silent>   <F6>    <C-\><C-n>:FloatermPrev<CR>
nnoremap   <silent>   <F7>    :FloatermNext<CR>
tnoremap   <silent>   <F7>    <C-\><C-n>:FloatermNext<CR>
nnoremap   <silent>   <F8>   :FloatermToggle<CR>
tnoremap   <silent>   <F8>   <C-\><C-n>:FloatermToggle<CR>

"""""""""""""""" coc
source $HOME/vimrc/coc.vim

"""""""""""""""" defx
if 0 && has("python3") || has("python")
  " direction = topleft or botright
  nmap <silent> <F3> :Defx `escape(expand('%:p:h'), ' :')` -search=`expand('%:p')` <CR>
  "nmap <silent> <F3> :Defx -split=vertical -winwidth=40 -direction=topleft <CR>
  "nmap <silent> <F3> :Defx `expand('%:p:h')` -search=`expand('%:p')` -columns=mark:indent:icon:filename:type:size:time <CR>
  call defx#custom#option('_', {
        \ 'winwidth': 40,
        \ 'split': 'vertical',
        \ 'direction': 'botright',
        \ 'show_ignored_files': 0,
        \ 'buffer_name': '',
        \ 'toggle': 1,
        \ 'resume': 1
        \ })
  autocmd FileType defx call s:defx_my_settings()
  function! s:defx_my_settings() abort
    " Define mappings
    nnoremap <silent><buffer><expr> <CR>
    \ defx#do_action('open')
    nnoremap <silent><buffer><expr> c
    \ defx#do_action('copy')
    nnoremap <silent><buffer><expr> m
    \ defx#do_action('move')
    nnoremap <silent><buffer><expr> p
    \ defx#do_action('paste')
    nnoremap <silent><buffer><expr> l
    \ defx#do_action('drop')
    nnoremap <silent><buffer><expr> e
    \ defx#do_action('open', 'vsplit')
    nnoremap <silent><buffer><expr> E
    \ defx#do_action('open', 'split')
    nnoremap <silent><buffer><expr> P
    \ defx#do_action('preview')
    nnoremap <silent><buffer><expr> o
    \ defx#do_action('open_tree', 'toggle')
    nnoremap <silent><buffer><expr> K
    \ defx#do_action('new_directory')
    nnoremap <silent><buffer><expr> N
    \ defx#do_action('new_file')
    nnoremap <silent><buffer><expr> M
    \ defx#do_action('new_multiple_files')
    nnoremap <silent><buffer><expr> C
    \ defx#do_action('toggle_columns',
    \                'mark:indent:icon:filename:type:size:time')
    nnoremap <silent><buffer><expr> S
    \ defx#do_action('toggle_sort', 'time')
    nnoremap <silent><buffer><expr> d
    \ defx#do_action('remove')
    nnoremap <silent><buffer><expr> r
    \ defx#do_action('rename')
    nnoremap <silent><buffer><expr> !
    \ defx#do_action('execute_command')
    nnoremap <silent><buffer><expr> x
    \ defx#do_action('execute_system')
    nnoremap <silent><buffer><expr> yy
    \ defx#do_action('yank_path')
    nnoremap <silent><buffer><expr> .
    \ defx#do_action('toggle_ignored_files')
    nnoremap <silent><buffer><expr> ;
    \ defx#do_action('repeat')
    nnoremap <silent><buffer><expr> h
    \ defx#do_action('cd', ['..'])
    nnoremap <silent><buffer><expr> ~
    \ defx#do_action('cd')
    nnoremap <silent><buffer><expr> q
    \ defx#do_action('quit')
    nnoremap <silent><buffer><expr> <Space>
    \ defx#do_action('toggle_select') . 'j'
    nnoremap <silent><buffer><expr> *
    \ defx#do_action('toggle_select_all')
    nnoremap <silent><buffer><expr> j
    \ line('.') == line('$') ? 'gg' : 'j'
    nnoremap <silent><buffer><expr> k
    \ line('.') == 1 ? 'G' : 'k'
    nnoremap <silent><buffer><expr> <C-l>
    \ defx#do_action('redraw')
    nnoremap <silent><buffer><expr> <C-g>
    \ defx#do_action('print')
    nnoremap <silent><buffer><expr> cd
    \ defx#do_action('change_vim_cwd')
  	nnoremap <silent><buffer><expr> > defx#do_action('resize',
  	\ defx#get_context().winwidth + 10)
  	nnoremap <silent><buffer><expr> < defx#do_action('resize',
  	\ defx#get_context().winwidth - 10)
    autocmd BufWritePost * call defx#redraw()
  endfunction
else
  "nnoremap <F3> :call MyNerdToggle()<CR>
  "nnoremap <F3> :Fern . -reveal=%:p -drawer -toggle<CR>
  nnoremap <silent> <F3> :Fern %:h -reveal=%:p -drawer -toggle<CR>
  "nnoremap <C-n> :call MyNerdToggle()<CR>
  "nnoremap <leader>ft :call MyNerdToggle()<CR>
  "nnoremap <leader>ft :Fern . -reveal=%:p -drawer -toggle<CR>
  nnoremap <silent> <leader>ft :Fern %:h -reveal=%:p -drawer -toggle<CR>
  " Use coc-explorer as file tree
  "nnoremap <F3> :CocCommand explorer<CR>
  "map <leader>ft :CocCommand explorer<CR>
  "nnoremap <leader>ft :NERDTreeFind<CR>
endif

"""""""""""""""""" fzf-vim
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
command! ProjectFiles execute 'Files' s:find_git_root()
map <leader>bb :Buffers<CR>
map <leader>ff :Files<CR>
map <leader>fh :History<CR>
map <leader>pf :ProjectFiles<CR>
nnoremap <silent> <Leader>sa :Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>sr :Rg <C-R><C-W><CR>
let g:fzf_preview_window = ['right:50%:hidden', 'ctrl-/']

let g:EasyMotion_do_mapping = 0 " Disable default mappings
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)
" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1
" JK motions: Line motions
map <localleader>j <Plug>(easymotion-j)
map <localleader>k <Plug>(easymotion-k)

"""""""""""""""""" neoformat
map <leader>bf :Neoformat<CR>

"""""""""""""""""" vim-choosewin
" invoke with '-'
nmap  -  <Plug>(choosewin)

"""""""""""""""""" wincmd
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

"""""""""""""""" lightline
let g:lightline = {
      \ 'colorscheme': 'darcula',
      \ 'active': {
      \  'left': [ [ 'winnr', 'mode', 'paste' ],
      \            [ 'gitbranch', 'gitstatus', 'readonly',
      \              'filename', 'modified', 'cocstatus' ] ],
      \  'right': [ [ 'lineinfo' ],
      \             [ 'percent' ],
      \             [ 'fileformat', 'fileencoding', 'filetype' ] ] },
      \ 'inactive': {
      \  'left': [ [ 'winnr', 'filename' ] ],
      \  'right': [ [ 'lineinfo' ],
      \             [ 'percent' ] ] },
      \ 'tabline': {
      \  'left': [ ['buffers'] ],
      \  'right': [ [ 'close' ] ] },
      \ 'component_function': {
      \ 'cocstatus': 'coc#status',
      \  'gitbranch': 'FugitiveStatusline',
      \ },
      \ 'component_expand': {
      \ 'buffers': 'lightline#bufferline#buffers'
      \ },
      \ 'component_type': {
      \ 'buffers': 'tabsel',
      \ },
      \ }
let g:lightline#bufferline#show_number = 2
let g:lightline#bufferline#enable_nerdfont = 1
nmap <leader>1 <Plug>lightline#bufferline#go(1)
nmap <leader>2 <Plug>lightline#bufferline#go(2)
nmap <leader>3 <Plug>lightline#bufferline#go(3)
nmap <leader>4 <Plug>lightline#bufferline#go(4)
nmap <leader>5 <Plug>lightline#bufferline#go(5)
nmap <leader>6 <Plug>lightline#bufferline#go(6)
nmap <leader>7 <Plug>lightline#bufferline#go(7)
nmap <leader>8 <Plug>lightline#bufferline#go(8)
nmap <leader>9 <Plug>lightline#bufferline#go(9)
nmap <leader>0 <Plug>lightline#bufferline#go(10)

"""""""""""""""""" JuliaFormatter
map <leader>bb :Buffers<CR>
" normal mode mapping
nnoremap <localleader>jf :JuliaFormatterFormat<CR>
" visual mode mapping
vnoremap <localleader>jf :JuliaFormatterFormat<CR>

"""""""""""""""""" haskell
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
