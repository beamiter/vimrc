-- Please check NvChad docs if you're totally new to nvchad + dont know lua!!
-- This is an example init file in /lua/custom/
-- this init.lua can load stuffs etc too so treat it like your ~/.config/nvim/

-- MAPPINGS
local map = require("core.utils").map

 vim.g.maplocalleader = ','
 vim.g.pumheight = 10

map("n", "<leader><leader>", ":Telescope <CR>")
map('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', {})
map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>", {})
map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>", {})
map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>", {})
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>", {})

map("n", "<leader>1", "<Cmd>BufferLineGoToBuffer  1<CR>")
map("n", "<leader>2", "<Cmd>BufferLineGoToBuffer  2<CR>")
map("n", "<leader>3", "<Cmd>BufferLineGoToBuffer  3<CR>")
map("n", "<leader>4", "<Cmd>BufferLineGoToBuffer  4<CR>")
map("n", "<leader>5", "<Cmd>BufferLineGoToBuffer  5<CR>")
map("n", "<leader>6", "<Cmd>BufferLineGoToBuffer  6<CR>")
map("n", "<leader>7", "<Cmd>BufferLineGoToBuffer  7<CR>")
map("n", "<leader>8", "<Cmd>BufferLineGoToBuffer  8<CR>")
map("n", "<leader>9", "<Cmd>BufferLineGoToBuffer  9<CR>")
map("n", "<leader>0", "<Cmd>BufferLineGoToBuffer 10<CR>")

map("n", "<localleader>1", ":<C-u>1  wincmd w<CR>")
map("n", "<localleader>2", ":<C-u>2  wincmd w<CR>")
map("n", "<localleader>3", ":<C-u>3  wincmd w<CR>")
map("n", "<localleader>4", ":<C-u>4  wincmd w<CR>")
map("n", "<localleader>5", ":<C-u>5  wincmd w<CR>")
map("n", "<localleader>6", ":<C-u>6  wincmd w<CR>")
map("n", "<localleader>7", ":<C-u>7  wincmd w<CR>")
map("n", "<localleader>8", ":<C-u>8  wincmd w<CR>")
map("n", "<localleader>9", ":<C-u>9  wincmd w<CR>")
map("n", "<localleader>0", ":<C-u>10 wincmd w<CR>")

map("n", "<F3>", ":NvimTreeToggle<CR>")
map("n", "<leader>ft", ":NvimTreeToggle<CR>")

map("n", "[g", ":Gitsigns prev_hunk<CR>")
map("n", "]g", ":Gitsigns next_hunk<CR>")

map("n", "<leader>bf", ":Neoformat<CR>")
map("n", "<leader>bb", ":Telescope buffers<CR>")


-- NOTE: the 4th argument in the map function is be a table i.e options but its most likely un-needed so dont worry about it
