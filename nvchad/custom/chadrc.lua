-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
  theme = "decay",
}

M.plugins = {
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
   ['junegunn/fzf'] = {
     dir = '~/.fzf',
     run = './install --all',
   },
   -- ['akinsho/bufferline.nvim'] = {
   --   tag = "v2.*",
   --   config = function()
   --     require("bufferline").setup{}
   --   end
   -- },
   ['junegunn/fzf.vim'] = {},
   ["tpope/vim-fugitive"] = {},
   ['phaazon/hop.nvim'] = {
     branch = 'v1', -- optional but strongly recommended
     config = function()
       -- you can configure Hop the way you like here; see :h hop-config
       require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
     end
   },
}

M.mappings = require "custom.mappings"

return M
