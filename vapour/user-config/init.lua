Vapour.plugins.treesitter.ensure_installed = ""
Vapour.settings.colorscheme = "dracula"

vim.o.timeoutlen = 1000
vim.o.updatetime = 300

local opts = {noremap = true, silent = true}
vim.api.nvim_set_keymap('n', 'bb', ':Telescope buffers<CR>', opts)
vim.api.nvim_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.api.nvim_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>fm', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
