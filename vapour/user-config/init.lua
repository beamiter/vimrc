Vapour.plugins.treesitter.ensure_installed = { "c", "cpp", "rust", "julia", "python" }
Vapour.plugins.toggleterm.enabled = true
Vapour.plugins.null_ls.enabled = false

Vapour.settings.colorscheme = "dracula"

Vapour.plugins.user = {
  {
    'phaazon/hop.nvim',
    branch = 'v1', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
    end
  },
  {
    'junegunn/fzf.vim'
  },
  { 'junegunn/fzf',
    dir = '~/.fzf',
    run = './install --all'
  },
  {
    "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" }
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
  {
    "andymass/vim-matchup"
  },
  {
    "tpope/vim-fugitive"
  },
}

vim.opt.timeoutlen = 1000
vim.opt.updatetime = 300
vim.opt.relativenumber = true
vim.g.vscode_style = "dark"

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map('n', '<space>bb', ':Telescope buffers<CR>', opts)
map('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
map('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
map('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
map('n', '<space>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
map('n', '<space>fc', ':Telescope colorscheme<CR>', opts)
map('v', '<space>cl', ':CommentToggle<cr>', opts)
map('n', '<space>cl', ':CommentToggle<cr>', opts)

map("n", "<space><space>", ":Telescope buffers<CR>", opts)
map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>", opts)
map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>", opts)
map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>", opts)
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>", opts)
map("n", "<F3>", ":NvimTreeToggle<CR>", opts)
map("n", "<space>ft", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "<space>e", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "<space>sa", ":Ag <C-R><C-W><CR>", opts)
map("n", "<space>sr", ":Rg <C-R><C-W><CR>", opts)
map("n", "<C-n>", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)

map('n', '<space>1', '<Cmd>BufferLineGoToBuffer 1<CR>', opts)
map('n', '<space>2', '<Cmd>BufferLineGoToBuffer 2<CR>', opts)
map('n', '<space>3', '<Cmd>BufferLineGoToBuffer 3<CR>', opts)
map('n', '<space>4', '<Cmd>BufferLineGoToBuffer 4<CR>', opts)
map('n', '<space>5', '<Cmd>BufferLineGoToBuffer 5<CR>', opts)
map('n', '<space>6', '<Cmd>BufferLineGoToBuffer 6<CR>', opts)
map('n', '<space>7', '<Cmd>BufferLineGoToBuffer 7<CR>', opts)
map('n', '<space>8', '<Cmd>BufferLineGoToBuffer 8<CR>', opts)
map('n', '<space>9', '<Cmd>BufferLineGoToBuffer 9<CR>', opts)
map('n', '<space>0', '<Cmd>BufferLineGoToBuffer 10<CR>', opts)
