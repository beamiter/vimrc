Vapour.plugins.treesitter.ensure_installed = ""
Vapour.settings.colorscheme = "dracula"
Vapour.plugins.user = {
  {
      'phaazon/hop.nvim',
      branch = 'v1', -- optional but strongly recommended
      config = function()
        -- you can configure Hop the way you like here; see :h hop-config
        require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
      end
  },
  {
      "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"}
  },
  {
      "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim"
  },
  {
      "LunarVim/onedarker.nvim"
  },
  {
      "Mofiqul/vscode.nvim"
  },
}

vim.opt.timeoutlen = 1000
vim.opt.updatetime = 300
vim.opt.relativenumber = true
vim.g.vscode_style = "dark"

local opts = {noremap = true, silent = true}
vim.api.nvim_set_keymap('n', '<space>bb', ':Telescope buffers<CR>', opts)
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>fc', ':Telescope colorscheme<CR>', opts)

local map = vim.api.nvim_set_keymap
map("n", "<leader><leader>", ":Telescope <CR>", opts)
map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>", opts)
map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>", opts)
map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>", opts)
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>", opts)
map("n", "<F3>", ":NvimTreeToggle<CR>", opts)
--map("n", "<leader>ft", ":NvimTreeToggle<CR>", opts)
map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)
