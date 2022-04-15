local present, plugin = pcall(require, "telescope")

if not present then
  return
end


local actions = require('telescope.actions')
local default = {
  defaults = {
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-n>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-p>"] = actions.move_selection_previous,
      },
    },
  }
}

plugin.setup(default)
