return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    "junegunn/fzf",
    build = "./install --bin",
  },

  {
    "junegunn/fzf.vim",
    enabled = false,
  },

  {
    "ibhagwan/fzf-lua",
    lazy = false,
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup {}
    end,
  },

  {
    "phaazon/hop.nvim",
    branch = "v2", -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require("hop").setup { keys = "etovxqpdygfblzhckisuran" }
    end,
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
      require("bufferline").setup {}
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    config = function()
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        -- default mappings
        api.config.mappings.default_on_attach(bufnr)
        -- custom mappings
        vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts "Up")
        vim.keymap.set("n", "?", api.tree.toggle_help, opts "Help")
        -- global
        -- vim.api.nvim_set_keymap("n", "<C-h>", ":NvimTreeToggle<cr>", { silent = true, noremap = true })
        -- on_attach
        vim.keymap.set("n", "l", api.node.open.edit, opts "Edit Or Open")
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
        vim.keymap.set("n", "o", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "w", api.node.open.edit, opts "Open")
        vim.keymap.set("n", "H", api.tree.collapse_all, opts "Collapse All")
      end
      require("nvim-tree").setup {
        view = {
          width = 60,
        },
        on_attach = my_on_attach,
      }
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server", "stylua", "clangd",
        "html-lsp", "css-lsp", "prettier"
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css"
      },
    },
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = { 'saadparwaiz1/cmp_luasnip' },
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

}
