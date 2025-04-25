-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set
for i = 1, 9 do
  map("n", "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>")
end
map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", { desc = "Pick Buffer" })

map("n", "<leader>0", "<Cmd>BufferLineGoToBuffer 10<CR>")
map("n", ")", ":vert res +5<CR>")
map("n", "(", ":vert res -5<CR>")
map("n", "<C-Right>", ":vert res +5<CR>")
map("n", "<C-Left>", ":vert res -5<CR>")

-- 复制文件路径相关快捷键
-- 首先为 <leader>y 创建一个组
vim.keymap.set("n", "<leader>y", "<nop>", { desc = "+Copy Path" })
-- 复制完整路径
map('n', '<leader>yp', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('"', path)
  vim.notify('Copied full path: ' .. path)
end, { desc = 'Copy full file path' })

-- 复制相对路径
map('n', '<leader>yr', function()
  local path = vim.fn.expand('%')
  vim.fn.setreg('"', path)
  vim.notify('Copied relative path: ' .. path)
end, { desc = 'Copy relative file path' })

-- 复制文件名
map('n', '<leader>yf', function()
  local path = vim.fn.expand('%:t')
  vim.fn.setreg('"', path)
  vim.notify('Copied filename: ' .. path)
end, { desc = 'Copy filename' })

-- 复制文件目录路径
map('n', '<leader>yd', function()
  local path = vim.fn.expand('%:p:h')
  vim.fn.setreg('"', path)
  vim.notify('Copied directory path: ' .. path)
end, { desc = 'Copy directory path' })
