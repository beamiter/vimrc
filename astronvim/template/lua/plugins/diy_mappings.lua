return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          ["<Leader>b"] = { name = "Buffers" },
          ["<Leader>c"] = { name = "Code" },
          ["<Leader>bc"] = false,
          ["<Leader>b|"] = false,
          ["<Leader>b\\"] = false,
          ["<Leader>bC"] = false,
          ["<Leader>bl"] = false,
          ["<Leader>br"] = false,
          ["<Leader>bs*"] = false,
          -- second key is the lefthand side of the map
          -- mappings seen under group name "Buffer"
          ["<Leader>bb"] = { ":Telescope buffers<CR>", desc = "buffers" },
          ["<Leader>fr"] = { ":Telescope oldfiles<CR>", desc = "recent files" },
          ["<Leader><leader>"] = { ":Telescope find_files<CR>", desc = "files" },
          ["<Leader>fh"] = { ":Telescope oldfiles<CR>", desc = "history files" },
          ["<Leader>sb"] = { ":Telescope buffers<CR>", desc = "buffers" },
          ["<Leader>sr"] = { ":Telescope oldfiles<CR>", desc = "recent files" },
          ["<Leader>sh"] = { ":Telescope oldfiles<CR>", desc = "history files" },
          ["<Leader>so"] = { ":Telescope oldfiles<CR>", desc = "history files" },
          ["<Leader>gj"] = { ":Gitsigns next_hunk<CR>", desc = "next hunk" },
          ["<Leader>gk"] = { ":Gitsigns prev_hunk<CR>", desc = "prev hunk" },
          ["<Leader>bf"] = { function() vim.lsp.buf.format { async = true } end, desc = "format" },
          ["<Leader>cf"] = { function() vim.lsp.buf.format { async = true } end, desc = "format" },
          ["<Leader>fm"] = { function() vim.lsp.buf.format { async = true } end, desc = "format" },
          ["<Leader>bn"] = { ":BufferLineCycleNext<CR>", desc = "buffer next" },
          ["<Leader>bp"] = { ":BufferLineCyclePrev<CR>", desc = "buffer prev" },
          -- tables with the `name` key will be registered with which-key if it's installed
          -- this is useful for naming menus
          -- quick save
          -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
          ["<F3>"] = { ":Neotree toggle<CR>", desc = "tree toggle" },
        },
        t = {
          -- setting a mapping to false will disable it
          -- ["<esc>"] = false,
        },
      },
    },
  },
  {
    -- "AstroNvim/astrolsp",
    -- ---@type AstroLSPOpts
    -- opts = {
    --   mappings = {
    --     n = {
    --       -- this mapping will only be set in buffers with an LSP attached
    --       K = {
    --         function()
    --           vim.lsp.buf.hover()
    --         end,
    --         desc = "Hover symbol details",
    --       },
    --       -- condition for only server with declaration capabilities
    --       gD = {
    --         function()
    --           vim.lsp.buf.declaration()
    --         end,
    --         desc = "Declaration of current symbol",
    --         cond = "textDocument/declaration",
    --       },
    --     },
    --   },
    -- },
  },
}
