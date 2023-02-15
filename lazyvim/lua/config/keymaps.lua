-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<F3>", ":Neotree toggle left reveal_force_cwd<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>0", "<Cmd>BufferLineGoToBuffer 10<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fr", ":Telescope oldfiles<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>bf", ":Telescope buffers<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>sg", ":Telescope grep_string<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>sw", ":Telescope live_grep<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>gj", ":Gitsigns next_hunk<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>gk", ":Gitsigns prev_hunk<CR>", { noremap = true, silent = true })
