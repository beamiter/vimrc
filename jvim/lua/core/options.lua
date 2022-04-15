vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.opt.backspace={'indent','eol','start'}
vim.opt.completeopt={'menu','menuone','noselect'}

vim.opt.clipboard:append 'unnamedplus'
-- vim.opt.shortmess:append 'csI'

vim.opt.autoindent = true
vim.opt.colorcolumn = '120'
vim.opt.encoding= 'utf-8'
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth=4
vim.opt.showtabline=2
vim.opt.laststatus=2
vim.opt.tabstop=4
vim.opt.pumheight=10
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.list = true
vim.opt.scrolloff = 18
vim.opt.sidescrolloff = 3
--vim.opt.listchars:append("eol:↴")

vim.g.noautochdir = true
vim.g.nobackup = true
vim.g.noswapfile = true
vim.g.nowritebackup = true
vim.g.vscode_style = "dark"

