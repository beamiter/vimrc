local present, plugin = pcall(require, "which-key")

if not present then
  return
end

local default = {
}

plugin.register({
  w = {
    name = "window", -- optional group name
    w = { "<C-w>w", "other-window" },
    d = { '<C-W>c', 'delete-window' },
    ["2"] = { '<C-W>v', 'layout-double-columns' },
    h = { '<C-W>h', 'window-left' },
    j = { '<C-W>j', 'window-below' },
    l = { '<C-W>l', 'window-right' },
    k = { '<C-W>k', 'window-up' },
    o = { '<C-W>o', 'window-only' },
    H = { '<C-W>5<', 'expand-window-left' },
    J = { ':resize +5', 'expand-window-below' },
    L = { '<C-W>5>', 'expand-window-right' },
    K = { ':resize -5', 'expand-window-up' },
    ["="] = { '<C-W>=', 'balance-window' },
    s = { '<C-W>s', 'split-window-below' },
    v = { '<C-W>v', 'split-window-right' },
  },
  f = {
    name = "files",
    t = { ":NvimTreeFindFileToggle<CR>", "tree toggle" },
    f = { ":Telescope find_files<CR>", "files" },
    g = { ":Telescope live_grep<CR>", "live_grep" },
    b = { ":Telescope buffers<CR>", "buffers" },
    h = { ":Telescope oldfiles<CR>", "oldfiles" },
  },
  b = {
    name = "buffers",
    f = { ":Neoformat<CR>", "format" },
    b = { ":Telescope buffers<CR>", "buffers" },
  },
}, { prefix = "<leader>" })

plugin.setup(default)
