local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local opt = vim.opt
local g = vim.g
g.mapleader = " "
g.maplocalleader = ","

g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.noautochdir = true
g.nobackup = true
g.noswapfile = true
g.nowritebackup = true
g.vscode_style = "dark"
g.catppuccin_flavour = "frappe" -- latte, frappe, macchiato, mocha

-- :h lua-vim-opt
-- vim.opt.guifont = { "JetBrainsMono Nerd Font Regular", ":h11.5"}
-- vim.opt.guifont = { "SauceCodePro Nerd Font Mono", ":h11.5"}

opt.autoindent = true
opt.backspace = { "indent", "eol", "start" }
opt.clipboard:append("unnamedplus")
opt.cmdheight = 1
opt.colorcolumn = "120"
opt.completeopt = { "menu", "menuone", "noselect" }
opt.cul = true
opt.encoding = "utf-8"
opt.expandtab = true
opt.fillchars = { eob = " " }
opt.hidden = true
opt.ignorecase = true
opt.laststatus = 2
opt.list = true
opt.mouse = "a"
opt.number = true
opt.numberwidth = 2
opt.pumheight = 10
opt.relativenumber = true
opt.ruler = false
opt.scrolloff = 3
-- opt.shadafile = "NONE"
opt.shiftwidth = 2
opt.showtabline = 2
opt.shortmess:append("sI")
opt.signcolumn = "yes"
opt.sidescrolloff = 3
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 4
opt.termguicolors = true
opt.title = true
opt.timeoutlen = 500
opt.updatetime = 250
opt.undofile = true
opt.whichwrap:append("<>[]hl")

-- Create autocmd
vim.api.nvim_command("autocmd FileType c,cpp setlocal shiftwidth=2")
vim.api.nvim_command("autocmd FileType c,cpp setlocal tabstop=2")

local opts = { noremap = true, silent = true }
local map = vim.api.nvim_set_keymap

map('n', '<F3>', ':NvimTreeFindFileToggle<CR>', opts)
-- map("n", "<F3>", ":Neotree toggle left reveal_force_cwd<CR>", opts)
map("n", "<F4>", ":Vista!!<CR>", opts)
-- map("n", "<C-n>", ":Neotree toggle left reveal_force_cwd<CR>", opts)
map('n', '<C-n>', ':NvimTreeFindFileToggle<CR>', opts)
map("n", "=", ":vert res +5<CR>", opts)
map("n", "-", ":vert res -5<CR>", opts)
map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)
map("n", "<leader>gj", ":Gitsigns next_hunk<CR>", opts)
map("n", "<leader>gk", ":Gitsigns prev_hunk<CR>", opts)
map("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", opts)
map("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", opts)
map("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", opts)
map("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", opts)
map("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", opts)
map("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", opts)
map("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", opts)
map("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", opts)
map("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", opts)
map("n", "<leader>0", "<Cmd>BufferLineGoToBuffer 10<CR>", opts)
map("n", "<leader>bd", ":bd<CR>", opts)
map("n", "<leader>bj", "<Cmd>BufferLinePick<CR>", opts)
map("n", "<leader>So", "<cmd>lua require('spectre').open()<CR>", {})
map("n", "<leader>Sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", {})
map("v", "<leader>S", "<cmd>lua require('spectre').open_visual()<CR>", {})
map("n", "<leader>Sp", "<cmd>lua require('spectre').open_file_search()<CR>", {})

require("lazy").setup({
	{
		"folke/neodev.nvim",
		config = function()
			-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
			require("neodev").setup({})
		end,
	},
	{
		"folke/neoconf.nvim",
		config = function()
			-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
			-- require("neoconf").setup({
			-- })
		end,
	},
	"nvim-lua/plenary.nvim",
	"lewis6991/impatient.nvim",
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},
	"dyng/ctrlsf.vim",
	"junegunn/fzf.vim",
	{ "junegunn/fzf", dir = "~/.fzf", run = "./install --all" },
	"preservim/tagbar",
	"liuchengxu/vista.vim",
	"EdenEast/nightfox.nvim",
	"lunarvim/horizon.nvim",

	{
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("indent_blankline").setup({
				show_current_context = true,
				show_current_context_start = true,
			})
		end,
	},

	"tpope/vim-fugitive",

	{ "mangeshrex/everblush.vim" },

	{ "nyoom-engineering/oxocarbon.nvim" },

	{ "jdhao/better-escape.vim", event = "InsertEnter" },

	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup()
			function _G.set_terminal_keymaps()
				vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
				vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
			end

			-- if you only want these mappings for toggle term use term://*toggleterm#* instead
			vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
		end,
	},

	{
		"numToStr/FTerm.nvim",
		config = function()
			require("FTerm").setup({
				-- border     = 'double',
				-- dimensions = {
				--   height = 0.9,
				--   width = 0.9,
				-- },
			})
			-- Example keybindings
			vim.keymap.set("n", "<F8>", '<CMD>lua require("FTerm").toggle()<CR>')
			vim.keymap.set("t", "<F8>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
		end,
	},

	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({})
			-- Toggle using count
			vim.keymap.set(
				"n",
				"<leader>cl",
				"v:count == 0 ? '<Plug>(comment_toggle_current_linewise)' : '<Plug>(comment_toggle_linewise_count)'",
				{ expr = true, remap = true }
			)
			-- Toggle in VISUAL mode
			vim.keymap.set("x", "<leader>cl", "<Plug>(comment_toggle_linewise_visual)")
		end,
	},

	"nvim-treesitter/nvim-treesitter-textobjects",
	{
		"nvim-treesitter/nvim-treesitter",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- A list of parser names, or "all" (the four listed parsers should always be installed)
				ensure_installed = { "c", "lua", "vim", "help", "rust", "cpp", "julia" },
				sync_install = false,
				auto_install = true,
				highlight = {
					-- `false` will disable the whole extension
					enable = true,
					disable = {},
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},

	"marko-cerovac/material.nvim",
	"luisiacc/gruvbox-baby",
	"folke/tokyonight.nvim",
	"AlphaTechnolog/onedarker.nvim",
	"rebelot/kanagawa.nvim",
	"tomasiser/vim-code-dark",
	"Mofiqul/vscode.nvim",
	"srcery-colors/srcery-vim",
	"sainnhe/gruvbox-material",
	"luisiacc/gruvbox-baby",
	"sainnhe/everforest",
	"sainnhe/edge",
	"felipec/vim-felipec",
	{
		"sainnhe/sonokai",
		config = function()
			vim.g.sonokai_style = "shusia"
			vim.g.sonokai_better_performance = 1
		end,
	},
	{
		"catppuccin/nvim",
		as = "catppuccin",
	},
	{
		"rose-pine/neovim",
		as = "rose-pine",
		config = function()
			-- vim.cmd('colorscheme rose-pine')
		end,
	},
	{
		-- "simrat39/rust-tools.nvim",
		-- config = function()
		-- 	require("rust-tools").setup()
		-- end,
	},

	{
		"mfussenegger/nvim-dap",
		config = function()
			vim.api.nvim_set_keymap("n", "<F5>", "<cmd>lua require'dap'.continue()<cr>", {})
			vim.api.nvim_set_keymap("n", "<F9>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", {})
			vim.api.nvim_set_keymap("n", "<F10>", "<cmd>lua require'dap'.step_over()<cr>", {})
			vim.api.nvim_set_keymap("n", "<F11>", "<cmd>lua require'dap'.step_into()<cr>", {})
			vim.api.nvim_set_keymap("n", "<S-F11>", "<cmd>lua require'dap'.step_out()<cr>", {})

			local dap = require("dap")
			dap.adapters.cppdbg = {
				id = "cppdbg",
				type = "executable",
				-- must be absolute path
				command = "/home/yinj3/.vscode/extensions/ms-vscode.cpptools-1.9.8-linux-x64/debugAdapters/bin/OpenDebugAD7",
			}
			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "cppdbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
					setupCommands = {
						{
							text = "-enable-pretty-printing",
							description = "enable pretty printing",
							ignoreFailures = false,
						},
					},
				},
			}
		end,
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		config = function()
			require("nvim-dap-virtual-text").setup()
		end,
	},
	{
		"stevearc/dressing.nvim",
		config = function()
			require("dressing").setup()
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		config = function()
			require("dapui").setup()
			local dap, dapui = require("dap"), require("dapui")
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
			-- " for normal mode - the word under the cursor
			-- nmap <Leader>di <Plug>VimspectorBalloonEval
			vim.api.nvim_set_keymap("n", "<leader>di", "<cmd>lua require'dapui'.eval()<cr>", {})
			-- " for visual mode, the visually selected text
			vim.api.nvim_set_keymap("v", "<leader>di", "<cmd>lua require'dapui'.eval()<cr>", {})
		end,
	},

	"bluz71/vim-moonfly-colors",
	"bluz71/vim-nightfly-guicolors",

	"cljoly/telescope-repo.nvim",
	{
		"nvim-telescope/telescope.nvim",
		config = function()
			local actions = require("telescope.actions")
			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next,
							["<C-n>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-p>"] = actions.move_selection_previous,
						},
					},
				},
			})
		end,
	},

	"ntpeters/vim-better-whitespace",
	"mhinz/vim-grepper",
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.dashboard").config)
		end,
	},
	{
		"windwp/nvim-spectre",
		config = function()
			require("spectre").setup()
		end,
	},

	-- Use this instead of hop
	{
		"ggandor/flit.nvim",
		dependencies = { "ggandor/leap.nvim" },
		config = function()
			require("flit").setup()
		end,
	},
	{
		"ggandor/leap.nvim",
		config = function()
			require("leap").add_default_mappings()
		end,
	},

	-- {
	--   "phaazon/hop.nvim",
	--   config = function()
	--     require("hop").setup({ keys = "etovxqpdygfblzhckisuran", jump_on_sole_occurrence = false })
	--     -- place this in one of your configuration file(s)
	--     vim.api.nvim_set_keymap("n", "s", "<cmd>lua require'hop'.hint_char2()<cr>", {})
	--     vim.api.nvim_set_keymap("n", "S", "<cmd>lua require'hop'.hint_char1()<cr>", {})
	--     vim.api.nvim_set_keymap("n", "f", "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
	--     vim.api.nvim_set_keymap("n", "F", "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
	--   end,
	-- },

	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- require('lualine').setup {
			--   options = { theme = 'dracula' }
			-- }
		end,
	},
	{
		"feline-nvim/feline.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- require('feline').setup()
		end,
	},
	{
		"NTBBloodbath/galaxyline.nvim",
		-- your statusline
		config = function()
			require("galaxyline.themes.eviline")
		end,
		-- some optional icons
		dependencies = { "nvim-tree/nvim-web-devicons", opt = true },
	},

	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup()
		end,
	},
    {
        "rcarriga/nvim-notify",
		config = function()
			require("notify").setup()
		end,
    },
	{
		"karb94/neoscroll.nvim",
		config = function()
			-- require("neoscroll").setup({})
		end,
	},
	"SmiteshP/nvim-navic",
	{ "echasnovski/mini.nvim", version = false },
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
      },
      config = function()
        require("nvim-tree").setup({
          sort_by = "case_sensitive",
          renderer = {
            group_empty = true,
          },
          filters = {
            dotfiles = true,
          },
        })
      end,
    },

	{ "andymass/vim-matchup", event = "VimEnter" },

	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitsigns").setup()
		end,
	},

	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup()
			local wk = require("which-key")
			wk.register({
				w = {
					name = "window", -- optional group name
					w = { "<C-w>w", "other-window" },
					d = { "<C-W>c", "delete-window" },
					["2"] = { "<C-W>v", "layout-double-columns" },
					h = { "<C-W>h", "window-left" },
					j = { "<C-W>j", "window-below" },
					l = { "<C-W>l", "window-right" },
					k = { "<C-W>k", "window-up" },
					o = { "<C-W>o", "window-only" },
					H = { "<C-W>5<", "expand-window-left" },
					J = { ":resize +5", "expand-window-below" },
					L = { "<C-W>5>", "expand-window-right" },
					K = { ":resize -5", "expand-window-up" },
					["="] = { "<C-W>=", "balance-window" },
					s = { "<C-W>s", "split-window-below" },
					v = { "<C-W>v", "split-window-right" },
				},
				f = {
					name = "files",
					t = { ":NvimTreeFindFileToggle<CR>", "tree toggle" },
					f = { ":Telescope find_files<CR>", "files" },
					w = { ":Telescope live_grep<CR>", "live_grep" },
					b = { ":Telescope buffers<CR>", "buffers" },
					h = { ":Telescope oldfiles<CR>", "oldfiles" },
					r = { ":Telescope oldfiles<CR>", "oldfiles" },
				},
				s = {
					name = "search",
					t = { ":Telescope live_grep<CR>", "live_grep" },
					g = { ":Telescope grep_string<CR>", "grep_string" },
					a = { ":Ag <C-R><C-W><CR>", "ag current" },
					r = { ":Rg <C-R><C-W><CR>", "rg current" },
				},
				b = {
					name = "buffers",
					b = { ":Telescope buffers<CR>", "buffers" },
				},
				L = { ":Lazy<CR>", "lazy" },
			}, { prefix = "<leader>" })
		end,
	},

	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/cmp-vsnip",
	"hrsh7th/vim-vsnip",
	{ "rafamadriz/friendly-snippets" },
	"RRethy/vim-illuminate",

	{
		"L3MON4D3/LuaSnip",
		config = function()
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},

	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "lua_ls", "rust_analyzer" },
			})
		end,
	},

	{
		"hrsh7th/nvim-cmp",
		config = function()
			-- Setup nvim-cmp.
			local cmp = require("cmp")
			local default = {
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				formatting = {
					format = function(entry, vim_item)
						vim_item.menu = ({
							nvim_lsp = "[LSP]",
							nvim_lua = "[Lua]",
							buffer = "[BUF]",
						})[entry.source.name]
						return vim_item
					end,
				},
				mapping = {
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-k>"] = cmp.mapping.select_prev_item(),
					["<C-j>"] = cmp.mapping.select_next_item(),
					["<UP>"] = cmp.mapping.select_prev_item(),
					["<Down>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-y>"] = cmp.config.disable,
					["<C-e>"] = cmp.mapping({
						i = cmp.mapping.abort(),
						c = cmp.mapping.close(),
					}),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif require("luasnip").expand_or_jumpable() then
							vim.fn.feedkeys(
								vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true),
								""
							)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif require("luasnip").jumpable(-1) then
							vim.fn.feedkeys(
								vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true),
								""
							)
						else
							fallback()
						end
					end, { "i", "s" }),
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "nvim_lua" },
					{ name = "path" },
				},
			}

			cmp.setup(default)
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = { "SmiteshP/nvim-navic" },
		config = function()
			vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, opts)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
			vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

			-- Use an on_attach function to only map the following keys
			-- after the language server attaches to the current buffer
			local on_attach = function(client, bufnr)
				-- Enable completion triggered by <c-x><c-o>
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- Mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				-- local bufopts = { noremap=true, silent=true, buffer=bufnr }
				vim.keymap.set(
					"n",
					"gD",
					vim.lsp.buf.declaration,
					{ noremap = true, silent = true, buffer = bufnr, desc = "declaration" }
				)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
					noremap = true,
					silent = true,
					buffer = bufnr,
					desc = "definition",
				})
				vim.keymap.set(
					"n",
					"K",
					vim.lsp.buf.hover,
					{ noremap = true, silent = true, buffer = bufnr, desc = "hover" }
				)
				vim.keymap.set(
					"n",
					"gi",
					vim.lsp.buf.implementation,
					{ noremap = true, silent = true, buffer = bufnr, desc = "implementation" }
				)
				vim.keymap.set(
					"n",
					"<C-k>",
					vim.lsp.buf.signature_help,
					{ noremap = true, silent = true, buffer = bufnr, desc = "signature_help" }
				)
				vim.keymap.set(
					"n",
					"<space>wa",
					vim.lsp.buf.add_workspace_folder,
					{ noremap = true, silent = true, buffer = bufnr, desc = "add_workspace_folder" }
				)
				vim.keymap.set(
					"n",
					"<space>wr",
					vim.lsp.buf.remove_workspace_folder,
					{ noremap = true, silent = true, buffer = bufnr, desc = "remove_workspace_folder" }
				)
				vim.keymap.set("n", "<space>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, { noremap = true, silent = true, buffer = bufnr, desc = "list_workspace_folders" })
				vim.keymap.set(
					"n",
					"<space>D",
					vim.lsp.buf.type_definition,
					{ noremap = true, silent = true, buffer = bufnr, desc = "type_definition" }
				)
				vim.keymap.set(
					"n",
					"<space>rn",
					vim.lsp.buf.rename,
					{ noremap = true, silent = true, buffer = bufnr, desc = "rename" }
				)
				vim.keymap.set(
					"n",
					"<space>ca",
					vim.lsp.buf.code_action,
					{ noremap = true, silent = true, buffer = bufnr, desc = "code_action" }
				)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, {
					noremap = true,
					silent = true,
					buffer = bufnr,
					desc = "references",
				})
				vim.keymap.set({ "n", "x", "v" }, "<space>fm", function()
					vim.lsp.buf.format({ async = true })
				end, { noremap = true, silent = true, buffer = bufnr, desc = "format" })
				local navic = require("nvim-navic")
				if client.server_capabilities.documentSymbolProvider then
					navic.attach(client, bufnr)
				end
			end

			require("mason-lspconfig").setup_handlers({
				-- The first entry (without a key) will be the default handler
				-- and will be called for each installed server that doesn't have
				-- a dedicated handler.
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({
						on_attach = on_attach,
					})
				end,
			})

			-- diagnostic config
			-- local config = {
			--   virtual_text = true,
			-- }
			-- vim.diagnostic.config(config)
		end,
	},

	{ "dracula/vim", as = "dracula" },
})

vim.cmd([[
colorscheme vscode
filetype off
syntax on
]])
