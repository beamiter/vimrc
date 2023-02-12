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

-- map('n', '<F3>', ':NvimTreeFindFileToggle<CR>', opts)
map("n", "<F3>", ":Neotree toggle left reveal_force_cwd<CR>", opts)
map("n", "<F4>", ":Vista!!<CR>", opts)
map("n", "<C-n>", ":Neotree toggle left reveal_force_cwd<CR>", opts)
-- map('n', '<C-n>', ':NvimTreeFindFileToggle<CR>', opts)
map("n", "=", ":vert res +5<CR>", opts)
map("n", "-", ":vert res -5<CR>", opts)
map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)
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
map("n", "<leader>So", "<cmd>lua require('spectre').open()<CR>", {})
map("n", "<leader>Sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", {})
map("v", "<leader>S", "<cmd>lua require('spectre').open_visual()<CR>", {})
map("n", "<leader>Sp", "<cmd>lua require('spectre').open_file_search()<CR>", {})

require("lazy").setup({
    -- Packer can manage itself
    "wbthomason/packer.nvim",
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
    { "junegunn/fzf",                    dir = "~/.fzf",       run = "./install --all" },
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

    { "jdhao/better-escape.vim",         event = "InsertEnter" },

    {
        "akinsho/toggleterm.nvim",
        config = function()
          require("toggleterm").setup()
          function _G.set_terminal_keymaps()
            local opts = { noremap = true }
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

    { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },

    "marko-cerovac/material.nvim",
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
        -- tag = 'v1.*',
        config = function()
          -- vim.cmd('colorscheme rose-pine')
        end,
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
    "mhinz/vim-startify",
    {
        "windwp/nvim-spectre",
        config = function()
          require("spectre").setup()
        end,
    },

    {
        "phaazon/hop.nvim",
        config = function()
          require("hop").setup({ keys = "etovxqpdygfblzhckisuran", jump_on_sole_occurrence = false })
          -- place this in one of your configuration file(s)
          vim.api.nvim_set_keymap("n", "s", "<cmd>lua require'hop'.hint_char2()<cr>", {})
          vim.api.nvim_set_keymap("n", "S", "<cmd>lua require'hop'.hint_char1()<cr>", {})
          vim.api.nvim_set_keymap("n", "f", "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
          vim.api.nvim_set_keymap("n", "F", "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
        end,
    },

    "kyazdani42/nvim-web-devicons",

    {
        "nvim-lualine/lualine.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
          -- require('lualine').setup {
          --   options = { theme = 'dracula' }
          -- }
        end,
    },
    {
        "feline-nvim/feline.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
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
        dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
    },

    {
        "akinsho/bufferline.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
          require("bufferline").setup({})
        end,
    },

    -- Unless you are still migrating, remove the deprecated commands from v1.x
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            {
                -- only needed if you want to use the commands with "_with_window_picker" suffix
                "s1n7ax/nvim-window-picker",
                tag = "1.*",
                config = function()
                  require("window-picker").setup({
                      autoselect_one = true,
                      include_current = false,
                      filter_rules = {
                          -- filter using buffer options
                          bo = {
                              -- if the file type is one of following, the window will be ignored
                              filetype = { "neo-tree", "neo-tree-popup", "notify", "quickfix" },

                              -- if the buffer type is one of following, the window will be ignored
                              buftype = { "terminal" },
                          },
                      },
                      other_win_hl_color = "#e35e4f",
                  })
                end,
            },
        },
        config = function()
          -- Unless you are still migrating, remove the deprecated commands from v1.x
          vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

          -- If you want icons for diagnostic errors, you'll need to define them somewhere:
          vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
          vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
          vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
          vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
          -- NOTE: this is changed from v1.x, which used the old style of highlight groups
          -- in the form "LspDiagnosticsSignWarning"

          require("neo-tree").setup({
              close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
              popup_border_style = "rounded",
              enable_git_status = true,
              enable_diagnostics = true,
              sort_case_insensitive = false, -- used when sorting files and directories in the tree
              sort_function = nil, -- use a custom function for sorting files and directories in the tree
              -- sort_function = function (a,b)
              --       if a.type == b.type then
              --           return a.path > b.path
              --       else
              --           return a.type > b.type
              --       end
              --   end , -- this sorts files and directories descendantly
              default_component_configs = {
                  container = {
                      enable_character_fade = true,
                  },
                  indent = {
                      indent_size = 2,
                      padding = 1, -- extra padding on left hand side
                      -- indent guides
                      with_markers = true,
                      indent_marker = "│",
                      last_indent_marker = "└",
                      highlight = "NeoTreeIndentMarker",
                      -- expander config, needed for nesting files
                      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
                      expander_collapsed = "",
                      expander_expanded = "",
                      expander_highlight = "NeoTreeExpander",
                  },
                  icon = {
                      folder_closed = "",
                      folder_open = "",
                      folder_empty = "ﰊ",
                      -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
                      -- then these will never be used.
                      default = "*",
                      highlight = "NeoTreeFileIcon",
                  },
                  modified = {
                      symbol = "[+]",
                      highlight = "NeoTreeModified",
                  },
                  name = {
                      trailing_slash = false,
                      use_git_status_colors = true,
                      highlight = "NeoTreeFileName",
                  },
                  git_status = {
                      symbols = {
                          -- Change type
                          added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                          modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
                          deleted = "✖", -- this can only be used in the git_status source
                          renamed = "", -- this can only be used in the git_status source
                          -- Status type
                          untracked = "",
                          ignored = "",
                          unstaged = "",
                          staged = "",
                          conflict = "",
                      },
                  },
              },
              window = {
                  position = "left",
                  width = 40,
                  mapping_options = {
                      noremap = true,
                      nowait = true,
                  },
                  mappings = {
                      ["<space>"] = {
                          "toggle_node",
                          nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
                      },
                      ["<2-LeftMouse>"] = "open",
                      ["<cr>"] = "open",
                      ["S"] = "open_split",
                      ["s"] = "open_vsplit",
                      -- ["S"] = "split_with_window_picker",
                      -- ["s"] = "vsplit_with_window_picker",
                      ["t"] = "open_tabnew",
                      ["w"] = "open_with_window_picker",
                      ["C"] = "close_node",
                      ["a"] = {
                          "add",
                          -- some commands may take optional config options, see `:h neo-tree-mappings` for details
                          config = {
                              show_path = "none", -- "none", "relative", "absolute"
                          },
                      },
                      ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add".
                      ["d"] = "delete",
                      ["r"] = "rename",
                      ["y"] = "copy_to_clipboard",
                      ["x"] = "cut_to_clipboard",
                      ["p"] = "paste_from_clipboard",
                      ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
                      -- ["c"] = {
                      --  "copy",
                      --  config = {
                      --    show_path = "none" -- "none", "relative", "absolute"
                      --  }
                      --}
                      ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
                      ["q"] = "close_window",
                      ["R"] = "refresh",
                      ["?"] = "show_help",
                  },
              },
              nesting_rules = {},
              filesystem = {
                  filtered_items = {
                      visible = false, -- when true, they will just be displayed differently than normal items
                      hide_dotfiles = true,
                      hide_gitignored = true,
                      hide_hidden = true, -- only works on Windows for hidden files/directories
                      hide_by_name = {
                          --"node_modules"
                      },
                      hide_by_pattern = { -- uses glob style patterns
                          --"*.meta"
                      },
                      never_show = { -- remains hidden even if visible is toggled to true
                          --".DS_Store",
                          --"thumbs.db"
                      },
                  },
                  follow_current_file = false, -- This will find and focus the file in the active buffer every
                  -- time the current file is changed while the tree is open.
                  group_empty_dirs = false, -- when true, empty folders will be grouped together
                  hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                  -- in whatever position is specified in window.position
                  -- "open_current",  -- netrw disabled, opening a directory opens within the
                  -- window like netrw would, regardless of window.position
                  -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                  use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                  -- instead of relying on nvim autocmd events.
                  window = {
                      mappings = {
                          ["<bs>"] = "navigate_up",
                          ["."] = "set_root",
                          ["H"] = "toggle_hidden",
                          ["/"] = "fuzzy_finder",
                          ["f"] = "filter_on_submit",
                          ["<c-x>"] = "clear_filter",
                          ["[g"] = "prev_git_modified",
                          ["]g"] = "next_git_modified",
                      },
                  },
              },
              buffers = {
                  follow_current_file = true, -- This will find and focus the file in the active buffer every
                  -- time the current file is changed while the tree is open.
                  group_empty_dirs = true, -- when true, empty folders will be grouped together
                  show_unloaded = true,
                  window = {
                      mappings = {
                          ["bd"] = "buffer_delete",
                          ["<bs>"] = "navigate_up",
                          ["."] = "set_root",
                      },
                  },
              },
              git_status = {
                  window = {
                      position = "float",
                      mappings = {
                          ["A"] = "git_add_all",
                          ["gu"] = "git_unstage_file",
                          ["ga"] = "git_add_file",
                          ["gr"] = "git_revert_file",
                          ["gc"] = "git_commit",
                          ["gp"] = "git_push",
                          ["gg"] = "git_commit_and_push",
                      },
                  },
              },
          })

          vim.cmd([[nnoremap \ :Neotree reveal<cr>]])
        end,
    },

    {
        "kyazdani42/nvim-tree.lua",
        config = function()
          -- require("nvim-tree").setup({
          --   respect_buf_cwd = true,
          --   update_cwd = true,
          --   update_focused_file = {
          --     enable = true,
          --     update_cwd = true
          --   },
          -- })
        end,
    },

    { "andymass/vim-matchup",            event = "VimEnter" },

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
                  t = { ":Neotree toggle left reveal_force_cwd<CR>", "tree toggle" },
                  f = { ":Telescope find_files<CR>", "files" },
                  w = { ":Telescope live_grep<CR>", "live_grep" },
                  b = { ":Telescope buffers<CR>", "buffers" },
                  h = { ":Telescope oldfiles<CR>", "oldfiles" },
                  r = { ":Telescope oldfiles<CR>", "oldfiles" },
              },
              s = {
                  name = "search",
                  g = { ":Telescope grep_string<CR>", "grep_string" },
                  a = { ":Ag <C-R><C-W><CR>", "ag current" },
                  r = { ":Rg <C-R><C-W><CR>", "rg current" },
              },
              b = {
                  name = "buffers",
                  f = { ":Neoformat<CR>", "format" },
                  b = { ":Telescope buffers<CR>", "buffers" },
              },
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

    "williamboman/nvim-lsp-installer",

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
                  ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs( -4), { "i", "c" }),
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
                    elseif require("luasnip").jumpable( -1) then
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
        config = function()
          -- Mappings.
          local map = vim.api.nvim_set_keymap
          local buf_map = vim.api.nvim_buf_set_keymap
          local opts = { noremap = true, silent = true }
          map("n", "<space>e", ":Neotree toggle left reveal_force_cwd<CR>", opts)
          map("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
          map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
          map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
          map("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
          local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            -- Mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            buf_map(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
            buf_map(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
            buf_map(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
            buf_map(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
            buf_map(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
            buf_map(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
            buf_map(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
            buf_map(
                bufnr,
                "n",
                "<space>wl",
                "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
                opts
            )
            buf_map(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
            buf_map(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
            buf_map(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
            buf_map(bufnr, "n", "<space>ac", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
            buf_map(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
            buf_map(bufnr, "n", "<space>fm", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
            buf_map(bufnr, "x", "<space>fm", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
            buf_map(bufnr, "x", "<space>bf", "<cmd>lua vim.lsp.buf.format()<CR>", opts)

            require("illuminate").on_attach(client)
          end

          local capabilities = vim.lsp.protocol.make_client_capabilities()
          capabilities.textDocument.completion.completionItem.documentationFormat = { "markdown", "plaintext" }
          capabilities.textDocument.completion.completionItem.snippetSupport = true
          capabilities.textDocument.completion.completionItem.preselectSupport = true
          capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
          capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
          capabilities.textDocument.completion.completionItem.deprecatedSupport = true
          capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
          capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
          capabilities.textDocument.completion.completionItem.resolveSupport = {
              properties = {
                  "documentation",
                  "detail",
                  "additionalTextEdits",
              },
          }
          capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

          local lsp_installer = require("nvim-lsp-installer")
          lsp_installer.settings({
              ui = {
                  icons = {
                      server_installed = "﫟",
                      server_pending = "",
                      server_uninstalled = "✗",
                  },
              },
          })

          lsp_installer.on_server_ready(function(server)
            local server_opts = {
                on_attach = on_attach,
                capabilities = capabilities,
                flags = {
                    debounce_text_changes = 150,
                },
                settings = {},
            }

            -- basic example to edit lsp server's options, disabling tsserver's inbuilt formatter
            if server.name == "tsserver" then
              server_opts.on_attach = function(client, bufnr)
                client.resolved_capabilities.document_formatting = false
                vim.api.nvim_buf_set_keymap(
                    bufnr,
                    "n",
                    "<space>fm",
                    "<cmd>lua vim.lsp.buf.formatting()<CR>",
                    {}
                )
              end
            end

            server:setup(server_opts)

            vim.cmd([[ do User LspAttachBuffers ]])
          end)

          -- diagnostic config
          -- local config = {
          --   virtual_text = true,
          -- }
          -- vim.diagnostic.config(config)
        end,
    },

    { "dracula/vim",                 as = "dracula" },

})

vim.cmd([[
colorscheme tokyonight
filetype off
syntax on
]])
