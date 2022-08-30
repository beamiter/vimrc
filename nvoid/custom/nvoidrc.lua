local M = {}

-- UI
M.ui = {
  theme = "onedark", -- aquarium | catppuccin | classic-dark | dracula | gruvbox | nightfox | nord | onedark | radium | solarized | tokyodark | uwu
  transparency = false,
  statusline = {
    style = "nvoid", -- evil | minimal | nvoid
    enabled = true,
  },
  bufferline = {
    enabled = true,
    lazyload = true,
  },
}
-- OPT
M.options = {
  clipboard = "unnamedplus",
  cmdheight = 1,
  mouse = "a",
  mapleader = " ",
  wrap = false,
  number = true,
  relative_number = false,
  number_width = 6,
  cursor_line = true,
  expand_tab = true,
  ignore_case = true,
  smart_case = true,
  smart_indent = true,
  swap_file = false,
  backup = false,
  show_mode = false,
}

-- Add Treesitter langs
M.ts_add = {} -- fish

-- Lsp
M.lsp = {
  add = {},
  virtual_text = true,
  document_highlight = true,
  autoforamt = false,
}

-- Plugins
M.plugins = {
  add = {
    {
      "phaazon/hop.nvim",
      config = function()
        require("hop").setup({ keys = "etovxqpdygfblzhckisuran", jump_on_sole_occurrence = false })
        -- place this in one of your configuration file(s)
        vim.api.nvim_set_keymap("n", "s", "<cmd>lua require'hop'.hint_char2()<cr>", {})
        vim.api.nvim_set_keymap("n", "S", "<cmd>lua require'hop'.hint_char1()<cr>", {})
        vim.api.nvim_set_keymap(
          "n",
          "f",
          "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>",
          {}
        )
        vim.api.nvim_set_keymap(
          "n",
          "F",
          "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>",
          {}
        )
      end,
    },
    {
      "akinsho/bufferline.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      config = function()
        require("bufferline").setup({})
      end,
    },
  },
  remove = {
    alpha = false,
    blankline = false,
    colorizer = false,
    gitsigns = false,
    nvimtree = false,
  },
  nvimtree = {
    git = true,
    indent_markers = true,
  },
}

-- Add new whichkey bind
M.whichkey_add = {
  b = {
    b = { ":Telescope buffers<CR>", "buffers" },
  },
  l = {
    a = { ":lua vim.lsp.buf.code_action()<CR>", "code action" },
  },
  s = {
    g = { ":Telescope grep_string<CR>", "live grep" },
  },
}
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', '<Space>1', '<Cmd>BufferLineGoToBuffer 1<CR>', opts)
map('n', '<Space>2', '<Cmd>BufferLineGoToBuffer 2<CR>', opts)
map('n', '<Space>3', '<Cmd>BufferLineGoToBuffer 3<CR>', opts)
map('n', '<Space>4', '<Cmd>BufferLineGoToBuffer 4<CR>', opts)
map('n', '<Space>5', '<Cmd>BufferLineGoToBuffer 5<CR>', opts)
map('n', '<Space>6', '<Cmd>BufferLineGoToBuffer 6<CR>', opts)
map('n', '<Space>7', '<Cmd>BufferLineGoToBuffer 7<CR>', opts)
map('n', '<Space>8', '<Cmd>BufferLineGoToBuffer 8<CR>', opts)
map('n', '<Space>9', '<Cmd>BufferLineGoToBuffer 9<CR>', opts)
map('n', '<Space>0', '<Cmd>BufferLineGoToBuffer 10<CR>', opts)

-- Note: Visit "https://github.com/ysfgrgO7/nvoid-custom-config" For more info how the file works

return M
