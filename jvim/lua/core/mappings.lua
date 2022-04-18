local opts = { noremap=true, silent=true }
local map = vim.api.nvim_set_keymap

map('n', '<F3>', ':NvimTreeFindFileToggle<CR>', opts)
map('n', '[g', ':Gitsigns prev_hunk<CR>', opts)
map('n', ']g', ':Gitsigns next_hunk<CR>', opts)
map('n', '<leader>1', '<Cmd>BufferLineGoToBuffer 1<CR>', opts)
map('n', '<leader>2', '<Cmd>BufferLineGoToBuffer 2<CR>', opts)
map('n', '<leader>3', '<Cmd>BufferLineGoToBuffer 3<CR>', opts)
map('n', '<leader>4', '<Cmd>BufferLineGoToBuffer 4<CR>', opts)
map('n', '<leader>5', '<Cmd>BufferLineGoToBuffer 5<CR>', opts)
map('n', '<leader>6', '<Cmd>BufferLineGoToBuffer 6<CR>', opts)
map('n', '<leader>7', '<Cmd>BufferLineGoToBuffer 7<CR>', opts)
map('n', '<leader>8', '<Cmd>BufferLineGoToBuffer 8<CR>', opts)
map('n', '<leader>9', '<Cmd>BufferLineGoToBuffer 9<CR>', opts)
map("n", "<C-n>", ":NvimTreeFindFileToggle<CR>", opts)

local opt = { expr = true, remap = true }
-- Toggle using count
vim.keymap.set('n', '<leader>cl', "v:count == 0 ? '<Plug>(comment_toggle_current_linewise)' : '<Plug>(comment_toggle_linewise_count)'", opt)
-- Toggle in VISUAL mode
vim.keymap.set('x', '<leader>cl', '<Plug>(comment_toggle_linewise_visual)')
