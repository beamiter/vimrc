require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local nomap = vim.keymap.del

nomap("n", "<leader>b")
nomap("n", "<tab>")
nomap("n", "<S-tab>")

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")
map("n", "<F3>", "<cmd>NvimTreeToggle<CR>", { desc = "NvimTree Toggle window" })
map("n", "s", "<cmd>lua require'hop'.hint_char2()<CR>", { desc = "" })
map("n", "S", "<cmd>lua require'hop'.hint_char1()<CR>", { desc = "" })
map("n", "[g", ":Gitsigns prev_hunk<CR>", { desc = "prev hunk" })
map("n", "]g", ":Gitsigns next_hunk<CR>", { desc = "next hunk" })
map("n", "<leader>bj", "<cmd>BufferLinePick<CR>", { desc = "pick buffer" })
map("n", "<leader>bb", "<cmd>Telescope buffers<CR>", { desc = "show buffers" })
map("n", "<leader><leader>", "<cmd>Telescope find_files<CR>", { desc = "find files" })
map("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "buffer 1" })
map("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "buffer 2" })
map("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "buffer 3" })
map("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "buffer 4" })
map("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>", { desc = "buffer 5" })
map("n", "<leader>6", "<cmd>BufferLineGoToBuffer 6<CR>", { desc = "buffer 6" })
map("n", "<leader>7", "<cmd>BufferLineGoToBuffer 7<CR>", { desc = "buffer 7" })
map("n", "<leader>8", "<cmd>BufferLineGoToBuffer 8<CR>", { desc = "buffer 8" })
map("n", "<leader>9", "<cmd>BufferLineGoToBuffer 9<CR>", { desc = "buffer 9" })
map("n", "<leader>0", "<cmd>BufferLineGoToBuffer 10<CR>", { desc = "buffer 10" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
