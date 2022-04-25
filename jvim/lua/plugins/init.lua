local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
end

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim
]]

local plugins = {
  -- Packer can manage itself
  'wbthomason/packer.nvim',

  'nvim-lua/plenary.nvim',
  "lewis6991/impatient.nvim",

  { 'windwp/nvim-autopairs', config = function()
    require('nvim-autopairs').setup {}
  end },
  'dyng/ctrlsf.vim',
  'junegunn/fzf.vim',
  { 'junegunn/fzf', dir = '~/.fzf', run = './install --all' },
  -- 'Yggdroot/indentLine'
  -- 'itchyny/lightline.vim'
  -- 'mengelbrecht/lightline-bufferline'
  { 'lukas-reineke/indent-blankline.nvim', config = function()
    require("plugins.configs.indent")
  end },
  -- { 'terrortylor/nvim-comment', config = function()
  --   require('nvim_comment').setup()
  -- end },
  { "numToStr/Comment.nvim", config = function()
    require('Comment').setup()
  end },
  'sbdchd/neoformat',
  'christianchiarulli/nvcode-color-schemes.vim',
  'marko-cerovac/material.nvim',
  'LunarVim/onedarker.nvim',
  { 'Mofiqul/vscode.nvim' },
  { 'nvim-telescope/telescope.nvim', config = function()
    require("plugins.configs.telescope")
  end },
  'ntpeters/vim-better-whitespace',
  'mhinz/vim-grepper',
  'mhinz/vim-startify',
  {
    'goolord/alpha-nvim',
    config = function()
      -- require 'alpha'.setup(require 'alpha.themes.dashboard'.config)
      require 'alpha'.setup(require 'alpha.themes.startify'.config)
    end
  },
  { 'phaazon/hop.nvim', config = function()
    require("plugins.configs.hop")
  end },
  'kyazdani42/nvim-web-devicons',
  { 'feline-nvim/feline.nvim', requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require('feline').setup()
    end
  },
  { 'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons',
    config = function()
      require("bufferline").setup()
    end },
  { 'kyazdani42/nvim-tree.lua', config = function()
    require('nvim-tree').setup()
  end },
  { 'andymass/vim-matchup', event = 'VimEnter' },
  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
  {
    'lewis6991/gitsigns.nvim', requires = { 'nvim-lua/plenary.nvim' },
    config = function() require('gitsigns').setup() end
  },
  { 'folke/which-key.nvim', config = function()
    require("plugins.configs.which-key")
  end },
  {
    "themercorp/themer.lua",
    config = function()
      require("themer").setup({
        colorscheme = "rose_pine",
        styles = {
          ["function"]    = { style = 'italic' },
          functionbuiltin = { style = 'italic' },
          variable        = { style = 'italic' },
          variableBuiltIn = { style = 'italic' },
          parameter       = { style = 'italic' },
        },
      })
    end
  },

  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  { 'rafamadriz/friendly-snippets' },
  { 'L3MON4D3/LuaSnip', config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end },
  'williamboman/nvim-lsp-installer',
  { 'hrsh7th/nvim-cmp', config = function()
    require("plugins.configs.nvim-cmp")
  end },
  { 'neovim/nvim-lspconfig',
    config = function()
      require("plugins.configs.nvim-lspconfig")
    end },

  -- You can alias plugin names
  -- { 'dracula/vim', as = 'dracula' },
  'Mofiqul/dracula.nvim',

}

local packer = require('packer')
packer.startup(function(use)
  for _, v in pairs(plugins) do
    use(v)
  end
end)

-- Automatically set up your configuration after cloning packer.nvim
-- Put this at the end after all plugins
if packer_bootstrap then
  packer.sync()
end
