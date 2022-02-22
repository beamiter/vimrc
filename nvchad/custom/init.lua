-- Please check NvChad docs if you're totally new to nvchad + dont know lua!!
-- This is an example init file in /lua/custom/
-- this init.lua can load stuffs etc too so treat it like your ~/.config/nvim/

-- MAPPINGS
local map = require("core.utils").map

map("n", "<leader><leader>", ":Telescope <CR>")
map("n", "<leader>q", ":q <CR>")
map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>", {})
map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>", {})
map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>", {})
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>", {})
map("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>")
map("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>")
map("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>")
map("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>")
map("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>")
map("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>")
map("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>")
map("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>")
map("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>")


-- NOTE: the 4th argument in the map function is be a table i.e options but its most likely un-needed so dont worry about it
