-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
  theme = "gruvchad",
}

M.plugins = {
   user = {
      ["goolord/alpha-nvim"] = {
         disable = false,
      },
      ["folke/which-key.nvim"] = {
        disable = false,
      },
      ["neovim/nvim-lspconfig"] = {
        config = function()
          require "plugins.configs.lspconfig"
          require "custom.plugins.lspconfig"
        end,
      },
   },
}

return M
