-- ========================================================================
-- 基础配置
-- ========================================================================

-- 设置 lazy.nvim 插件管理器
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- 使用最新稳定版
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 设置全局变量和键位
local opt = vim.opt
local g = vim.g
local map = vim.keymap.set

-- 领导键设置
g.mapleader = " "
g.maplocalleader = ","

-- 全局设置
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.noautochdir = true
g.nobackup = true
g.noswapfile = true
g.nowritebackup = true
g.vscode_style = "dark"
g.catppuccin_flavour = "frappe" -- latte, frappe, macchiato, mocha
vim.go.background = "dark"
-- vim.go.background = "light"

-- 编辑器选项设置
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

-- ========================================================================
-- 自动命令
-- ========================================================================

-- 创建自动命令组
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- 针对特定文件类型的设置
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

-- ========================================================================
-- 键位映射
-- ========================================================================

local opts = { noremap = true, silent = true }

-- 文件浏览器
map("n", "<F3>", ":NvimTreeFindFileToggle<CR>", opts)
map("n", "<C-n>", ":NvimTreeFindFileToggle<CR>", opts)

-- 窗口调整
map("n", "=", ":vert res +5<CR>", opts)
map("n", "-", ":vert res -5<CR>", opts)
map("n", "<C-Right>", ":vert res +5<CR>", opts)
map("n", "<C-Left>", ":vert res -5<CR>", opts)

-- Git 导航
map("n", "[g", ":Gitsigns prev_hunk<CR>", opts)
map("n", "]g", ":Gitsigns next_hunk<CR>", opts)
map("n", "<leader>gj", ":Gitsigns next_hunk<CR>", opts)
map("n", "<leader>gk", ":Gitsigns prev_hunk<CR>", opts)

-- 快速访问
map("n", "<leader><leader>", ":Telescope find_files<CR>", opts)

-- 缓冲区导航
for i = 1, 9 do
  map("n", "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", opts)
end
map("n", "<leader>0", "<Cmd>BufferLineGoToBuffer 10<CR>", opts)
map("n", "<leader>bd", ":bd<CR>", opts)
map("n", "<leader>bj", "<Cmd>BufferLinePick<CR>", opts)

-- 窗口导航
for i = 1, 9 do
  map("n", "<localleader>" .. i, ":<C-u>" .. i .. " wincmd w<CR>", opts)
end
map("n", "<localleader>0", ":<C-u>10 wincmd w<CR>", opts)

-- 搜索相关
map("n", "<leader>So", "<cmd>lua require('spectre').open()<CR>", {})
map("n", "<leader>Sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", {})
map("v", "<leader>S", "<cmd>lua require('spectre').open_visual()<CR>", {})
map("n", "<leader>Sp", "<cmd>lua require('spectre').open_file_search()<CR>", {})

-- ========================================================================
-- 插件配置
-- ========================================================================

require("lazy").setup({
  -- ========== 性能优化 ==========
  "lewis6991/impatient.nvim",
  "folke/neodev.nvim",
  {
    "folke/neoconf.nvim",
    config = function() end,
  },

  -- ========== UI 增强 ==========
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'dracula',
          refresh = { statusline = 1000000 }
        }
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
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("alpha").setup(require("alpha.themes.dashboard").config)
    end,
  },
  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup()
    end,
  },
  {
    "j-hui/fidget.nvim",
    opts = {},
  },
  { "nvim-neotest/nvim-nio" },

  -- ========== 编辑增强 ==========
  "mg979/vim-visual-multi",
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({})
      -- 切换注释
      vim.keymap.set(
        "n",
        "<leader>cl",
        "v:count == 0 ? '<Plug>(comment_toggle_current_linewise)' : '<Plug>(comment_toggle_linewise_count)'",
        { expr = true, remap = true }
      )
      -- 在可视模式下切换注释
      vim.keymap.set("x", "<leader>cl", "<Plug>(comment_toggle_linewise_visual)")
    end,
  },
  "ntpeters/vim-better-whitespace",
  {
    'andymass/vim-matchup',
    config = function()
      g.matchup_matchparen_offscreen = { method = "status" }
    end,
  },

  -- ========== 导航和搜索 ==========
  "dyng/ctrlsf.vim",
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({})
    end
  },
  { "junegunn/fzf",         dir = "~/.fzf", run = "./install --all" },
  "junegunn/fzf.vim",
  "preservim/tagbar",
  {
    "phaazon/hop.nvim",
    config = function()
      require("hop").setup({ keys = "etovxqpdygfblzhckisuran", jump_on_sole_occurrence = false })
      vim.api.nvim_set_keymap("n", "s", "<cmd>lua require'hop'.hint_char2()<cr>", {})
      vim.api.nvim_set_keymap("n", "S", "<cmd>lua require'hop'.hint_char1()<cr>", {})
      vim.api.nvim_set_keymap("n", "f", "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<cr>", {})
      vim.api.nvim_set_keymap("n", "F", "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<cr>", {})
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "telescope-fzf-native.nvim",
      'nvim-telescope/telescope-symbols.nvim',
      "cljoly/telescope-repo.nvim"
    },
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
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make",      lazy = true },
  "mhinz/vim-grepper",
  {
    "windwp/nvim-spectre",
    config = function()
      require("spectre").setup()
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- 默认映射
        api.config.mappings.default_on_attach(bufnr)

        -- 自定义映射
        vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
        vim.keymap.set("n", "l", api.node.open.edit, opts("Edit Or Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
        vim.keymap.set("n", "o", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "w", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "H", api.tree.collapse_all, opts("Collapse All"))
      end

      require("nvim-tree").setup({
        sort = { sorter = "case_sensitive" },
        view = { width = 60 },
        renderer = { group_empty = true },
        filters = { dotfiles = false },
        on_attach = my_on_attach,
      })
    end,
  },

  -- ========== 终端集成 ==========
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup()
      function _G.set_terminal_keymaps()
        local opts = { noremap = true, silent = true }
        vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
        vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
      end

      vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
    end,
  },
  {
    "numToStr/FTerm.nvim",
    config = function()
      require("FTerm").setup({})
      vim.keymap.set("n", "<F8>", '<CMD>lua require("FTerm").toggle()<CR>')
      vim.keymap.set("t", "<F8>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
    end,
  },

  -- ========== Git 集成 ==========
  "tpope/vim-fugitive",
  {
    "lewis6991/gitsigns.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- ========== 语法和语言支持 ==========
  "nvim-treesitter/nvim-treesitter-textobjects",
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = { "TSInstall", "TSUninstall", "TSUpdate", "TSUpdateSync", "TSInstallInfo", "TSInstallSync", "TSInstallFromGrammar" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vim", "rust", "cpp", "julia" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          disable = {},
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
  },

  -- ========== LSP 和自动补全 ==========
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
  { "tamago324/nlsp-settings.nvim",             cmd = "LspSettings", lazy = true },
  { "nvimtools/none-ls.nvim",                   lazy = true },
  {
    "williamboman/mason-lspconfig.nvim",
    cmd = { "LspInstall", "LspUninstall" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "rust_analyzer", "clangd", "julials" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "SmiteshP/nvim-navic", "mason-lspconfig.nvim", "nlsp-settings.nvim" },
    config = function()
      -- 定义 LSP 附加函数
      local on_attach = function(client, bufnr)
        local function buf_map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
        end

        -- 诊断相关
        buf_map("n", "<space>e", vim.diagnostic.open_float, "diagnostic open")
        buf_map("n", "[d", vim.diagnostic.goto_prev, "prev diagnostic")
        buf_map("n", "]d", vim.diagnostic.goto_next, "next diagnostic")
        buf_map("n", "<space>q", vim.diagnostic.setloclist, "diagnostic list")

        -- LSP 导航
        buf_map("n", "gD", vim.lsp.buf.declaration, "declaration")
        buf_map("n", "gd", vim.lsp.buf.definition, "definition")
        buf_map("n", "K", vim.lsp.buf.hover, "hover")
        buf_map("n", "gi", vim.lsp.buf.implementation, "implementation")
        buf_map("n", "<C-k>", vim.lsp.buf.signature_help, "signature_help")
        buf_map("n", "gr", vim.lsp.buf.references, "references")

        -- 工作区相关
        buf_map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, "add_workspace_folder")
        buf_map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, "remove_workspace_folder")
        buf_map("n", "<space>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "list_workspace_folders")

        -- 代码操作
        buf_map("n", "<space>D", vim.lsp.buf.type_definition, "type_definition")
        buf_map("n", "<space>rn", vim.lsp.buf.rename, "rename")
        buf_map("n", "<space>ca", vim.lsp.buf.code_action, "code_action")

        -- 格式化
        buf_map({ "n", "x", "v" }, "<space>fm", function()
          vim.lsp.buf.format({ async = true })
        end, "format")
        buf_map({ "n", "x", "v" }, "<space>cf", function()
          vim.lsp.buf.format({ async = true })
        end, "code format")

        -- 导航集成
        local navic = require("nvim-navic")
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end

      -- 设置 OCaml LSP
      require('lspconfig').ocamllsp.setup {
        on_attach = on_attach,
      }

      -- 设置 Mason LSP 处理程序
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          local capabilities = require('cmp_nvim_lsp').default_capabilities()
          require("lspconfig")[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
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
          ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if luasnip.expandable() then
                luasnip.expand()
              else
                cmp.confirm({ select = true })
              end
            else
              fallback()
            end
          end),
          ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          max_width = 0,
          source_names = {
            nvim_lsp = "(LSP)",
            buffer = "(Buffer)",
            luasnip = "(Snippet)",
            path = "(Path)",
            calc = "(Calc)",
            vsnip = "(Snippet)",
            tmux = "(TMUX)",
            emoji = "(Emoji)",
            treesitter = "(TreeSitter)",
          },
          duplicates = {
            nvim_lsp = 1,
            buffer = 1,
            luasnip = 1,
            path = 1,
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

  -- ========== 调试支持 ==========
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      -- 键位映射
      vim.api.nvim_set_keymap("n", "<F5>", "<cmd>lua require'dap'.continue()<cr>", {})
      vim.api.nvim_set_keymap("n", "<F9>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", {})
      vim.api.nvim_set_keymap("n", "<F10>", "<cmd>lua require'dap'.step_over()<cr>", {})
      vim.api.nvim_set_keymap("n", "<F11>", "<cmd>lua require'dap'.step_into()<cr>", {})
      vim.api.nvim_set_keymap("n", "<S-F11>", "<cmd>lua require'dap'.step_out()<cr>", {})

      -- C++ 调试器配置
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
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

      -- 设置自动打开/关闭调试UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- 键位映射
      vim.api.nvim_set_keymap("n", "<leader>di", "<cmd>lua require'dapui'.eval()<cr>", {})
      vim.api.nvim_set_keymap("v", "<leader>di", "<cmd>lua require'dapui'.eval()<cr>", {})
    end,
  },

  -- ========== 键位指南 ==========
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      -- 主要分组
      { "<leader>L",  ":Lazy<CR>",                                                                      desc = "lazy" },
      { "<leader>S",  group = "spectre" },
      { "<leader>b",  group = "buffers" },
      { "<leader>c",  group = "code" },
      { "<leader>d",  group = "debug" },
      { "<leader>f",  group = "files" },
      { "<leader>g",  group = "git" },
      { "<leader>l",  group = "LSP" },
      { "<leader>r",  group = "aux" },
      { "<leader>s",  group = "search" },
      { "<leader>w",  group = "window" },

      -- 文件操作
      { "<leader>fb", ":Telescope buffers<CR>",                                                         desc = "buffers" },
      { "<leader>ff", ":Telescope find_files<CR>",                                                      desc = "files" },
      { "<leader>fh", ":Telescope oldfiles<CR>",                                                        desc = "oldfiles" },
      { "<leader>fr", ":Telescope oldfiles<CR>",                                                        desc = "oldfiles" },
      { "<leader>ft", ":NvimTreeFindFileToggle<CR>",                                                    desc = "tree toggle" },
      { "<leader>fw", ":Telescope live_grep<CR>",                                                       desc = "live_grep" },

      -- LSP 相关
      { "<leader>lI", "<cmd>Mason<cr>",                                                                 desc = "Mason Info" },
      { "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",                               desc = "Workspace Symbols" },
      { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",                                         desc = "Code Action" },
      { "<leader>ld", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>",                           desc = "Buffer Diagnostics" },
      { "<leader>le", "<cmd>Telescope quickfix<cr>",                                                    desc = "Telescope Quickfix" },
      { "<leader>lf", function() vim.lsp.buf.format({ async = true }) end,                              desc = "Format" },
      { "<leader>li", "<cmd>LspInfo<cr>",                                                               desc = "Info" },
      { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<cr>",                                        desc = "Next Diagnostic" },
      { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<cr>",                                        desc = "Prev Diagnostic" },
      { "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>",                                            desc = "CodeLens Action" },
      { "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>",                                       desc = "Quickfix" },
      { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>",                                              desc = "Rename" },
      { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>",                                        desc = "Document Symbols" },
      { "<leader>lw", "<cmd>Telescope diagnostics<cr>",                                                 desc = "Diagnostics" },

      -- 搜索相关
      { "<leader>sC", "<cmd>Telescope commands<cr>",                                                    desc = "Commands" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>",                                                  desc = "Find highlight groups" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>",                                                   desc = "Man Pages" },
      { "<leader>sR", "<cmd>Telescope registers<cr>",                                                   desc = "Registers" },
      { "<leader>sa", ":Ag <C-R><C-W><CR>",                                                             desc = "ag current" },
      { "<leader>sb", "<cmd>Telescope git_branches<cr>",                                                desc = "Checkout branch" },
      { "<leader>sc", "<cmd>Telescope colorscheme<cr>",                                                 desc = "Colorscheme" },
      { "<leader>sf", "<cmd>Telescope find_files<cr>",                                                  desc = "Find File" },
      { "<leader>sg", ":Telescope grep_string<CR>",                                                     desc = "grep_string" },
      { "<leader>sh", "<cmd>Telescope oldfiles<cr>",                                                    desc = "Open Recent File" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>",                                                     desc = "Keymaps" },
      { "<leader>sl", "<cmd>Telescope resume<cr>",                                                      desc = "Resume last search" },
      { "<leader>so", "<cmd>Telescope oldfiles<cr>",                                                    desc = "Open Recent File" },
      { "<leader>sp", "<cmd>lua require('telescope.builtin').colorscheme({enable_preview = true})<cr>", desc = "Colorscheme with Preview" },
      { "<leader>sr", "<cmd>Telescope oldfiles<cr>",                                                    desc = "Open Recent File" },
      { "<leader>st", "<cmd>Telescope live_grep<cr>",                                                   desc = "Text" },
      { "<leader>sw", ":Rg <C-R><C-W><CR>",                                                             desc = "rg current" },

      -- 窗口管理
      { "<leader>w2", "<C-W>v",                                                                         desc = "layout-double-columns" },
      { "<leader>w=", "<C-W>=",                                                                         desc = "balance-window" },
      { "<leader>wH", "<C-W>5<",                                                                        desc = "expand-window-left" },
      { "<leader>wJ", ":resize +5",                                                                     desc = "expand-window-below" },
      { "<leader>wK", ":resize -5",                                                                     desc = "expand-window-up" },
      { "<leader>wL", "<C-W>5>",                                                                        desc = "expand-window-right" },
      { "<leader>wd", "<C-W>c",                                                                         desc = "delete-window" },
      { "<leader>wh", "<C-W>h",                                                                         desc = "window-left" },
      { "<leader>wj", "<C-W>j",                                                                         desc = "window-below" },
      { "<leader>wk", "<C-W>k",                                                                         desc = "window-up" },
      { "<leader>wl", "<C-W>l",                                                                         desc = "window-right" },
      { "<leader>wo", "<C-W>o",                                                                         desc = "window-only" },
      { "<leader>ws", "<C-W>s",                                                                         desc = "split-window-below" },
      { "<leader>wv", "<C-W>v",                                                                         desc = "split-window-right" },
      { "<leader>ww", "<C-w>w",                                                                         desc = "other-window" },
    },
  },

  -- ========== 高亮和显示 ==========
  "RRethy/vim-illuminate",
  { "nvim-lua/plenary.nvim", cmd = { "PlenaryBustedFile", "PlenaryBustedDirectory" }, lazy = true },
  "SmiteshP/nvim-navic",
  { "echasnovski/mini.nvim", version = false },

  -- ========== 文件浏览器 ==========
  {
    "tamago324/lir.nvim",
    config = function()
      local actions = require('lir.actions')
      local mark_actions = require('lir.mark.actions')
      local clipboard_actions = require('lir.clipboard.actions')

      require('lir').setup {
        show_hidden_files = false,
        ignore = {},
        devicons = { enable = false, highlight_dirname = false },
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
          curdir_window = { enable = false, highlight_dirname = false }
        },
        hide_cursor = true
      }

      -- 设置文件类型自动命令
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = { "lir" },
        callback = function()
          vim.api.nvim_buf_set_keymap(
            0, "x", "J", ':<C-u>lua require"lir.mark.actions".toggle_mark("v")<CR>',
            { noremap = true, silent = true }
          )
          vim.api.nvim_echo({ { vim.fn.expand("%:p"), "Normal" } }, false, {})
        end
      })

      -- 自定义文件夹图标
      require('nvim-web-devicons').set_icon({
        lir_folder_icon = {
          icon = "",
          color = "#7ebae4",
          name = "LirFolderNode"
        }
      })
    end,
  },

  -- ========== 颜色主题 ==========
  "EdenEast/nightfox.nvim",
  "lunarvim/horizon.nvim",
  { "mangeshrex/everblush.vim" },
  { "nyoom-engineering/oxocarbon.nvim" },
  { "RRethy/base16-nvim" },
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
  { "catppuccin/nvim", as = "catppuccin" },
  {
    "rose-pine/neovim",
    as = "rose-pine",
    config = function() end,
  },
  "bluz71/vim-moonfly-colors",
  "bluz71/vim-nightfly-guicolors",
  { "dracula/vim",     as = "dracula" },
})

-- ========================================================================
-- 最终设置
-- ========================================================================

vim.cmd([[
colorscheme lunar
filetype off
syntax on
]])
