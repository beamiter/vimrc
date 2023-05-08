-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- mappings seen under group name "Buffer"
    ["<leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(function(bufnr) require("astronvim.utils.buffer").close(bufnr) end)
      end,
      desc = "Pick to close",
    },
    ["s"] = { "<cmd>lua require'hop'.hint_char2()<CR>" },
    ["S"] = { "<cmd>lua require'hop'.hint_char1()<CR>" },
    ["<F3>"] = { ":Neotree toggle left reveal_force_cwd<CR>" },
    ["<leader>bj"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end)
      end,
      desc = "Select buffer from tabline",
    },
    -- ["<leader>1"] = { ":BufferLineGoToBuffer 1<CR>", desc = "" },
    -- ["<leader>2"] = { ":BufferLineGoToBuffer 2<CR>", desc = "" },
    -- ["<leader>3"] = { ":BufferLineGoToBuffer 3<CR>", desc = "" },
    -- ["<leader>4"] = { ":BufferLineGoToBuffer 4<CR>", desc = "" },
    -- ["<leader>5"] = { ":BufferLineGoToBuffer 5<CR>", desc = "" },
    -- ["<leader>6"] = { ":BufferLineGoToBuffer 6<CR>", desc = "" },
    -- ["<leader>7"] = { ":BufferLineGoToBuffer 7<CR>", desc = "" },
    -- ["<leader>8"] = { ":BufferLineGoToBuffer 8<CR>", desc = "" },
    -- ["<leader>9"] = { ":BufferLineGoToBuffer 9<CR>", desc = "" },
    -- ["<leader>0"] = { ":BufferLineGoToBuffer 10<CR>", desc = "" },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
}
