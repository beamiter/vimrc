return {
  {
    "AstroNvim/astrocore",
    ---@param opts AstroCoreOpts
    opts = function(_, opts)
      for k, _ in pairs(opts.mappings.n) do
        if k:find "^<Leader>bs" then opts.mappings.n[k] = false end
      end
    end,
  },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      -- Configuration table of features provided by AstroLSP
      features = {
        autoformat = false, -- enable or disable auto formatting on start
      },
      -- customize lsp formatting options
      formatting = {
        -- control auto formatting on save
        format_on_save = {
          enabled = false, -- enable or disable format on save globally
        },
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      opts.tabline = nil -- remove tabline
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window.width = 60
    end,
  },
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup()
      local opts = { noremap = true, silent = true }
      local map = vim.api.nvim_set_keymap
      map("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", opts)
      map("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", opts)
      map("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", opts)
      map("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", opts)
      map("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", opts)
      map("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", opts)
      map("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", opts)
      map("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", opts)
      map("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", opts)
      map("n", "<leader>0", "<Cmd>BufferLineGoToBuffer 10<CR>", opts)
      map("n", "<localleader>1", ":<C-u>1 wincmd w<CR>", opts)
      map("n", "<localleader>2", ":<C-u>2 wincmd w<CR>", opts)
      map("n", "<localleader>3", ":<C-u>3 wincmd w<CR>", opts)
      map("n", "<localleader>4", ":<C-u>4 wincmd w<CR>", opts)
      map("n", "<localleader>5", ":<C-u>5 wincmd w<CR>", opts)
      map("n", "<localleader>6", ":<C-u>6 wincmd w<CR>", opts)
      map("n", "<localleader>7", ":<C-u>7 wincmd w<CR>", opts)
      map("n", "<localleader>8", ":<C-u>8 wincmd w<CR>", opts)
      map("n", "<localleader>9", ":<C-u>9 wincmd w<CR>", opts)
      map("n", "<localleader>0", ":<C-u>10 wincmd w<CR>", opts)
      map("n", "<leader>bd", ":bd<CR>", opts)
      map("n", "<leader>bj", "<Cmd>BufferLinePick<CR>", opts)
    end,
  },
  {
    "phaazon/hop.nvim",
    config = function()
      require("hop").setup { keys = "etovxqpdygfblzhckisuran", jump_on_sole_occurrence = false }
      -- place this in one of your configuration file(s)
      vim.api.nvim_set_keymap("n", "s", "<cmd>lua require'hop'.hint_char2()<cr>", {})
      vim.api.nvim_set_keymap("n", "S", "<cmd>lua require'hop'.hint_char1()<cr>", {})
      vim.api.nvim_set_keymap("n", "f", "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
      vim.api.nvim_set_keymap("n", "F", "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
    end,
  },
}
