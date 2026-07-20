vim9script

var C = g:vimrc_context

# ============================================================================
# 核心选项
# ============================================================================
set nocompatible
set encoding=utf-8
set nolangremap
set ambiwidth=double

set autoindent
set smartindent
set smarttab
set shiftround
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set backspace=indent,eol,start

set hidden
set autoread
set confirm
set noautochdir
set fixendofline
set fileformats=unix,dos,mac

set number
set relativenumber
set signcolumn=yes
set cursorline
set scrolloff=5
set sidescrolloff=5
set wrap
set display=lastline
set laststatus=2
set showtabline=2
set showmode
set cmdheight=1
set pumheight=12
set pumwidth=20
set ruler
set mouse=a

set ignorecase
set smartcase
set incsearch
set hlsearch
set infercase
set magic
set showmatch

set wildmenu
set wildmode=longest:full,full
set wildoptions=pum,fuzzy
set wildignore+=*/.git/*,*/node_modules/*,*/target/*,*/dist/*,*/build/*
set wildignore+=*.o,*.obj,*.pyc,*.class,*.cache
set completeopt=menuone,noselect,popup
set complete-=i

set splitbelow
set splitright
set splitkeep=screen
set switchbuf=useopen,usetab,newtab
set jumpoptions=stack

set timeout
set timeoutlen=450
set ttimeout
set ttimeoutlen=50
set updatetime=300
set redrawtime=1500
set synmaxcol=500
set history=2000
set belloff=all
set smoothscroll

set sessionoptions=buffers,curdir,folds,help,localoptions,tabpages,winsize,winpos
set viewoptions=cursor,folds,slash,unix
set diffopt+=algorithm:histogram,indent-heuristic
set nrformats-=octal
set shortmess+=Ic
set listchars=tab:>-,trail:~,extends:>,precedes:<,nbsp:+

if exists('+termguicolors')
  set termguicolors
endif

if has('unnamedplus')
  set clipboard^=unnamedplus
endif

if has('gui_running')
  set guioptions=
  set guifont=SauceCodePro\ Nerd\ Font\ Regular\ 11.5
  set guifontwide=Sans\ Regular\ 11.5
endif

# 所有恢复数据都进入权限受控的 XDG state 目录，不污染项目目录。
for dir in [
  C.state_home,
  C.vim_state,
  C.undo_dir,
  C.swap_dir,
  C.backup_dir,
  C.session_dir,
]
  if !isdirectory(dir)
    try
      mkdir(dir, 'p', 0o700)
    catch
      echohl WarningMsg
      echomsg '[vimrc] 无法创建状态目录: ' .. dir
      echohl None
    endtry
  endif
endfor

# Fail closed when the state root is unavailable: never fall back to creating
# swap or backup files beside source files.
set noundofile
set noswapfile
set nobackup
set nowritebackup
if isdirectory(C.undo_dir) && filewritable(C.undo_dir) == 2
  &undodir = C.undo_dir .. '//'
  set undofile
endif
if isdirectory(C.swap_dir) && filewritable(C.swap_dir) == 2
  &directory = C.swap_dir .. '//'
  set swapfile
endif
if isdirectory(C.backup_dir) && filewritable(C.backup_dir) == 2
  &backupdir = C.backup_dir .. '//'
  set writebackup
endif

# Respect an explicit `vim -i NONE` or another user path, while allowing this
# module's own fail-closed NONE to recover on a later source.
var viminfo_was_managed = get(g:, 'vimrc_viminfo_is_managed', 0) == 1
var viminfo_was_overridden = viminfo_was_managed
      \ ? &viminfofile !=# get(g:, 'vimrc_managed_viminfofile', '')
      \ : !empty(&viminfofile)
if !viminfo_was_overridden
  var viminfo_path = C.vim_state .. '/viminfo'
  if isdirectory(C.vim_state)
        \ && filewritable(C.vim_state) == 2
        \ && (getftype(viminfo_path) ==# '' || filewritable(viminfo_path) == 1)
    &viminfofile = viminfo_path
  else
    &viminfofile = 'NONE'
  endif
  g:vimrc_managed_viminfofile = &viminfofile
  g:vimrc_viminfo_is_managed = 1
else
  g:vimrc_viminfo_is_managed = 0
endif

if executable('rg')
  &grepprg = 'rg --vimgrep --smart-case --hidden --glob '
        .. shellescape('!.git/*')
  &grepformat = '%f:%l:%c:%m'
endif
