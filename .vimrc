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
set colorcolumn=80
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
set tabstop=4
set termguicolors
set noautochdir

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
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'dyng/ctrlsf.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
Plug 'sainnhe/gruvbox-material'
Plug 'neovimhaskell/haskell-vim'
Plug 'Yggdroot/indentLine'
Plug 'kdheepak/JuliaFormatter.vim'
Plug 'JuliaEditorSupport/julia-vim'
Plug 'itchyny/lightline.vim'
Plug 'sbdchd/neoformat'
Plug 'preservim/nerdcommenter'
Plug 'preservim/nerdtree'
Plug 'dracula/vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 't9md/vim-choosewin'
Plug 'arzg/vim-colors-xcode'
Plug 'easymotion/vim-easymotion'
Plug 'felipec/vim-felipec'
Plug 'voldikss/vim-floaterm'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-grepper'
Plug 'jackguo380/vim-lsp-cxx-highlight'
Plug 'andymass/vim-matchup'
Plug 'bluz71/vim-moonfly-colors'
Plug 'rakr/vim-one'
Plug 'airblade/vim-rooter'
Plug 'mhinz/vim-startify'
Plug 'liuchengxu/vim-which-key'

call plug#end()

"colorscheme xcodelight
"colorscheme gruvbox-material
"colorscheme felipec
colorscheme dracula
"set background=light
set background=dark

"""""""""""""""" vim-rooter
"let g:rooter_manual_only = 1

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
    if &filetype == 'nerdtree'
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

" Define prefix dictionary
let g:which_key_map =  {}
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

"""""""""""""""" vim-floaterm
nnoremap   <silent>   <F5>    :FloatermNew<CR>
tnoremap   <silent>   <F5>    <C-\><C-n>:FloatermNew<CR>
nnoremap   <silent>   <F6>    :FloatermPrev<CR>
tnoremap   <silent>   <F6>    <C-\><C-n>:FloatermPrev<CR>
nnoremap   <silent>   <F7>    :FloatermNext<CR>
tnoremap   <silent>   <F7>    <C-\><C-n>:FloatermNext<CR>
nnoremap   <silent>   <F8>   :FloatermToggle<CR>
tnoremap   <silent>   <F8>   <C-\><C-n>:FloatermToggle<CR>

"""""""""""""""" coc.nvim
" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
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
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

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

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
"inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
"                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
"nmap <silent> [g <Plug>(coc-diagnostic-prev)
"nmap <silent> ]g <Plug>(coc-diagnostic-next)

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
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
"xmap <leader>f  <Plug>(coc-format-selected)
"nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
"xmap <leader>a  <Plug>(coc-codeaction-selected)
"nmap <leader>a  <Plug>(coc-codeaction-selected)

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

" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
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

" Mappings for CoCList
" Show all diagnostics.
"nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
"nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
"nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
"nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
"nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
"nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
"nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
"nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" navigate chunks of current buffer
"nmap [g <Plug>(coc-git-prevchunk)
"nmap ]g <Plug>(coc-git-nextchunk)
nmap [g <Plug>(GitGutterPrevHunk)
nmap ]g <Plug>(GitGutterNextHunk)
" navigate conflicts of current buffer
"nmap [c <Plug>(coc-git-prevconflict)
"nmap ]c <Plug>(coc-git-nextconflict)

let g:coc_global_extensions = ['coc-cmake', 'coc-floaterm', 'coc-highlight',
            \'coc-julia', 'coc-rust-analyzer', 'coc-snippets', 'coc-vimlsp', 'coc-yank',
            \'coc-explorer', 'coc-pyright', 'coc-sh', 'coc-json', 'coc-clangd']

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
  "nnoremap <F3> :NERDTreeToggle<CR>
  nnoremap <F3> :call MyNerdToggle()<CR>
  "nnoremap <F3> :CocCommand explorer<CR>
endif
" Use coc-explorer as file tree
"map <leader>ft :CocCommand explorer<CR>
"nnoremap <leader>ft :NERDTreeFind<CR>
nnoremap <leader>ft :call MyNerdToggle()<CR>

"""""""""""""""""" fzf-vim
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
command! ProjectFiles execute 'Files' s:find_git_root()
map <leader>bb :Buffers<CR>
map <leader>ff :Files<CR>
map <leader>fn :FzfChooseProjectFile<CR>
map <leader>fh :History<CR>
map <leader>pf :ProjectFiles<CR>
nnoremap <silent> <Leader>sa :Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>sr :Rg <C-R><C-W><CR>

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
noremap <silent> <leader>1 :<C-u>1 wincmd w<CR>
noremap <silent> <leader>2 :<C-u>2 wincmd w<CR>
noremap <silent> <leader>3 :<C-u>3 wincmd w<CR>
noremap <silent> <leader>4 :<C-u>4 wincmd w<CR>
noremap <silent> <leader>5 :<C-u>5 wincmd w<CR>
noremap <silent> <leader>6 :<C-u>6 wincmd w<CR>
noremap <silent> <leader>7 :<C-u>7 wincmd w<CR>
noremap <silent> <leader>8 :<C-u>8 wincmd w<CR>
noremap <silent> <leader>9 :<C-u>9 wincmd w<CR>
noremap <silent> <leader>0 :<C-u>10 wincmd w<CR>

"""""""""""""""" lightline
let g:lightline = {
      \ 'colorscheme': 'darcula',
      \ 'active': {
      \  'left': [ [ 'winnr', 'mode', 'paste' ],
      \            [ 'gitbranch', 'gitstatus', 'readonly',
      \              'filename', 'modified' ] ],
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
nmap <localleader>1 <Plug>lightline#bufferline#go(1)
nmap <localleader>2 <Plug>lightline#bufferline#go(2)
nmap <localleader>3 <Plug>lightline#bufferline#go(3)
nmap <localleader>4 <Plug>lightline#bufferline#go(4)
nmap <localleader>5 <Plug>lightline#bufferline#go(5)
nmap <localleader>6 <Plug>lightline#bufferline#go(6)
nmap <localleader>7 <Plug>lightline#bufferline#go(7)
nmap <localleader>8 <Plug>lightline#bufferline#go(8)
nmap <localleader>9 <Plug>lightline#bufferline#go(9)
nmap <localleader>0 <Plug>lightline#bufferline#go(10)

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

