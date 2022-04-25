local config = {

  -- Set colorscheme
  colorscheme = "lunar",

  -- Default theme configuration
  default_theme = {
    diagnostics_style = { italic = true },
    -- Modify the color table
    colors = {
      fg = "#abb2bf",
    },
    -- Modify the highlight groups
    highlights = function(highlights)
      local C = require "default_theme.colors"

      highlights.Normal = { fg = C.fg, bg = C.bg }
      return highlights
    end,
  },

  -- Disable default plugins
  enabled = {
    bufferline = true,
    neo_tree = true,
    lualine = true,
    gitsigns = true,
    colorizer = true,
    toggle_term = true,
    comment = true,
    symbols_outline = true,
    indent_blankline = true,
    dashboard = true,
    which_key = true,
    neoscroll = false,
    ts_rainbow = true,
    ts_autotag = true,
  },

  -- Disable AstroNvim ui features
  ui = {
    nui_input = true,
    telescope_select = true,
  },

  -- Configure plugins
  plugins = {
    -- Add plugins, the packer syntax without the "use"
    init = {
      { 'christianchiarulli/nvcode-color-schemes.vim' },
      { 'marko-cerovac/material.nvim' },
      { 'LunarVim/onedarker.nvim' },
      { 'Mofiqul/vscode.nvim' },
      { 'dracula/vim' },
      {
        'phaazon/hop.nvim',
        branch = 'v1', -- optional but strongly recommended
        config = function()
          -- you can configure Hop the way you like here; see :h hop-config
          require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
        end
      },
      -- { "andweeb/presence.nvim" },
      -- {
      --   "ray-x/lsp_signature.nvim",
      --   event = "BufRead",
      --   config = function()
      --     require("lsp_signature").setup()
      --   end,
      -- },
    },
    -- All other entries override the setup() call for default plugins
    treesitter = {
      ensure_installed = { "lua" },
    },
    packer = {
      compile_path = vim.fn.stdpath "config" .. "/lua/packer_compiled.lua",
    },
    ["which-key"] = {
      ignore_missing = false,
    },
  },

  -- Add paths for including more VS Code style snippets in luasnip
  luasnip = {
    vscode_snippet_paths = {},
  },

  -- Modify which-key registration
  ["which-key"] = {
    -- Add bindings to the normal mode <leader> mappings
    register_n_leader = {
      -- ["N"] = { "<cmd>tabnew<cr>", "New Buffer" },
    },
  },

  -- CMP Source Priorities
  -- modify here the priorities of default cmp sources
  -- higher value == higher priority
  -- The value can also be set to a boolean for disabling default sources:
  -- false == disabled
  -- true == 1000
  cmp = {
    source_priority = {
      nvim_lsp = 1000,
      luasnip = 750,
      buffer = 500,
      path = 250,
    },
  },

  -- Extend LSP configuration
  lsp = {
    -- add to the server on_attach function
    -- on_attach = function(client, bufnr)
    -- end,

    -- override the lsp installer server-registration function
    -- server_registration = function(server, opts)
    --   server:setup(opts)
    -- end

    -- Add overrides for LSP server settings, the keys are the name of the server
    ["server-settings"] = {
      -- example for addings schemas to yamlls
      -- yamlls = {
      --   settings = {
      --     yaml = {
      --       schemas = {
      --         ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
      --         ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
      --         ["http://json.schemastore.org/ansible-stable-2.9"] = "roles/tasks/*.{yml,yaml}",
      --       },
      --     },
      --   },
      -- },
    },
  },

  -- Diagnostics configuration (for vim.diagnostics.config({}))
  diagnostics = {
    virtual_text = false,
    underline = true,
  },

  -- null-ls configuration
  ["null-ls"] = function()
    -- Formatting and linting
    -- https://github.com/jose-elias-alvarez/null-ls.nvim
    local status_ok, null_ls = pcall(require, "null-ls")
    if not status_ok then
      return
    end

    -- Check supported formatters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    local formatting = null_ls.builtins.formatting

    -- Check supported linters
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    local diagnostics = null_ls.builtins.diagnostics

    null_ls.setup {
      debug = false,
      sources = {
        -- Set a formatter
        formatting.rufo,
        -- Set a linter
        diagnostics.rubocop,
      },
      -- NOTE: You can remove this on attach function to disable format on save
      on_attach = function(client)
        if client.resolved_capabilities.document_formatting then
          vim.api.nvim_create_autocmd("BufWritePre", {
            desc = "Auto format before save",
            pattern = "<buffer>",
            callback = vim.lsp.buf.formatting_sync,
          })
        end
      end,
    }
  end,

  -- This function is run last
  -- good place to configure mappings and vim options
  polish = function()
    local map = vim.keymap.set
    local set = vim.opt
    -- Set options
    set.relativenumber = true

    -- Set key bindings
    map("n", "<C-s>", ":w!<CR>")
    map("n", "<leader><leader>", ":Telescope buffers<CR>")
    map('n', 's', "<cmd>lua require'hop'.hint_char2()<CR>")
    map('n', 'S', "<cmd>lua require'hop'.hint_char1()<CR>")
    map('n', 'f', "<cmd>lua require'hop'.hint_char2({ current_line_only = true })<CR>")
    map('n', 'F', "<cmd>lua require'hop'.hint_char1({ current_line_only = true })<CR>")
    map("n", "<F3>", ":NeoTreeFocusToggle<CR>")
    map("n", "<leader>ft", ":NeoTreeFocusToggle<CR>")
    map("n", "<C-n>", ":NeoTreeFocusToggle<CR>")
    map("n", "[g", ":Gitsigns prev_hunk<CR>")
    map("n", "]g", ":Gitsigns next_hunk<CR>")
    map("n", "<leader>bb", ":Telescope buffers<CR>")
    map("n", "<leader>bj", ":BufferLinePick<CR>")
    map("n", "<leader>1", ":BufferLineGoToBuffer 1<CR>")
    map("n", "<leader>2", ":BufferLineGoToBuffer 2<CR>")
    map("n", "<leader>3", ":BufferLineGoToBuffer 3<CR>")
    map("n", "<leader>4", ":BufferLineGoToBuffer 4<CR>")
    map("n", "<leader>5", ":BufferLineGoToBuffer 5<CR>")
    map("n", "<leader>6", ":BufferLineGoToBuffer 6<CR>")
    map("n", "<leader>7", ":BufferLineGoToBuffer 7<CR>")
    map("n", "<leader>8", ":BufferLineGoToBuffer 8<CR>")
    map("n", "<leader>9", ":BufferLineGoToBuffer 9<CR>")
    map("n", "<leader>0", ":BufferLineGoToBuffer 10<CR>")
    map("n", "<leader>cl", "<cmd>lua require('Comment.api').toggle_current_linewise(vim.fn.visualmode())<CR>")
    map("v", "<leader>cl", "<cmd>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>")


    vim.g.vscode_style = "dark"

    -- Set autocommands
    vim.api.nvim_create_augroup("packer_conf", {})
    vim.api.nvim_create_autocmd("BufWritePost", {
      desc = "Sync packer after modifying plugins.lua",
      group = "packer_conf",
      pattern = "plugins.lua",
      command = "source <afile> | PackerSync",
    })

    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    --   pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }
  end,
}

return config
