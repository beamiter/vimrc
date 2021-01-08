syntax on
syntax enable

set foldmethod=manual
set termguicolors
set hlsearch
set backspace=2
set number
set relativenumber
set tabstop=2
set switchbuf="useopen"
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent
set expandtab
set nowrap                              " Display long lines as just one line
set mouse=a                             " Enable your mouse
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
set cursorline                          " Enable highlighting of the current line
set nocursorline                        " Enable highlighting of the current line
set noshowmode                          " We don't need to see things like -- INSERT -- anymore
set clipboard=unnamedplus               " Copy paste between vim and everything else
set background=dark " must put it befor syntax to work
set pastetoggle=<F9>
" 设置为双字宽显示，否则无法完整显示如:☆
set ambiwidth=double
" 总是显示状态栏
set laststatus=2
set showtabline=2
"set undofile
"set undodir=~/.vim/undo
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
" By default timeoutlen is 1000 ms
set timeoutlen=1000
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
