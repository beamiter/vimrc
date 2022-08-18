-- lua/custom/mappings 

local M = {}

M.abc = {
  n = {
    ["s"] = {"<cmd>lua require'hop'.hint_char2()<CR>", ""},
    ["S"] = {"<cmd>lua require'hop'.hint_char1()<CR>", ""},
    ["[g"] = {":Gitsigns prev_hunk<CR>"},
    ["sg"] = {":Telescope grep_string<CR>"},
    ["]g"] = {":Gitsigns next_hunk<CR>"},
    ["<leader>1"] = { "<cmd> BufferLineGoToBuffer 1 <CR>", "" },
    ["<leader>2"] = { "<cmd> BufferLineGoToBuffer 2 <CR>", "" },
    ["<leader>3"] = { "<cmd> BufferLineGoToBuffer 3 <CR>", "" },
    ["<leader>4"] = { "<cmd> BufferLineGoToBuffer 4 <CR>", "" },
    ["<leader>5"] = { "<cmd> BufferLineGoToBuffer 5 <CR>", "" },
    ["<leader>6"] = { "<cmd> BufferLineGoToBuffer 6 <CR>", "" },
    ["<leader>7"] = { "<cmd> BufferLineGoToBuffer 7 <CR>", "" },
    ["<leader>8"] = { "<cmd> BufferLineGoToBuffer 8 <CR>", "" },
    ["<leader>9"] = { "<cmd> BufferLineGoToBuffer 9 <CR>", "" },
    ["<leader>0"] = { "<cmd> BufferLineGoToBuffer 10<CR>", "" },
  },
  i = {

  }
}

M.nvimtree = {
   n = {
      ["<leader>e"] = { "<cmd> NvimTreeToggle <CR>", "   toggle nvimtree" },
   },
}

return M
