-- Functions for make mapping easier.
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function wk_add(mappings, options)
  table.insert(extra_which_keys, { mappings, options })
end

extra_which_keys = {}

additional_plugins = {
  -- You can put your additional plugins here.
  -- Syntax is like normal packer.nvim Syntax.
  -- If you need to set some settings for your plugins
  -- you must put configs in config = function() like below examples

  { "famiu/feline.nvim", branch = "develop" },

  -- "mhartington/formatter.nvim",

  -- { crispgm/nvim-go", ft = "go" },

  --[[ {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    run = ":call mkdp#util#install()",
    config = function ()
      vim.g.mkdp_auto_close = 0
    end
  },

  {
    "andweeb/presence.nvim",
    config = function ()
      require("presence"):setup({
      log_level           = "info", -- Log messages at or above this level (one of the following: "debug", "info", "warn", "error")
      debounce_timeout    = 5,   -- Number of seconds to debounce events (or calls to `:lua package.loaded.presence:update(<filename>, true)`)
      blacklist           = {},  -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
      })
    end
  } ]]

  {
     'phaazon/hop.nvim',
     branch = 'v1', -- optional but strongly recommended
     config = function()
       -- you can configure Hop the way you like here; see :h hop-config
       require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
     end
  },
  {
     "folke/trouble.nvim",
     requires = "kyazdani42/nvim-web-devicons",
     config = function()
       require("trouble").setup {
         -- your configuration comes here
         -- or leave it empty to use the default settings
         -- refer to the configuration section below
       }
     end
  },
}

-- Other settings here
-- For examples for disabling line number:
-- vim.opt.number = false
-- vim.opt.relativenumber = false
vim.o.timeoutlen = 600
vim.o.updatetime = 100
vim.o.scrolloff = 18
vim.o.sidescrolloff = 3

-- Or for changing terminal toggle mapping:
-- first argument is mode of mapping. second argument is keymap.
-- third argument is command. and last argument is optional argument like {expr = true}.
-- map("n", "<C-t>", ":ToggleTerm<CR>")
-- map("t", "<C-t>", ":ToggleTerm<CR>")

map('n', '<leader>bb', ':Telescope buffers<CR>')
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<space>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>')
map("n", "<F3>", ":NvimTreeFindFileToggle<CR>")
map("n", "<leader>ft", ":NvimTreeFindFileToggle<CR>")
map("n", "<leader>e", ":NvimTreeFindFileToggle<CR>")
map("n", "<C-n>", ":NvimTreeFindFileToggle<CR>")
map("n", "<leader><leader>", ":Telescope buffers<CR>")
map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>")
map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>")
map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>")
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>")

local config = { -- your config
  virtual_text = false,
}
vim.diagnostic.config(config)


-- This is example of how to make keymap and add it to
-- which_keys(that pop of window on bottom of NeoVim that help you to find keymaps)
-- This will make new group of keymaps names Something with two commands and they're describtions.
-- with pressing `<leader> + s` you can trigger which keys to show you
-- Something commands. with pressing e it will echo hello on command prompt at the end of NeoVim
-- and with pressing f it will echo Goodbye on command prompt at the end of NeoVim
--[[ wk_add(
  { s = {
    name = "Something",
    e = { ":echo 'Hello'<CR>", "Echo Hello" },
    f = { ":echo 'Goodbye'<CR>", "Echo Goodbye" },
  }},
  { prefix = "<leader>" }
)]]

user_lualine_style = 1 -- You can choose between 1, 2, 3, 4 and 5
user_indent_blankline_style = 1 -- You can choose between 1, 2, 3, 4,5 and 6

vim.cmd("autocmd FileType lua set tabstop=2")
vim.cmd("autocmd Filetype lua set shiftwidth=2")
-- vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
vim.cmd("autocmd FileType qf nnoremap <buffer><silent> <CR> <CR> :cclose<CR>")
