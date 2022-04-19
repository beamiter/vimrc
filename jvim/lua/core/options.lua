local opt = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = ','
g.noautochdir = true
g.nobackup = true
g.noswapfile = true
g.nowritebackup = true
g.vscode_style = "dark"

opt.autoindent = true
opt.backspace={'indent','eol','start'}
opt.clipboard:append 'unnamedplus'
opt.cmdheight = 1
opt.colorcolumn = '120'
opt.completeopt={'menu','menuone','noselect'}
opt.cul = true
opt.encoding= 'utf-8'
opt.expandtab = true
opt.fillchars = { eob = " " }
opt.hidden = true
opt.ignorecase = true
opt.laststatus=2
opt.list = true
opt.mouse = "a"
opt.number = true
opt.numberwidth = 2
opt.pumheight=10
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 3
opt.shadafile = "NONE"
opt.shiftwidth=2
opt.showtabline=2
opt.shortmess:append "sI"
opt.signcolumn = 'yes'
opt.sidescrolloff = 3
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop=4
opt.termguicolors = true
opt.title = true
opt.timeoutlen = 800
opt.updatetime = 250
opt.undofile = true
opt.whichwrap:append "<>[]hl"
