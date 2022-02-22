-- /lua/custom/plugins/init.lua
return {
   { "williamboman/nvim-lsp-installer" },
   { 'goolord/alpha-nvim' },
   {
        "folke/which-key.nvim",
        config = function()
          require("which-key").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
          }
        end
   }

}
