 " auto-install vim-plug
 if empty(glob('~/.vim/autoload/plug.vim'))
   silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
         \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
   "autocmd VimEnter * PlugInstall
   autocmd VimEnter * PlugInstall | source $MYVIMRC
 endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

" On-demand loading

" Intelligence
" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}
"" use coc-fzf-preview instead
"Plug 'antoinemadec/coc-fzf', {'branch': 'release'}

" Luanguage pack
Plug 'sheerun/vim-polyglot'

" Vim lsp
Plug 'prabirshrestha/vim-lsp' " vim-lsp
"" or
"Plug 'autozimu/LanguageClient-neovim' " LanguageClient-neovim
"" or
"Plug 'neovim/nvim-lsp' " nvim-lsp

" Lsp supported highlight
Plug 'jackguo380/vim-lsp-cxx-highlight'

" Comment
Plug 'preservim/nerdcommenter'
"Plug 'scrooloose/nerdcommenter'

" Tagbar
Plug 'preservim/tagbar'

if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'Shougo/denite.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
"Plug 'preservim/nerdtree'

" Fzf asynchronous search
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
" Vim script RPC
"Plug 'yuki-ycino/fzf-preview.vim', { 'branch': 'release/rpc' }
" Remote Plugins
"Plug 'yuki-ycino/fzf-preview.vim', { 'branch': 'release/remote', 'do': ':UpdateRemotePlugins' }
Plug 'junegunn/fzf.vim'

" LeaderF asynchronous search
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" Favorite grep tool asynchronous search
Plug 'mhinz/vim-grepper'

" Code search and view tool
Plug 'dyng/ctrlsf.vim'

" Easy motion
Plug 'easymotion/vim-easymotion'

"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
" light line for status line and tag line
"Plug 'itchyny/lightline.vim'
"Plug 'mengelbrecht/lightline-bufferline'
Plug 'liuchengxu/eleline.vim'
"Plug 'romgrk/barbar.nvim' " only support neovim0.5

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
Plug 'junegunn/gv.vim'
Plug 'lambdalisue/gina.vim'
Plug 'rhysd/git-messenger.vim'

Plug 'skywind3000/asyncrun.vim'
Plug 'voldikss/LeaderF-floaterm'
Plug 'voldikss/fzf-floaterm'
Plug 'voldikss/vim-floaterm'

" Fix cursor hold bound with fern
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'lambdalisue/nerdfont.vim'
"Plug 'lambdalisue/glyph-palette.vim'

" Effective working
Plug 'junegunn/goyo.vim'

" Better whitespace
Plug 'ntpeters/vim-better-whitespace'

" Choose windows
Plug 't9md/vim-choosewin'

" Emoji
Plug 'junegunn/vim-emoji'

" Even better % nv&hl matching words
Plug 'andymass/vim-matchup'

" do not use vim-mundo
"" Undo from history
"Plug 'simnalamburt/vim-mundo'

" More powerful repeat
Plug 'tpope/vim-repeat'

" Beautiful startify
Plug 'mhinz/vim-startify'

" Quoting/parenthesizing made simple
Plug 'tpope/vim-surround'

" Auto pairs
Plug 'jiangmiao/auto-pairs'

" Indent line
Plug 'Yggdroot/indentLine'

" Any jump
Plug 'pechorin/any-jump.vim'

" Vim which key
Plug 'liuchengxu/vim-which-key'
"" On-demand lazy load
"Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }

" Vista
Plug 'liuchengxu/vista.vim'

" Rainbow brackets
Plug 'luochen1990/rainbow'
"Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
"Plug 'dominikduda/vim_current_word'

"Plug 'RRethy/vim-illuminate'

" Vim rooter
Plug 'airblade/vim-rooter'

" Vim multiple cursors
Plug 'terryma/vim-multiple-cursors'

" Find and replace
Plug 'brooth/far.vim'

" gutentags is buggy
 ""Vim gutentags
"Plug 'ludovicchabant/vim-gutentags'

" Interactive scratchpad for hackers
Plug 'metakirby5/codi.vim'

"" Quick scope
"Plug 'unblevable/quick-scope'


" 主题插件
" collections, ascending by star, use single package every time
"Plug 'flazz/vim-colorschemes'
Plug 'rafi/awesome-vim-colorschemes'
"Plug 'chriskempson/base16-vim'
"Plug 'rainglow/vim'

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
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'tomasiser/vim-code-dark'
Plug 'mg979/vim-studio-dark'

Plug 'rhysd/vim-clang-format'
Plug 'sbdchd/neoformat'
Plug 'prettier/vim-prettier'

" Devicons for vim
Plug 'ryanoasis/vim-devicons'  "this Plug must be put at the last"

" Initialize plugin system
call plug#end()

"autocmd VimEnter *
  "\  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  "\|   PlugInstall --sync | q
  "\| endif
