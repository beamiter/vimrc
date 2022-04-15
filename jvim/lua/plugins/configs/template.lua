local present, plugin = pcall(require, "******")

if not present then
  return
end

local default = {
}

plugin.setup(default)
