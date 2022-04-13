-- Override Cosmic editor options

local g = vim.g
local map = require('cosmic.utils').map
local opt = vim.opt

-- Default leader is <space>
--g.mapleader = ','

-- Default indent = 2
--opt.shiftwidth = 4
--opt.softtabstop = 4
--opt.tabstop = 4

-- Add additional keymaps or disable existing ones
-- To view maps set, use `:Telescope keymaps`
-- or `:map`, `:map <leader>`

-- Example: Additional insert mapping:
--map('i', 'jj', '<esc>', { noremap = true, silent = true })
local opts = { noremap = true, silent = true }
map("n", "<leader><leader>", ":Telescope buffers<CR>", opts)
map("n", "<leader>fh", ":Telescope oldfiles<CR>", opts)
map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>", opts)
map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>", opts)
map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>", opts)
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>", opts)

map("n", "<F3>", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "<leader>ft", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "<C-n>", ":NvimTreeFindFileToggle<CR>", opts)

map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)

-- Mapping options:
-- map('n', ...)
-- map('v', ...)
-- map('i', ...)
-- map('t', ...)

-- Example: Disable find files keymap
-- local cmd = vim.cmd
-- cmd('unmap <leader>f')
