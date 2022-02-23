set nocompatible

imap jk <ESC>

filetype off
syntax on

set autoindent
"set clipboard+=unnamedplus
set clipboard^=unnamed,unnamedplus
set colorcolumn=80
set expandtab
set nobackup
set noswapfile
set nowritebackup
set number
set relativenumber
set shiftwidth=4
set shortmess+=c
set showtabline=2
set tabstop=4
set pumheight=10 " popup menu height
set termguicolors
set noautochdir

let g:mapleader = "\<Space>"
let g:maplocalleader = ','
set timeoutlen=500

autocmd FileType c,cpp setlocal shiftwidth=2
autocmd FileType c,cpp setlocal tabstop=2

if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')

" LSP, according to plug name alphabetical order
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'JuliaEditorSupport/julia-vim'
Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
" For vsnip users.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

Plug 'williamboman/nvim-lsp-installer'
Plug 'simrat39/rust-tools.nvim'
" OTHERS, according to plug name alphabetical order
Plug 'jiangmiao/auto-pairs'
Plug 'dyng/ctrlsf.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'neovimhaskell/haskell-vim'
Plug 'Yggdroot/indentLine'
Plug 'kdheepak/JuliaFormatter.vim'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'preservim/nerdcommenter'
Plug 'sbdchd/neoformat'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'marko-cerovac/material.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'RishabhRD/popfix'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'dracula/vim'
Plug 'ntpeters/vim-better-whitespace'
Plug 't9md/vim-choosewin'
Plug 'arzg/vim-colors-xcode'
Plug 'voldikss/vim-floaterm'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-grepper'
Plug 'andymass/vim-matchup'
Plug 'bluz71/vim-moonfly-colors'
Plug 'rakr/vim-one'
Plug 't9md/vim-quickhl'
Plug 'mhinz/vim-startify'
Plug 'folke/which-key.nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'phaazon/hop.nvim'


call plug#end()

set completeopt=menu,menuone,noselect

colorscheme tokyonight
"colorscheme dracula " Or whatever colorscheme you make
"colorscheme xcodelight
"colorscheme one
"set background=light " dark

""""""""""""""""""""""""""""""""""""""""""""""""""""
" USE VIM SCRIPT TO CONFIG NEOVIM
""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""" vim-floaterm
nnoremap   <silent>   <F5>    :FloatermNew<CR>
tnoremap   <silent>   <F5>    <C-\><C-n>:FloatermNew<CR>
nnoremap   <silent>   <F6>    :FloatermPrev<CR>
tnoremap   <silent>   <F6>    <C-\><C-n>:FloatermPrev<CR>
nnoremap   <silent>   <F7>    :FloatermNext<CR>
tnoremap   <silent>   <F7>    <C-\><C-n>:FloatermNext<CR>
nnoremap   <silent>   <F8>   :FloatermToggle<CR>
tnoremap   <silent>   <F8>   <C-\><C-n>:FloatermToggle<CR>

"""""""""""""""" quickhl
nmap <Space>m <Plug>(quickhl-manual-this)
xmap <Space>m <Plug>(quickhl-manual-this)

"nmap <Space>w <Plug>(quickhl-manual-this-whole-word)
"xmap <Space>w <Plug>(quickhl-manual-this-whole-word)

"nmap <Space>c <Plug>(quickhl-manual-clear)
"vmap <Space>c <Plug>(quickhl-manual-clear)

nmap <Space>M <Plug>(quickhl-manual-reset)
xmap <Space>M <Plug>(quickhl-manual-reset)

nmap <Space>j <Plug>(quickhl-cword-toggle)
"nmap <Space>] <Plug>(quickhl-tag-toggle)
"map H <Plug>(operator-quickhl-manual-this-motion)


"""""""""""""""" coc
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

"" Highlight the symbol and its references when holding the cursor.
"autocmd CursorHold * silent call CocActionAsync('highlight')
"hi! link CocHighlightText CocListBlackGreen

"""""""""""""""" haskell
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords

"""""""""""""""" quickfix
:autocmd FileType qf nnoremap <buffer> <CR> <CR>:cclose<CR>

"""""""""""""""" gitgutter
nmap [g <Plug>(GitGutterPrevHunk)
nmap ]g <Plug>(GitGutterNextHunk)

"""""""""""""""""" neoformat
map <leader>bf :Neoformat<CR>

"""""""""""""""""" wincmd
noremap <silent> <leader>1 :<C-u>1  wincmd w<CR>
noremap <silent> <leader>2 :<C-u>2  wincmd w<CR>
noremap <silent> <leader>3 :<C-u>3  wincmd w<CR>
noremap <silent> <leader>4 :<C-u>4  wincmd w<CR>
noremap <silent> <leader>5 :<C-u>5  wincmd w<CR>
noremap <silent> <leader>6 :<C-u>6  wincmd w<CR>
noremap <silent> <leader>7 :<C-u>7  wincmd w<CR>
noremap <silent> <leader>8 :<C-u>8  wincmd w<CR>
noremap <silent> <leader>9 :<C-u>9  wincmd w<CR>
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
	  \  'left': [ [ 'buffers' ] ],
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

"""""""""""""""""" fzf-vim
"map <leader>bb :Buffers<CR>
"map <leader>ff :Files<CR>
"map <leader>fh :History<CR>
nnoremap <silent> <Leader>sa :Ag <C-R><C-W><CR>
nnoremap <silent> <Leader>sr :Rg <C-R><C-W><CR>

"""""""""""""""""" JuliaFormatter
" normal mode mapping
nnoremap <localleader>jf :JuliaFormatterFormat<CR>
" visual mode mapping
vnoremap <localleader>jf :JuliaFormatterFormat<CR>


"""""""""""""""""" telescope
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>bb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope oldfiles<cr>


"""""""""""""""""" vim-choosewin
" invoke with '-'
nmap  -  <Plug>(choosewin)

"""""""""""""""""" nvim-tree
let g:nvim_tree_quit_on_open = 0 "0 by default, closes the tree when you open a file
let g:nvim_tree_indent_markers = 1 "0 by default, this option shows indent markers when folders are open
let g:nvim_tree_git_hl = 1 "0 by default, will enable file highlight for git attributes (can be used without the icons).
let g:nvim_tree_highlight_opened_files = 1 "0 by default, will enable folder and file icon highlight for opened files/directories.
let g:nvim_tree_root_folder_modifier = ':~' "This is the default. See :help filename-modifiers for more options
let g:nvim_tree_add_trailing = 1 "0 by default, append a trailing slash to folder names
let g:nvim_tree_group_empty = 1 " 0 by default, compact folders that only contain a single folder into one node in the file tree
let g:nvim_tree_disable_window_picker = 1 "0 by default, will disable the window picker.
let g:nvim_tree_icon_padding = ' ' "one space by default, used for rendering the space between the icon and the filename. Use with caution, it could break rendering if you set an empty string depending on your font.
let g:nvim_tree_symlink_arrow = ' >> ' " defaults to ' ➛ '. used as a separator between symlinks' source and target.
let g:nvim_tree_respect_buf_cwd = 1 "0 by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.
let g:nvim_tree_create_in_closed_folder = 0 "1 by default, When creating files, sets the path of a file when cursor is on a closed folder to the parent folder when 0, and inside the folder when 1.
let g:nvim_tree_refresh_wait = 500 "1000 by default, control how often the tree can be refreshed, 1000 means the tree can be refresh once per 1000ms.
let g:nvim_tree_window_picker_exclude = {
    \   'filetype': [
    \     'notify',
    \     'packer',
    \     'qf'
    \   ],
    \   'buftype': [
    \     'terminal'
    \   ]
    \ }
" Dictionary of buffer option names mapped to a list of option values that
" indicates to the window picker that the buffer's window should not be
" selectable.
let g:nvim_tree_special_files = { 'README.md': 1, 'Makefile': 1, 'MAKEFILE': 1 } " List of filenames that gets highlighted with NvimTreeSpecialFile
let g:nvim_tree_show_icons = {
    \ 'git': 1,
    \ 'folders': 0,
    \ 'files': 0,
    \ 'folder_arrows': 0,
    \ }
"If 0, do not show the icons for one of 'git' 'folder' and 'files'
"1 by default, notice that if 'files' is 1, it will only display
"if nvim-web-devicons is installed and on your runtimepath.
"if folder is 1, you can also tell folder_arrows 1 to show small arrows next to the folder icons.
"but this will not work when you set indent_markers (because of UI conflict)

" default will show icon by default if no icon is provided
" default shows no icon by default
let g:nvim_tree_icons = {
    \ 'default': '',
    \ 'symlink': '',
    \ 'git': {
    \   'unstaged': "✗",
    \   'staged': "✓",
    \   'unmerged': "",
    \   'renamed': "➜",
    \   'untracked': "★",
    \   'deleted': "",
    \   'ignored': "◌"
    \   },
    \ 'folder': {
    \   'arrow_open': "",
    \   'arrow_closed': "",
    \   'default': "",
    \   'open': "",
    \   'empty': "",
    \   'empty_open': "",
    \   'symlink': "",
    \   'symlink_open': "",
    \   },
    \   'lsp': {
    \     'hint': "",
    \     'info': "",
    \     'warning': "",
    \     'error': "",
    \   }
    \ }

nnoremap <F3> :NvimTreeToggle<CR>
nnoremap <leader>ft :NvimTreeToggle<CR>
" NvimTreeOpen, NvimTreeClose, NvimTreeFocus and NvimTreeResize are also available if you need them

"autocmd CursorHold * lua vim.diagnostic.open_float(0, {scope="line"})

" a list of groups can be found at `:help nvim_tree_highlight`
highlight NvimTreeFolderIcon guibg=blue

"""""""""""""""""" nerdcommenter
let g:NERDCreateDefaultMappings = 0
nmap <leader>ct <plug>NERDCommenterToggle
nmap <leader>cu <plug>NERDCommenterUncomment
nmap <leader>cl <plug>NERDCommenterAlignLeft
nmap <leader>cb <plug>NERDCommenterAlignBoth

""""""""""""""""""""""""""""""""""""""""""""""""""""
" USE LUA TO CONFIG NEOVIM
""""""""""""""""""""""""""""""""""""""""""""""""""""
" begin

lua << EOF

-- telescope
local actions = require('telescope.actions')
require'telescope'.setup {
defaults = {
  mappings = {
    i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-n>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-p>"] = actions.move_selection_previous,
      },
    },
  }
}


--- nvim-lsp-installer
local lsp_installer_servers = require('nvim-lsp-installer.servers')

local servers = {
  "bashls",
  "pylsp",
  "clangd",
  "julials",
  "cmake",
  "rust_analyzer",
}

-- Loop through the servers listed above and set them up. If a server is
-- not already installed, install it.
for _, server_name in pairs(servers) do
    local server_available, server = lsp_installer_servers.get_server(server_name)
    if server_available then
        server:on_ready(function ()
            -- When this particular server is ready (i.e. when installation is finished or the server is already installed),
            -- this function will be invoked. Make sure not to also use the "catch-all" lsp_installer.on_server_ready()
            -- function to set up your servers, because by doing so you'd be setting up the same server twice.
            local opts = {}
            -- (optional) Customize the options passed to the server
            -- if server.name == "tsserver" then
            --     opts.root_dir = function() ... end
            -- end
            --server:setup(opts)
        end)
        if not server:is_installed() then
            -- Queue the server to be installed.
            print("Installing " .. server_name)
            server:install()
        end
    end
end

-- hop.nvim config
require'hop'.setup { keys = 'etovxqpdygfblzhckisuran', jump_on_sole_occurrence = false }
-- place this in one of your configuration file(s)
vim.api.nvim_set_keymap('n', 's', "<cmd>lua require'hop'.hint_char2()<cr>", {})
vim.api.nvim_set_keymap('n', 'S', "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})

-- nvim-lspconfig
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keyS
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>fb', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
    capabilities = capabilities
  }
end

-- which-key setup
  require("which-key").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
  local wk = require("which-key")

  wk.register({
    w = {
      name = "window", -- optional group name
      w = { "<C-w>w"       , "other-window"}          ,
      d = {'<C-W>c'        , 'delete-window'}         ,
      ["2"] = {'<C-W>v'    , 'layout-double-columns'} ,
      h = {'<C-W>h'        , 'window-left'}           ,
      j = {'<C-W>j'        , 'window-below'}          ,
      l = {'<C-W>l'        , 'window-right'}          ,
      k = {'<C-W>k'        , 'window-up'}             ,
      o = {'<C-W>o'        , 'window-only'}           ,
      H = {'<C-W>5<'       , 'expand-window-left'}    ,
      J = {':resize +5'    , 'expand-window-below'}   ,
      L = {'<C-W>5>'       , 'expand-window-right'}   ,
      K = {':resize -5'    , 'expand-window-up'}      ,
      ["="] = {'<C-W>='    , 'balance-window'}        ,
      s = {'<C-W>s'        , 'split-window-below'}    ,
      v = {'<C-W>v'        , 'split-window-right'}    ,
    },
  }, { prefix = "<leader>" })

-- nvim-tree setup
-- following options are the default
require'nvim-tree'.setup {
  -- disables netrw completely
  disable_netrw       = true,
  -- hijack netrw window on startup
  hijack_netrw        = true,
  -- open the tree when running this setup function
  open_on_setup       = false,
  -- will not open on setup if the filetype is in this list
  ignore_ft_on_setup  = {},
  -- closes neovim automatically when the tree is the last **WINDOW** in the view
  auto_close          = false,
  -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
  open_on_tab         = false,
  -- hijacks new directory buffers when they are opened.
  update_to_buf_dir   = {
    -- enable the feature
    enable = true,
    -- allow to open the tree if it was previously closed
    auto_open = true,
  },
  -- hijack the cursor in the tree to put it at the start of the filename
  hijack_cursor       = false,
  -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
  update_cwd          = false,
  -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
  update_focused_file = {
    -- enables the feature
    enable      = true,
    -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
    -- only relevant when `update_focused_file.enable` is true
    update_cwd  = false,
    -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
    -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
    ignore_list = {}
  },
  -- configuration options for the system open command (`s` in the tree by default)
  system_open = {
    -- the command to run this, leaving nil should work in most cases
    cmd  = nil,
    -- the command arguments as a list
    args = {}
  },

  view = {
    -- width of the window, can be either a number (columns) or a string in `%`, for left or right side placement
    width = 35,
    -- height of the window, can be either a number (columns) or a string in `%`, for top or bottom side placement
    height = 35,
    -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
    side = 'left',
    -- if true the tree will resize itself after opening a file
    auto_resize = false,
    mappings = {
      -- custom only false will merge the list with the default mappings
      -- if true, it will only use your list to set the mappings
      custom_only = false,
      -- list of mappings to set on the tree manually
      list = {}
    }
  }
}

-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

EOF

"end
