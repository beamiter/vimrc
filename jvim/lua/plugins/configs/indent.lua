local present, plugin = pcall(require, "indent_blankline")

if not present then
  return
end

local default = {
  -- for example, context is off by default, use this to turn it on
  show_current_context = true,
  show_current_context_start = true,
}

plugin.setup(default)
