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

-- example using a list of specs with the default options
vim.g.mapleader = " " -- make sure to set `mapleader` before lazy so your mappings are correct

require("lazy").setup({
    { "folke/neoconf.nvim",     cmd = "Neoconf" },
    "folke/neodev.nvim",
    {
        "folke/which-key.nvim",
        config = function()
          vim.o.timeout = true
          vim.o.timeoutlen = 300
          require("which-key").setup({
              -- your configuration comes here
              -- or leave it empty to use the default settings
              -- refer to the configuration section below
          })
        end,
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        keys = {
            { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        config = function()
          require("neo-tree").setup()
        end,
    },

    -- the colorscheme should be available when starting Neovim
    {
        "folke/tokyonight.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
          -- load the colorscheme here
          vim.cmd([[colorscheme tokyonight]])
        end,
    },

    -- I have a separate config.mappings file where I require which-key.
    -- With lazy the plugin will be automatically loaded when it is required somewhere

    {
        "nvim-neorg/neorg",
        -- lazy-load on filetype
        ft = "norg",
        -- custom config that will be executed when loading the plugin
        config = function()
          require("neorg").setup()
        end,
    },

    {
        "dstein64/vim-startuptime",
        -- lazy-load on a command
        cmd = "StartupTime",
    },

    {
        "hrsh7th/nvim-cmp",
        -- load cmp on InsertEnter
        event = "InsertEnter",
        -- these dependencies will only be loaded when cmp loads
        -- dependencies are always lazy-loaded unless specified otherwise
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
        },
        config = function()
          -- ...
        end,
    },

    {
        "williamboman/mason.nvim",
        config = function()
          require("mason").setup()
        end,
    },

    -- you can use the VeryLazy event for things that can
    -- load later and are not important for the initial UI
    { "stevearc/dressing.nvim", event = "VeryLazy" },

    {
        "cshuaimin/ssr.nvim",
        -- init is always executed during startup, but doesn't load the plugin yet.
        init = function()
          vim.keymap.set({ "n", "x" }, "<leader>cR", function()
            -- this require will automatically load the plugin
            require("ssr").open()
          end, { desc = "Structural Replace" })
        end,
    },

    {
        "monaqa/dial.nvim",
        -- lazy-load on keys
        -- mode is `n` by default. For more advanced options, check the section on key mappings
        keys = { "<C-a>", { "<C-x>", mode = "n" } },
    },

    -- local plugins need to be explicitly configured with dir
    -- { dir = "~/projects/secret.nvim" },

    -- you can use a custom url to fetch a plugin
    -- { url = "git@github.com:folke/noice.nvim.git" },

    -- local plugins can also be configure with the dev option.
    -- This will use {config.dev.path}/noice.nvim/ instead of fetching it from Github
    -- With the dev option, you can easily switch between the local and installed version of a plugin
    { "folke/noice.nvim", dev = true },

})
