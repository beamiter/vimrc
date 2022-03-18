lua << EOF

local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.cmd 'colorscheme material'
vim.cmd 'filetype off'
vim.cmd 'syntax on'

vim.opt.autoindent = true
--vim.opt.backspace=indent,eol,start
vim.opt.clipboard:append 'unnamedplus'
vim.opt.colorcolumn = '120'
vim.opt.encoding= 'utf-8'
vim.opt.expandtab = true
vim.opt.guioptions=''
--vim.opt.nobackup = true
--vim.opt.noswapfile = true
--vim.opt.nowritebackup = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth=4
vim.opt.shortmess:append 'csI'
vim.opt.showtabline=2
vim.opt.laststatus=2
vim.opt.tabstop=4
vim.opt.pumheight=10
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
--vim.opt.noautochdir = true

vim.opt.completeopt={'menu','menuone','noselect'}

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'JuliaEditorSupport/julia-vim'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'dcampos/nvim-snippy'
  use 'dcampos/cmp-snippy'

  use 'williamboman/nvim-lsp-installer'

  -- Plugins can have dependencies on other plugins
  use {
    'hrsh7th/nvim-cmp',
    config = function()
      local cmp = require'cmp'
      cmp.setup({
        --snippet
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
        -- mapping
        mapping = {
          ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-y>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
             if cmp.visible() then
                cmp.select_next_item()
             elseif require("luasnip").expand_or_jumpable() then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
             else
                fallback()
             end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
             if cmp.visible() then
                cmp.select_prev_item()
             elseif require("luasnip").jumpable(-1) then
                vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
             else
                fallback()
             end
          end, { "i", "s" }),
        },
        -- sources
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'vsnip' },
          { name = 'snippy' },
          { name = 'nvim_lua' },
          { name = 'buffer' },
          { name = 'path' },
          })
      })
      cmp.setup.cmdline('/', {
        sources = {
          { name = 'buffer' }
        }
      })
      cmp.setup.cmdline(':', {
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        })
      })

    end
  }

  use {'neovim/nvim-lspconfig',
  config = function()
    local servers = {
      "bashls",
      -- "pylsp",
      "clangd",
      "julials",
      -- "cmake",
      "rust_analyzer",
    }
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
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    end
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    --capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
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

  end}

  use 'simrat39/rust-tools.nvim'
  use 'dyng/ctrlsf.vim'
  use { 'junegunn/fzf', run = function() vim.fn['fzf#install'](0) end }
  use 'junegunn/fzf.vim'
  use 'neovimhaskell/haskell-vim'
  use 'Yggdroot/indentLine'
  use 'kdheepak/JuliaFormatter.vim'
  use 'itchyny/lightline.vim'
  use 'mengelbrecht/lightline-bufferline'
  use 'preservim/nerdcommenter'
  use 'sbdchd/neoformat'
  use 'christianchiarulli/nvcode-color-schemes.vim'
  use 'kyazdani42/nvim-web-devicons'
  use {'kyazdani42/nvim-tree.lua', config = function() require('nvim-tree').setup() end}
  use 'marko-cerovac/material.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'RishabhRD/popfix'
  use 'nvim-lua/popup.nvim'
  use {'nvim-telescope/telescope.nvim', config = function() require('telescope').setup() end}
  use 'ntpeters/vim-better-whitespace'
  use 't9md/vim-choosewin'
  use 'arzg/vim-colors-xcode'
  use 'voldikss/vim-floaterm'
  use 'mhinz/vim-grepper'
  use 'bluz71/vim-moonfly-colors'
  use 'rakr/vim-one'
  use 't9md/vim-quickhl'
  use 'mhinz/vim-startify'
  use {'folke/which-key.nvim', config = function()
    require("which-key").setup()
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
  end}

  use {'phaazon/hop.nvim', config = function()
  require'hop'.setup { keys = 'etovxqpdygfblzhckisuran', jump_on_sole_occurrence = false }
    -- place this in one of your configuration file(s)
    vim.api.nvim_set_keymap('n', 's', "<cmd>lua require'hop'.hint_char2()<cr>", {})
    vim.api.nvim_set_keymap('n', 'S', "<cmd>lua require'hop'.hint_char1()<cr>", {})
    vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
    vim.api.nvim_set_keymap('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
  end}

  -- Simple plugins can be specified as strings
  use '9mm/vim-closer'

  -- Load on an autocommand event
  use {'andymass/vim-matchup', event = 'VimEnter'}

  -- Load on a combination of conditions: specific filetypes or commands
  -- Also run code after load (see the "config" key)
  --use {
  --  'w0rp/ale',
  --  ft = {'sh', 'zsh', 'bash', 'c', 'cpp', 'cmake', 'html', 'markdown', 'racket', 'vim', 'tex'},
  --  cmd = 'ALEEnable',
  --  config = 'vim.cmd[[ALEEnable]]'
  --}

  -- Post-install/update hook with neovim command
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  -- Post-install/update hook with call of vimscript function with argument
  use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

  -- Use dependency and run lua function after load
  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }

  -- You can alias plugin names
  use {'dracula/vim', as = 'dracula'}

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)

EOF
