set nocompatible
" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

" On-demand loading

" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'antoinemadec/coc-fzf', {'branch': 'release'}

Plug 'kana/vim-operator-user'

Plug 'preservim/nerdcommenter' "the same as above nerdcommenter"
Plug 'preservim/tagbar'
"Plug 'scrooloose/nerdcommenter'
Plug 'itchyny/vim-gitbranch'

if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'Shougo/denite.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'itchyny/lightline.vim'

Plug 'tpope/vim-fugitive'
Plug 'junegunn/goyo.vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 't9md/vim-choosewin'
Plug 'junegunn/vim-emoji'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-grepper'
Plug 'andymass/vim-matchup'
Plug 'simnalamburt/vim-mundo'
Plug 'tpope/vim-repeat'
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'Yggdroot/indentLine'
Plug 'pechorin/any-jump.vim'

Plug 'mengelbrecht/lightline-bufferline'
"Plug 'kyazdani42/nvim-web-devicons'
"Plug 'romgrk/barbar.nvim' " only support neovim0.5

Plug 'kristijanhusak/defx-icons'
Plug 'liuchengxu/vim-which-key'
" On-demand lazy load
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'easymotion/vim-easymotion'

Plug 'liuchengxu/vista.vim'
Plug 'luochen1990/rainbow'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'dominikduda/vim_current_word'

" 主题插件
Plug 'rafi/awesome-vim-colorschemes'
Plug 'rainglow/vim'
Plug 'flazz/vim-colorschemes'

Plug 'tomasr/molokai'
Plug 'morhetz/gruvbox'
Plug 'altercation/vim-colors-solarized'
Plug 'rhysd/vim-color-spring-night'
Plug 'mhinz/vim-janah'
Plug 'mhartington/oceanic-next'
Plug 'hzchirs/vim-material'
Plug 'joshdick/onedark.vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'srcery-colors/srcery-vim'
Plug 'rakr/vim-one'
Plug 'arcticicestudio/nord-vim'
Plug 'itchyny/landscape.vim'
Plug 'phongnh/vim-leaderf-solarized-theme'
Plug 'connorholyday/vim-snazzy'
Plug 'nanotech/jellybeans.vim'
Plug 'jacoborus/tender.vim'
Plug 'sjl/badwolf'
Plug 'romgrk/doom-one.vim'
Plug 'ajmwagar/vim-deus'

Plug 'rhysd/vim-clang-format'
Plug 'sbdchd/neoformat'
Plug 'prettier/vim-prettier'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'ctrlpvim/ctrlp.vim'

Plug 'ryanoasis/vim-devicons'  "this Plug must be put at the last"

" Initialize plugin system
call plug#end()
let g:mapleader = "\<Space>"
let g:maplocalleader = ','

let &t_TI = ""
let &t_TE = ""

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

set foldmethod=manual
set termguicolors
set hlsearch
set backspace=2
set number
set relativenumber
set tabstop=2
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent
set expandtab
set background=dark " must put it befor syntax to work
"colorscheme space-vim-dark
colorscheme ayu
syntax on
syntax enable
set pastetoggle=<F9>
" 设置为双字宽显示，否则无法完整显示如:☆
set ambiwidth=double
" 总是显示状态栏
set laststatus=2
set showtabline=2
" By default timeoutlen is 1000 ms
"set timeoutlen=500
set undofile
set undodir=~/.vim/undo
set encoding=utf-8
" TextEdit might fail if hidden is not set.
set hidden
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" Give more space for displaying messages.
set cmdheight=2
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=750
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

highlight! link CursorColumn TagbarHighlight

let g:EasyMotion_do_mapping = 0 " Disable default mappings
let g:vista_default_executive = 'coc'
let g:vista_sidebar_width = 45
let g:vista_curser_delay = 100
let g:vista_echo_cursor_stragegy = 'both'
let g:vista_finder_alternative_executives = ['ctags', 'vim_lsp', 'nvim_lsp']
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

" coc configuration
let g:coc_global_extensions = [
            \ 'coc-bookmark',
            \ 'coc-cmake',
            \ 'coc-explorer',
            \ 'coc-git',
            \ 'coc-json',
            \ 'coc-marketplace',
            \ 'coc-pairs',
            \ 'coc-stylelint',
            \ 'coc-todolist',
            \ 'coc-translator',
            \ 'coc-tsserver',
            \ 'coc-vimlsp',
            \ 'coc-yaml',
            \ 'coc-lists',
            \ 'coc-clangd',
            \ 'coc-highlight',
            \ 'coc-yank',
            \ 'coc-snippets',
            \  ]

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

" Show line numbers in search rusults
let g:any_jump_list_numbers = 0

" Auto search references
let g:any_jump_references_enabled = 1

" Auto group results by filename
let g:any_jump_grouping_enabled = 0

" Amount of preview lines for each search result
let g:any_jump_preview_lines_count = 5

" Max search results, other results can be opened via [a]
let g:any_jump_max_search_results = 7

" Prefered search engine: rg or ag
let g:any_jump_search_prefered_engine = 'rg'

" Default search results list styles:
" - 'filename_first'
" - 'filename_last'
let g:any_jump_results_ui_style = 'filename_first'

" Any-jump window size & position options
let g:any_jump_window_width_ratio  = 0.5
let g:any_jump_window_height_ratio = 0.4
let g:any_jump_window_top_offset   = 15

" Customize any-jump colors with extending default color scheme:
let g:any_jump_colors = { "help": "Function" }

" Or override all default colors
let g:any_jump_colors = {
      \"plain_text":         "Comment",
      \"preview":            "Comment",
      \"preview_keyword":    "Operator",
      \"heading_text":       "Function",
      \"heading_keyword":    "Identifier",
      \"group_text":         "Comment",
      \"group_name":         "Function",
      \"more_button":        "Operator",
      \"more_explain":       "Comment",
      \"result_line_number": "Comment",
      \"result_text":        "Statement",
      \"result_path":        "String",
      \"help":               "Comment"
      \}

" Custom ignore files
" default is: ['*.tmp', '*.temp']
let g:any_jump_ignored_files = ['*.tmp', '*.temp']

" Search references only for current file type
" (default: false, so will find keyword in all filetypes)
let g:any_jump_references_only_for_current_filetype = 0

" Disable search engine ignore vcs untracked files (default: false, search engine will ignore vcs untracked files)
let g:any_jump_disable_vcs_ignore = 0

let g:webdevicons_enable = 1
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_airline_statusline = 1
let g:webdevicons_enable_ctrlp = 1
let g:webdevicons_enable_startify = 1
let g:webdevicons_enable_flagship_statusline = 1
let g:WebDevIconsUnicodeDecorateFileNodes = 1
let g:WebDevIconsUnicodeGlyphDoubleWidth = 1
let g:WebDevIconsNerdTreeAfterGlyphPadding = '  '
let g:WebDevIconsNerdTreeGitPluginForceVAlign = 1
let g:webdevicons_enable_denite = 1
let g:WebDevIconsTabAirLineAfterGlyphPadding = ' '
let g:WebDevIconsTabAirLineBeforeGlyphPadding = ' '
"let g:WebDevIconsUnicodeDecorateFileNodesDefaultSymbol = 'ƛ'
"let g:WebDevIconsUnicodeByteOrderMarkerDefaultSymbol = ''
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1
let g:DevIconsEnableFolderPatternMatching = 1
let g:DevIconsEnableFolderExtensionPatternMatching = 0
let WebDevIconsUnicodeDecorateFolderNodesExactMatches = 1
"let g:WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol = 'ƛ'
"let g:DevIconsDefaultFolderOpenSymbol = 'ƛ'
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {} " needed
"let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['js'] = 'ƛ'
let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols = {} " needed
"let g:WebDevIconsUnicodeDecorateFileNodesExactSymbols['MyReallyCoolFile.okay'] = 'ƛ'
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {} " needed
"let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['myext'] = 'ƛ'
let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols = {} " needed
"let g:WebDevIconsUnicodeDecorateFileNodesPatternSymbols['.*jquery.*\.js$'] = 'ƛ'
let g:WebDevIconsOS = 'Darwin'


nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>

" returns all modified files of the current git repo
" `2>/dev/null` makes the command fail quietly, so that when we are not
" in a git repo, the list will be empty
function! s:gitModified()
    let files = systemlist('git ls-files -m 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
endfunction

" same as above, but show untracked files, honouring .gitignore
function! s:gitUntracked()
    let files = systemlist('git ls-files -o --exclude-standard 2>/dev/null')
    return map(files, "{'line': v:val, 'path': v:val}")
endfunction

let g:startify_lists = [
        \ { 'type': 'files',     'header': ['   MRU']            },
        \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
        \ { 'type': 'sessions',  'header': ['   Sessions']       },
        \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
        \ { 'type': function('s:gitModified'),  'header': ['   git modified']},
        "\ { 'type': function('s:gitUntracked'), 'header': ['   git untracked']},
        \ { 'type': 'commands',  'header': ['   Commands']       },
        \ ]

nnoremap <localleader>f :Files <CR>
nnoremap <localleader>b :Buffers <CR>

nnoremap <leader>mv :mkview <CR>
nnoremap <leader>lv :loadview <CR>

nmap <silent> <F2> :CocCommand explorer<CR>
"nmap <silent> <F3> :Defx -columns=indent:mark:icons:filename:type <CR>
nmap <silent> <F3> :Defx `expand('%:p:h')` -search=`expand('%:p')` -columns=indent:mark:icons:filename:type <CR>
call defx#custom#option('_', {
      \ 'winwidth': 50,
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

let g:defx_icons_enable_syntax_highlight = 1
let g:defx_icons_column_length = 1
let g:defx_icons_directory_icon = ''
let g:defx_icons_mark_icon = '*'
let g:defx_icons_copy_icon = ''
let g:defx_icons_move_icon = ''
let g:defx_icons_parent_icon = ''
let g:defx_icons_default_icon = ''
let g:defx_icons_directory_symlink_icon = ''
" Options below are applicable only when using "tree" feature
let g:defx_icons_root_opened_tree_icon = ''
let g:defx_icons_nested_opened_tree_icon = ''
let g:defx_icons_nested_closed_tree_icon = ''

let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste', 'scroll' ], [ 'gitbranch', 'gitstatus', 'readonly',
      \               'filename', 'modified' ] ],
      \ },
      \ 'tabline': {
      \   'left': [ ['buffers'] ],
      \   'right': [ ['close'] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveStatusline',
      \   'gitstatus': 'GitStatus',
      \   'readonly': 'LightlineReadonly',
      \   'modified': 'LightlineModified',
      \   'tabnum': 'lightline#tab#tabnum',
      "\   'scroll': 'ScrollStatus',
	    \   'cocstatus': 'coc#status',
      \ },
      \ 'component_expand': {
      \   'buffers': 'lightline#bufferline#buffers',
      \ },
      \ 'component_type': {
      \   'buffers': 'tabsel'
      \ }
      \ }
autocmd User CocStatusChange,CocDiagnosticChange call lightline#update()

let g:scrollstatus_size = 10
let g:scrollstatus_symbol_track = '-'
let g:scrollstatus_symbol_bar = '|'

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction
function! LightlineReadonly()
	return &readonly ? 'RO' : 'RW'
endfunction
function! LightlineModified()
	return &modifiable && &modified ? '+' : ''
endfunction

let g:lightline#bufferline#show_number = 2
"let g:lightline#bufferline#composed_number_map = {
"\ 1:  '⑴ ', 2:  '⑵ ', 3:  '⑶ ', 4:  '⑷ ', 5:  '⑸ ',
"\ 6:  '⑹ ', 7:  '⑺ ', 8:  '⑻ ', 9:  '⑼ ', 10: '⑽ ',
"\ 11: '⑾ ', 12: '⑿ ', 13: '⒀ ', 14: '⒁ ', 15: '⒂ ',
"\ 16: '⒃ ', 17: '⒄ ', 18: '⒅ ', 19: '⒆ ', 20: '⒇ '}
let g:lightline#bufferline#composed_number_map = {
\ 1:  '1 ', 2:  '2 ', 3:  '3 ', 4:  '4 ', 5:  '5 ',
\ 6:  '6 ', 7:  '7 ', 8:  '8 ', 9:  '9 ', 10: '10 ',
\ 11: '11 ', 12: '12 ', 13: '13 ', 14: '14 ', 15: '15 ',
\ 16: '16 ', 17: '17 ', 18: '18 ', 19: '19 ', 20: '20 '}
let g:lightline#bufferline#number_map = {
\ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
\ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}
"let g:lightline#bufferline#enable_devicons = 1
"let g:lightline#bufferline#enable_nerdfont = 1

nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)
nmap <Leader>c1 <Plug>lightline#bufferline#delete(1)
nmap <Leader>c2 <Plug>lightline#bufferline#delete(2)
nmap <Leader>c3 <Plug>lightline#bufferline#delete(3)
nmap <Leader>c4 <Plug>lightline#bufferline#delete(4)
nmap <Leader>c5 <Plug>lightline#bufferline#delete(5)
nmap <Leader>c6 <Plug>lightline#bufferline#delete(6)
nmap <Leader>c7 <Plug>lightline#bufferline#delete(7)
nmap <Leader>c8 <Plug>lightline#bufferline#delete(8)
nmap <Leader>c9 <Plug>lightline#bufferline#delete(9)
nmap <Leader>c0 <Plug>lightline#bufferline#delete(10)

"" Magic buffer-picking mode
"nnoremap <silent> <C-s> :BufferPick<CR>
"" Sort automatically by...
"nnoremap <silent> <Space>bd :BufferOrderByDirectory<CR>
"nnoremap <silent> <Space>bl :BufferOrderByLanguage<CR>
"" Move to previous/next
"nnoremap <silent>    <A-,> :BufferPrevious<CR>
"nnoremap <silent>    <A-.> :BufferNext<CR>
"" Re-order to previous/next
"nnoremap <silent>    <A-<> :BufferMovePrevious<CR>
"nnoremap <silent>    <A->> :BufferMoveNext<CR>
"" Goto buffer in position...
"nnoremap <silent>    <A-1> :BufferGoto 1<CR>
"nnoremap <silent>    <A-2> :BufferGoto 2<CR>
"nnoremap <silent>    <A-3> :BufferGoto 3<CR>
"nnoremap <silent>    <A-4> :BufferGoto 4<CR>
"nnoremap <silent>    <A-5> :BufferGoto 5<CR>
"nnoremap <silent>    <A-6> :BufferGoto 6<CR>
"nnoremap <silent>    <A-7> :BufferGoto 7<CR>
"nnoremap <silent>    <A-8> :BufferGoto 8<CR>
"nnoremap <silent>    <A-9> :BufferLast<CR>
"" Close buffer
"nnoremap <silent>    <A-c> :BufferClose<CR>
"" Wipeout buffer
""                          :BufferWipeout<CR>
"" Close commands
""                          :BufferCloseAllButCurrent<CR>
""                          :BufferCloseBuffersRight<CR>

"" Other:
"" :BarbarEnable - enables barbar (enabled by default)
"" :BarbarDisable - very bad command, should never be used

set completefunc=emoji#complete

" invoke with '-'
nmap - <Plug>(choosewin)

nmap <F7> :Vista<CR>
nmap <F8> :TagbarToggle<CR>

let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "Standard" : "C++11"}

" map to <Leader>cf in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
" if you install vim-operator-user
autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
nmap <Leader>C :ClangFormatAutoToggle<CR>


" this if for the powerline in terminal
"POWERLINE_SCRIPT=/usr/share/powerline/bindings/bash/powerline.sh
"if [ -f $POWERLINE_SCRIPT ]; then
   "source $POWERLINE_SCRIPT
"fi


"let g:airline_powerline_fonts = 1   " 使用powerline打过补丁的字体
"let g:airline_theme="dark"      " 设置主题
"" 开启tabline
"let g:airline#extensions#tabline#enabled = 1
""tabline中当前buffer两端的分隔字符
"let g:airline#extensions#tabline#left_sep = ' '
""tabline中未激活buffer两端的分隔字符
"let g:airline#extensions#tabline#left_alt_sep = '|'
""tabline中buffer显示编号
"let g:airline#extensions#tabline#buffer_nr_show = 1
"let g:airline#extensions#tabline#formatter = 'default'
"let g:airline_theme='badwolf'  "可以自定义主题，这里使用 badwolf
"" jsformatter  unique_tail  unique_tail_improved
"" 设置字体
"set guifont=DroidSansMono\ Nerd\ Font\ 11   "must set same terminal font with this"
"" set guifont=3270\ Nerd\ Font\ 11


" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction


" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>as  <Plug>(coc-codeaction-selected)
nmap <leader>as  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " mappings
nnoremap <silent> <space><space> :<C-u>CocFzfList<CR>
nnoremap <silent> <space>a       :<C-u>CocFzfList diagnostics<CR>
nnoremap <silent> <space>d       :<C-u>CocFzfList diagnostics --current-buf<CR>
nnoremap <silent> <space>c       :<C-u>CocFzfList commands<CR>
nnoremap <silent> <space>e       :<C-u>CocFzfList extensions<CR>
nnoremap <silent> <space>l       :<C-u>CocFzfList location<CR>
nnoremap <silent> <space>o       :<C-u>CocFzfList outline<CR>
nnoremap <silent> <space>s       :<C-u>CocFzfList symbols<CR>
nnoremap <silent> <space>p       :<C-u>CocFzfListResume<CR>
