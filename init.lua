local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  Packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

local opt = vim.opt
local g = vim.g
g.mapleader = ' '

g.maplocalleader = ','
g.noautochdir = true
g.nobackup = true
g.noswapfile = true
g.nowritebackup = true
g.vscode_style = "dark"

opt.autoindent = true
opt.backspace = { 'indent', 'eol', 'start' }
opt.clipboard:append 'unnamedplus'
opt.cmdheight = 1
opt.colorcolumn = '120'
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.cul = true
opt.encoding = 'utf-8'
opt.expandtab = true
opt.fillchars = { eob = " " }
opt.hidden = true
opt.ignorecase = true
opt.laststatus = 2
opt.list = true
opt.mouse = "a"
opt.number = true
opt.numberwidth = 2
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 3
-- opt.shadafile = "NONE"
opt.shiftwidth = 2
opt.showtabline = 2
opt.shortmess:append "sI"
opt.signcolumn = 'yes'
opt.sidescrolloff = 3
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 4
opt.termguicolors = true
opt.title = true
opt.timeoutlen = 500
opt.updatetime = 250
opt.undofile = true
opt.whichwrap:append "<>[]hl"

-- Create autocmd
vim.api.nvim_command('autocmd FileType c,cpp setlocal shiftwidth=2')
vim.api.nvim_command('autocmd FileType c,cpp setlocal tabstop=2')

-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim
]]

local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

map('n', '<F3>', ':NvimTreeFindFileToggle<CR>', opts)
map('n', '<C-n>', ':NvimTreeFindFileToggle<CR>', opts)
map('n', '[g', ':Gitsigns prev_hunk<CR>', opts)
map('n', ']g', ':Gitsigns next_hunk<CR>', opts)
map('n', '<leader>1', '<Cmd>BufferLineGoToBuffer 1<CR>', opts)
map('n', '<leader>2', '<Cmd>BufferLineGoToBuffer 2<CR>', opts)
map('n', '<leader>3', '<Cmd>BufferLineGoToBuffer 3<CR>', opts)
map('n', '<leader>4', '<Cmd>BufferLineGoToBuffer 4<CR>', opts)
map('n', '<leader>5', '<Cmd>BufferLineGoToBuffer 5<CR>', opts)
map('n', '<leader>6', '<Cmd>BufferLineGoToBuffer 6<CR>', opts)
map('n', '<leader>7', '<Cmd>BufferLineGoToBuffer 7<CR>', opts)
map('n', '<leader>8', '<Cmd>BufferLineGoToBuffer 8<CR>', opts)
map('n', '<leader>9', '<Cmd>BufferLineGoToBuffer 9<CR>', opts)
map('n', '<leader>So', "<cmd>lua require('spectre').open()<CR>", {})
map('n', '<leader>Sw', "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", {})
map('v', '<leader>S', "<cmd>lua require('spectre').open_visual()<CR>", {})
map('n', '<leader>Sp', "<cmd>lua require('spectre').open_file_search()<CR>", {})

require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use 'nvim-lua/plenary.nvim'
  use "lewis6991/impatient.nvim"
  use { 'windwp/nvim-autopairs', config = function()
    require('nvim-autopairs').setup {}
  end }
  use 'dyng/ctrlsf.vim'
  use 'junegunn/fzf.vim'
  use { 'junegunn/fzf', dir = '~/.fzf', run = './install --all' }

  use { 'lukas-reineke/indent-blankline.nvim', config = function()
    require("indent_blankline").setup {
      show_current_context = true,
      show_current_context_start = true,
    }
  end }

  use 'tpope/vim-fugitive'

  use { "akinsho/toggleterm.nvim", tag = 'v1.*', config = function()
    require("toggleterm").setup()
    function _G.set_terminal_keymaps()
      local opts = { noremap = true }
      vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
      vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
      vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
      vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
      vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
      vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
    end

    -- if you only want these mappings for toggle term use term://*toggleterm#* instead
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
  end }

  use { 'numToStr/FTerm.nvim', config = function()
    require 'FTerm'.setup({
      -- border     = 'double',
      -- dimensions = {
      --   height = 0.9,
      --   width = 0.9,
      -- },
    })
    -- Example keybindings
    vim.keymap.set('n', '<F5>', '<CMD>lua require("FTerm").toggle()<CR>')
    vim.keymap.set('t', '<F5>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
  end
  }

  use { "numToStr/Comment.nvim", config = function()
    require('Comment').setup {}
    -- Toggle using count
    vim.keymap.set('n', '<leader>cl', "v:count == 0 ? '<Plug>(comment_toggle_current_linewise)' : '<Plug>(comment_toggle_linewise_count)'", { expr = true, remap = true })
    -- Toggle in VISUAL mode
    vim.keymap.set('x', '<leader>cl', '<Plug>(comment_toggle_linewise_visual)')

  end }

  use 'sbdchd/neoformat'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

  use { 'christianchiarulli/nvcode-color-schemes.vim',
    require 'nvim-treesitter.configs'.setup {
      ensure_installed = {"c", "rust", "julia", "python"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
      highlight = {
        enable = true, -- false will disable the whole extension
        -- disable = { "c", "rust" }, -- list of language that will be disabled
      },
    }
  }
  use 'marko-cerovac/material.nvim'
  use 'LunarVim/onedarker.nvim'
  use 'Mofiqul/vscode.nvim'
  use 'srcery-colors/srcery-vim'
  use 'sainnhe/gruvbox-material'
  use 'sainnhe/everforest'
  use 'sainnhe/edge'
  use 'felipec/vim-felipec'
  use { 'sainnhe/sonokai', config = function()
    vim.g.sonokai_style = 'shusia'
    vim.g.sonokai_better_performance = 1
  end }

  use 'bluz71/vim-moonfly-colors'
  use 'bluz71/vim-nightfly-guicolors'

  use { 'nvim-telescope/telescope.nvim', config = function()
    local actions = require('telescope.actions')
    require 'telescope'.setup {
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
  end }

  use 'ntpeters/vim-better-whitespace'
  use 'mhinz/vim-grepper'
  use 'mhinz/vim-startify'
  use { 'windwp/nvim-spectre', config = function()
    require('spectre').setup()
  end }

  use { 'phaazon/hop.nvim', config = function()
    require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran', jump_on_sole_occurrence = false }
    -- place this in one of your configuration file(s)
    vim.api.nvim_set_keymap('n', 's', "<cmd>lua require'hop'.hint_char2()<cr>", {})
    vim.api.nvim_set_keymap('n', 'S', "<cmd>lua require'hop'.hint_char1()<cr>", {})
    vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
    vim.api.nvim_set_keymap('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
  end }

  use 'kyazdani42/nvim-web-devicons'

  use { 'feline-nvim/feline.nvim', requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('feline').setup()
    end
  }

  use { 'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require("bufferline").setup {}
    end }

  use { 'kyazdani42/nvim-tree.lua', config = function()
    require('nvim-tree').setup()
  end }

  --use 'jiangmiao/auto-pairs'
  --use '9mm/vim-closer'
  use { 'andymass/vim-matchup', event = 'VimEnter' }

  use {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  }

  use { 'folke/which-key.nvim', config = function()
    require("which-key").setup {}
    local wk = require("which-key")
    wk.register({
      w = {
        name = "window", -- optional group name
        w = { "<C-w>w", "other-window" },
        d = { '<C-W>c', 'delete-window' },
        ["2"] = { '<C-W>v', 'layout-double-columns' },
        h = { '<C-W>h', 'window-left' },
        j = { '<C-W>j', 'window-below' },
        l = { '<C-W>l', 'window-right' },
        k = { '<C-W>k', 'window-up' },
        o = { '<C-W>o', 'window-only' },
        H = { '<C-W>5<', 'expand-window-left' },
        J = { ':resize +5', 'expand-window-below' },
        L = { '<C-W>5>', 'expand-window-right' },
        K = { ':resize -5', 'expand-window-up' },
        ["="] = { '<C-W>=', 'balance-window' },
        s = { '<C-W>s', 'split-window-below' },
        v = { '<C-W>v', 'split-window-right' },
      },
      f = {
        name = "files",
        t = { ":NvimTreeFindFileToggle<CR>", "tree toggle" },
        f = { ":Telescope find_files<CR>", "files" },
        g = { ":Telescope live_grep<CR>", "live_grep" },
        b = { ":Telescope buffers<CR>", "buffers" },
        h = { ":Telescope oldfiles<CR>", "oldfiles" },
      },
      s = {
        name = "search",
        g = { ":Telescope live_grep<CR>", "live_grep" },
        a = { ":Ag <C-R><C-W><CR>", "ag current" },
        r = { ":Rg <C-R><C-W><CR>", "rg current" },
      },
      b = {
        name = "buffers",
        f = { ":Neoformat<CR>", "format" },
        b = { ":Telescope buffers<CR>", "buffers" },
      },
    }, { prefix = "<leader>" })
  end }

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use { 'rafamadriz/friendly-snippets' }

  use { 'L3MON4D3/LuaSnip', config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end }

  use 'williamboman/nvim-lsp-installer'

  use { 'hrsh7th/nvim-cmp', config = function()
    -- Setup nvim-cmp.
    local cmp = require 'cmp'
    local default = {
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      formatting = {
        format = function(entry, vim_item)
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            nvim_lua = "[Lua]",
            buffer = "[BUF]",
          })[entry.source.name]
          return vim_item
        end,
      },
      mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
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
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "nvim_lua" },
        { name = "path" },
      },
    }

    cmp.setup(default)
  end }

  use { 'neovim/nvim-lspconfig', config = function()
    -- Mappings.
    local map = vim.api.nvim_set_keymap
    local buf_map = vim.api.nvim_buf_set_keymap
    local opts = { noremap = true, silent = true }
    map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    map('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    map('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    map('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    map('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
    local on_attach = function(_, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
      -- Mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      buf_map(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      buf_map(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_map(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_map(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_map(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      buf_map(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
      buf_map(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
      buf_map(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
      buf_map(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      buf_map(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_map(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      buf_map(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      buf_map(bufnr, 'n', '<space>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    capabilities.textDocument.completion.completionItem.preselectSupport = true
    capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
    capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
    capabilities.textDocument.completion.completionItem.deprecatedSupport = true
    capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
    capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      },
    }
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

    local lsp_installer = require("nvim-lsp-installer")
    lsp_installer.settings {
      ui = {
        icons = {
          server_installed = "﫟",
          server_pending = "",
          server_uninstalled = "✗",
        },
      },
    }

    lsp_installer.on_server_ready(function(server)
      local server_opts = {
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
          debounce_text_changes = 150,
        },
        settings = {},
      }

      -- basic example to edit lsp server's options, disabling tsserver's inbuilt formatter
      if server.name == 'tsserver' then
        server_opts.on_attach = function(client, bufnr)
          client.resolved_capabilities.document_formatting = false
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>fm", "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
        end
      end

      server:setup(server_opts)

      vim.cmd [[ do User LspAttachBuffers ]]
    end)

    -- diagnostic config
    -- local config = {
    --   virtual_text = true,
    -- }
    -- vim.diagnostic.config(config)

  end }

  -- You can alias plugin names
  use { 'dracula/vim', as = 'dracula' }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if Packer_bootstrap then
    require('packer').sync()
  end

end)

vim.cmd [[
colorscheme sonokai
filetype off
syntax on
]]
