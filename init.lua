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
-- vim.go.background = "light"
vim.go.background = "dark"

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

map("n", "<F3>", ":NvimTreeFindFileToggle<CR>", opts)
-- map("n", "<F3>", ":Neotree toggle left reveal_force_cwd<CR>", opts)
-- map("n", "<C-n>", ":Neotree toggle left reveal_force_cwd<CR>", opts)
map("n", "<C-n>", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "=", ":vert res +5<CR>", opts)
map("n", "-", ":vert res -5<CR>", opts)
map("n", "<C-Right>", ":vert res +5<CR>", opts)
map("n", "<C-Left>", ":vert res -5<CR>", opts)
map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)
map("n", "<leader><leader>", ":Telescope find_files<CR>", opts)
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
map("n", "<localleader>1", ":<C-u>1 wincmd w<CR>", opts)
map("n", "<localleader>2", ":<C-u>2 wincmd w<CR>", opts)
map("n", "<localleader>3", ":<C-u>3 wincmd w<CR>", opts)
map("n", "<localleader>4", ":<C-u>4 wincmd w<CR>", opts)
map("n", "<localleader>5", ":<C-u>5 wincmd w<CR>", opts)
map("n", "<localleader>6", ":<C-u>6 wincmd w<CR>", opts)
map("n", "<localleader>7", ":<C-u>7 wincmd w<CR>", opts)
map("n", "<localleader>8", ":<C-u>8 wincmd w<CR>", opts)
map("n", "<localleader>9", ":<C-u>9 wincmd w<CR>", opts)
map("n", "<localleader>0", ":<C-u>10 wincmd w<CR>", opts)
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
  { "nvim-lua/plenary.nvim", cmd = { "PlenaryBustedFile", "PlenaryBustedDirectory" }, lazy = true },
  "lewis6991/impatient.nvim",
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
  "dyng/ctrlsf.vim",
  "junegunn/fzf.vim",
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({})
    end
  },
  { "junegunn/fzf",          dir = "~/.fzf",                                          run = "./install --all" },
  "preservim/tagbar",
  "EdenEast/nightfox.nvim",
  "lunarvim/horizon.nvim",

  {
    "j-hui/fidget.nvim",
    opts = {
      -- options
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { char = "│" },
    },
    config = function(_, opts0)
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require("ibl").setup(opts0)
    end,
  },
  { "nvim-neotest/nvim-nio" },

  "tpope/vim-fugitive",

  { "mangeshrex/everblush.vim" },

  { "nyoom-engineering/oxocarbon.nvim" },

  { "RRethy/base16-nvim" },

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
    cmd = {
      "TSInstall",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
      "TSInstallInfo",
      "TSInstallSync",
      "TSInstallFromGrammar",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        -- A list of parser names, or "all" (the four listed parsers should always be installed)
        ensure_installed = { "c", "lua", "vim", "rust", "cpp", "julia" },
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
  {
    -- Lazy loaded by Comment.nvim pre_hook
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
  },

  "marko-cerovac/material.nvim",
  "NLKNguyen/papercolor-theme",
  "luisiacc/gruvbox-baby",
  "folke/tokyonight.nvim",
  "lunarvim/lunar.nvim",
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
    dependencies = { "telescope-fzf-native.nvim" },
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
          file_previewer = function() return end,
          grep_previewer = function() return end,
          qflist_previewer = function() return end,
        },
      })
    end,
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },

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
  -- {
  --   "ggandor/flit.nvim",
  --   dependencies = { "ggandor/leap.nvim" },
  --   config = function()
  --     require("flit").setup()
  --   end,
  -- },
  -- {
  --   "ggandor/leap.nvim",
  --   config = function()
  --     require("leap").add_default_mappings()
  --     vim.keymap.del({ "x", "o" }, "x")
  --     vim.keymap.del({ "x", "o" }, "X")
  --     -- To set alternative keys for "exclusive" selection:
  --     -- vim.keymap.set({'x', 'o'}, <some-other-key>, '<Plug>(leap-forward-till)')
  --     -- vim.keymap.set({'x', 'o'}, <some-other-key>, '<Plug>(leap-backward-till)')
  --   end,
  -- },

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

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup {
        options = { theme = 'dracula' }
      }
    end,
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
  { "echasnovski/mini.nvim",                    version = false },
  {
    "tamago324/lir.nvim",
    config = function()
      local actions = require 'lir.actions'
      local mark_actions = require 'lir.mark.actions'
      local clipboard_actions = require 'lir.clipboard.actions'

      require 'lir'.setup {
        show_hidden_files = false,
        ignore = {}, -- { ".DS_Store", "node_modules" } etc.
        devicons = {
          enable = false,
          highlight_dirname = false
        },
        mappings = {
          ['l']     = actions.edit,
          ['<C-s>'] = actions.split,
          ['<C-v>'] = actions.vsplit,
          ['<C-t>'] = actions.tabedit,

          ['h']     = actions.up,
          ['q']     = actions.quit,

          ['K']     = actions.mkdir,
          ['N']     = actions.newfile,
          ['R']     = actions.rename,
          ['@']     = actions.cd,
          ['Y']     = actions.yank_path,
          ['.']     = actions.toggle_show_hidden,
          ['D']     = actions.delete,

          ['J']     = function()
            mark_actions.toggle_mark()
            vim.cmd('normal! j')
          end,
          ['C']     = clipboard_actions.copy,
          ['X']     = clipboard_actions.cut,
          ['P']     = clipboard_actions.paste,
        },
        float = {
          winblend = 0,
          curdir_window = {
            enable = false,
            highlight_dirname = false
          },

          -- -- You can define a function that returns a table to be passed as the third
          -- -- argument of nvim_open_win().
          -- win_opts = function()
          --   local width = math.floor(vim.o.columns * 0.8)
          --   local height = math.floor(vim.o.lines * 0.8)
          --   return {
          --     border = {
          --       "+", "─", "+", "│", "+", "─", "+", "│",
          --     },
          --     width = width,
          --     height = height,
          --     row = 1,
          --     col = math.floor((vim.o.columns - width) / 2),
          --   }
          -- end,
        },
        hide_cursor = true
      }

      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { "lir" },
        callback = function()
          -- use visual mode
          vim.api.nvim_buf_set_keymap(
            0,
            "x",
            "J",
            ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
            { noremap = true, silent = true }
          )

          -- echo cwd
          vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
        end
      })

      -- custom folder icon
      require 'nvim-web-devicons'.set_icon({
        lir_folder_icon = {
          icon = "",
          color = "#7ebae4",
          name = "LirFolderNode"
        }
      })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        local function edit_or_open()
          local node = api.tree.get_node_under_cursor()
          if node.nodes ~= nil then
            -- expand or collapse folder
            api.node.open.edit()
          else
            -- open file
            api.node.open.edit()
            -- Close the tree if file was opened
            api.tree.close()
          end
        end
        -- open as vsplit on current node
        local function vsplit_preview()
          local node = api.tree.get_node_under_cursor()
          if node.nodes ~= nil then
            -- expand or collapse folder
            api.node.open.edit()
          else
            -- open file as vsplit
            api.node.open.vertical()
          end
          -- Finally refocus on tree if it was lost
          api.tree.focus()
        end
        -- default mappings
        api.config.mappings.default_on_attach(bufnr)
        -- custom mappings
        vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
        -- global
        vim.api.nvim_set_keymap("n", "<C-h>", ":NvimTreeToggle<cr>", { silent = true, noremap = true })
        -- on_attach
        vim.keymap.set("n", "l", api.node.open.edit, opts("Edit Or Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
        vim.keymap.set("n", "o", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "w", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
      end
      require("nvim-tree").setup({
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 60,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
        on_attach = my_on_attach,
      })
    end,
  },

  { "andymass/vim-matchup",         event = "VimEnter" },

  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup()
    end,
  },

  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
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
        g = {
          name = "git",
        },
        r = {
          name = "aux",
        },
        c = {
          name = "code",
        },
        d = {
          name = "debug",
        },
        S = {
          name = "spectre",
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
          g = { ":Telescope grep_string<CR>", "grep_string" },
          a = { ":Ag <C-R><C-W><CR>", "ag current" },
          w = { ":Rg <C-R><C-W><CR>", "rg current" },
          b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
          c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
          f = { "<cmd>Telescope find_files<cr>", "Find File" },
          h = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
          H = { "<cmd>Telescope highlights<cr>", "Find highlight groups" },
          M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
          o = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
          r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
          R = { "<cmd>Telescope registers<cr>", "Registers" },
          t = { "<cmd>Telescope live_grep<cr>", "Text" },
          k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
          C = { "<cmd>Telescope commands<cr>", "Commands" },
          l = { "<cmd>Telescope resume<cr>", "Resume last search" },
          p = {
            "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>",
            "Colorscheme with Preview",
          },
        },
        b = {
          name = "buffers",
          b = { ":Telescope buffers<CR>", "buffers" },
        },
        l = {
          name = "LSP",
          a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
          d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
          w = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
          f = { function()
            vim.lsp.buf.format({ async = true })
          end, "Format" },
          i = { "<cmd>LspInfo<cr>", "Info" },
          I = { "<cmd>Mason<cr>", "Mason Info" },
          j = {
            "<cmd>lua vim.diagnostic.goto_next()<cr>",
            "Next Diagnostic",
          },
          k = {
            "<cmd>lua vim.diagnostic.goto_prev()<cr>",
            "Prev Diagnostic",
          },
          l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
          q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
          r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
          s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
          S = {
            "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
            "Workspace Symbols",
          },
          e = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
        },
        L = { ":Lazy<CR>", "lazy" },
      }, { prefix = "<leader>" })
    end,
  },

  "RRethy/vim-illuminate",

  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    config = function()
      require("mason").setup({})
    end,
    build = function()
      pcall(function()
        require("mason-registry").refresh()
      end)
    end,
  },
  { "tamago324/nlsp-settings.nvim", cmd = "LspSettings", lazy = true },
  { "nvimtools/none-ls.nvim",       lazy = true },
  {
    "williamboman/mason-lspconfig.nvim",
    cmd = { "LspInstall", "LspUninstall" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "julials", },
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
    },

    opts = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local defaults = require("cmp.config.default")()
      return {
        confirm_opts = {
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          -- { name = 'vsnip' }, -- For vsnip users.
          { name = 'luasnip' }, -- For luasnip users.
          -- { name = 'ultisnips' }, -- For ultisnips users.
          -- { name = 'snippy' }, -- For snippy users.
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          max_width = 0,
          source_names = {
            buffer = "(Buffer)",
            nvim_lsp = "(LSP)",
            luasnip = "(Snippet)",
            path = "(Path)",
            calc = "(Calc)",
            vsnip = "(Snippet)",
            tmux = "(TMUX)",
            emoji = "(Emoji)",
            treesitter = "(TreeSitter)",
          },
          duplicates = {
            buffer = 1,
            path = 1,
            nvim_lsp = 1,
            luasnip = 1,
          },
          duplicates_default = 0,
        },
        experimental = {
          ghost_text = {
            hl_group = "CmpGhostText",
          },
          native_menu = false,
        },
        completion = {
          ---@usage The minimum length of a word to complete on.
          keyword_length = 1,
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sorting = defaults.sorting,
      }
    end,
    config = function(_, opts0)
      local cmp = require("cmp")
      cmp.setup(opts0)
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "SmiteshP/nvim-navic", "mason-lspconfig.nvim", "nlsp-settings.nvim" },
    config = function()
      -- Use an on_attach function to only map the following keys
      -- after the language server attaches to the current buffer
      local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        -- local bufopts = { noremap=true, silent=true, buffer=bufnr }
        vim.keymap.set("n", "<space>e", vim.diagnostic.open_float,
          { noremap = true, silent = true, buffer = bufnr, desc = "diagnostic open" })
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev,
          { noremap = true, silent = true, buffer = bufnr, desc = "prev diagnostic" })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next,
          { noremap = true, silent = true, buffer = bufnr, desc = "next diagnostic" })
        vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist,
          { noremap = true, silent = true, buffer = bufnr, desc = "diagnostic list" })
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
        vim.keymap.set({ "n", "x", "v" }, "<space>bf", function()
          vim.lsp.buf.format({ async = true })
        end, { noremap = true, silent = true, buffer = bufnr, desc = "buffer format" })
        vim.keymap.set({ "n", "x", "v" }, "<space>cf", function()
          vim.lsp.buf.format({ async = true })
        end, { noremap = true, silent = true, buffer = bufnr, desc = "code format" })
        local navic = require("nvim-navic")
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      require 'lspconfig'.ocamllsp.setup {
        on_attach = on_attach,
      }

      require("mason-lspconfig").setup_handlers({
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.

        function(server_name) -- default handler (optional)
          local capabilities = require('cmp_nvim_lsp').default_capabilities()
          require("lspconfig")[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
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
colorscheme PaperColor
filetype off
syntax on
]])
