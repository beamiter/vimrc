local present, plugin = pcall(require, "hop")

if not present then
  return
end

local default = {
  keys = 'etovxqpdygfblzhckisuran', jump_on_sole_occurrence = false
}

-- place this in one of your configuration file(s)
vim.api.nvim_set_keymap('n', 's', "<cmd>lua require'hop'.hint_char2()<cr>", {})
vim.api.nvim_set_keymap('n', 'S', "<cmd>lua require'hop'.hint_char1()<cr>", {})
vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
vim.api.nvim_set_keymap('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})

plugin.setup(default)
