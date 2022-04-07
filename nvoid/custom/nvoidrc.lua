-- Key map
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
map("n", "<leader><leader>", ":Telescope <CR>", opts)
map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>", opts)
map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>", opts)
map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>", opts)
map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>", opts)

map("n", "<F3>", ":NvimTreeToggle<CR>", opts)
--map("n", "<leader>ft", ":NvimTreeToggle<CR>", opts)

map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)

vim.diagnostic.config({virtual_txt = false})

local M = {}

-- UI
M.ui = {
	theme = "catppuccin", -- "catppuccin" "classic-dark" "nord" "onedark" "solarized" "tokyodark" "uwu"
	transparency = false,
	statusline = "nvoid", -- "lunarvim" "nvchad" "nvoid" "minimal"
}

-- Options
M.options = {
	clipboard = "unnamedplus",
	cmdheight = 1,
	mouse = "a",
	mapleader = " ",
	wrap = false,
	number = true,
	relative_number = true,
	number_width = 6,
	cursor_line = true,
	hidden = true,
	expand_tab = true,
	ignore_case = true,
	smart_case = true,
	smart_indent = true,
	swap_file = false,
	backup = false,
	show_mode = false,
    --timeoutlen = 800,
}

-- Add lsp
M.lsp_add = {} -- "bashls",

-- Add treesitter language
M.ts_add = {} -- "all", "fish"

-- Add Plugins
M.plugins_add = {
	{ "folke/zen-mode.nvim" },
    {
       'phaazon/hop.nvim',
       branch = 'v1', -- optional but strongly recommended
       config = function()
         -- you can configure Hop the way you like here; see :h hop-config
         require'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
       end
    },
}

-- Add new whichkey bind
M.whichkey_add = {
	-- ["z"] = { "<cmd>ZenMode<cr>", "ZenMode" },
	["bb"] = { ":Telescope buffers<cr>", "buffers" },
	["sg"] = { ":Telescope live_grep<cr>", "live grep" },
}

return M
