-- Create autocmd
vim.api.nvim_command('autocmd FileType c,cpp setlocal shiftwidth=2')
vim.api.nvim_command('autocmd FileType c,cpp setlocal tabstop=2')

vim.cmd("autocmd FileType qf nnoremap <buffer><silent> <CR> <CR> :cclose<CR>")
vim.cmd [[
colorscheme vscode
filetype off
syntax on
]]

