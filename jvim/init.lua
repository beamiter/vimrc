local present, impatient = pcall(require, "impatient")

if present then
  impatient.enable_profile()
end

local core_modules = {
  "plugins",
  "core.options",
  "core.autocmds",
  "core.mappings",
  "core.colors",
}

for _,  module in ipairs(core_modules) do
  local ok, err = pcall(require, module)
  if not ok then
    error("Error loading " .. module .. "\n\n" .. err)
  end
end
