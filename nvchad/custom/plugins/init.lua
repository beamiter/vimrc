-- /lua/custom/plugins/init.lua
return {
   {'junegunn/fzf', dir = '~/.fzf', run = './install --all' },
   {'junegunn/fzf.vim'},
   { "williamboman/nvim-lsp-installer" },
   {
      "folke/which-key.nvim",
      config = function()
        require("which-key").setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        }
      end
   },
   {
      'phaazon/hop.nvim',
      branch = 'v1', -- optional but strongly recommended
      config = function()
        -- you can configure Hop the way you like here; see :h hop-config
        require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      end
   }

}
