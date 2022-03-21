set completeopt=menu,menuone,noselect

lua << EOF

vim.g.mapleader = " "

-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim
colorscheme material
]]

vim.api.nvim_set_keymap('n', '<F3>', ':NvimTreeToggle<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>ft', ':NvimTreeToggle<CR>', {noremap = true})


return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'dyng/ctrlsf.vim'
  use 'junegunn/fzf.vim'
  use 'Yggdroot/indentLine'
  use 'itchyny/lightline.vim'
  use 'mengelbrecht/lightline-bufferline'
  use 'preservim/nerdcommenter'
  use 'sbdchd/neoformat'
  use 'christianchiarulli/nvcode-color-schemes.vim'
  use 'marko-cerovac/material.nvim'
  use 'nvim-telescope/telescope.nvim'
  use 'ntpeters/vim-better-whitespace'
  use 'mhinz/vim-grepper'
  use 'mhinz/vim-startify'
  use {'phaazon/hop.nvim', config = function()
require'hop'.setup { keys = 'etovxqpdygfblzhckisuran', jump_on_sole_occurrence = false }
-- place this in one of your configuration file(s)
vim.api.nvim_set_keymap('n', 's', "<cmd>lua require'hop'.hint_char2()<cr>", {})
vim.api.nvim_set_keymap('n', 'S', "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
  end}

  use 'kyazdani42/nvim-web-devicons'
  use {'kyazdani42/nvim-tree.lua', config = function()
    require('nvim-tree').setup()
  end}
  use 'jiangmiao/auto-pairs'
  --use '9mm/vim-closer'
  use {'andymass/vim-matchup', event = 'VimEnter'}
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }

  use {'folke/which-key.nvim', config = function()
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

  end}

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use 'williamboman/nvim-lsp-installer'
  use {'hrsh7th/nvim-cmp', config = function()
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

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
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

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  local servers = { 'clangd', 'rust_analyzer', 'julials' }
  for _, lsp in pairs(servers) do
    require('lspconfig')[lsp].setup {
      capabilities = capabilities
    }
  end
  end}

  use {'neovim/nvim-lspconfig', config = function()
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

-- Use an on_attach function to only map the following keys
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
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'clangd', 'rust_analyzer', 'julials' }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }
end
  end}

  -- You can alias plugin names
  use {'dracula/vim', as = 'dracula'}

end)

EOF
