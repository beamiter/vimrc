local present, plugin = pcall(require, "cmp")

if not present then
  return
end

local default = {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  formatting = {
    format = function(entry, vim_item)
      local icons = require "plugins.configs.lspkind_icons"
      vim_item.kind = string.format("%s %s", icons[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        nvim_lua = "[Lua]",
        buffer = "[BUF]",
      })[entry.source.name]
      return vim_item
    end,
  },
  mapping = {
    ["<C-p>"] = plugin.mapping.select_prev_item(),
    ["<C-n>"] = plugin.mapping.select_next_item(),
    ["<C-k>"] = plugin.mapping.select_prev_item(),
    ["<C-j>"] = plugin.mapping.select_next_item(),
    ['<C-b>'] = plugin.mapping(plugin.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = plugin.mapping(plugin.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = plugin.mapping(plugin.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = plugin.config.disable,
    ['<C-e>'] = plugin.mapping({
      i = plugin.mapping.abort(),
      c = plugin.mapping.close(),
    }),
    ['<CR>'] = plugin.mapping.confirm({ select = true }),
    ["<Tab>"] = plugin.mapping(function(fallback)
      if plugin.visible() then
        plugin.select_next_item()
      elseif require("luasnip").expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = plugin.mapping(function(fallback)
      if plugin.visible() then
        plugin.select_prev_item()
      elseif require("luasnip").jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "nvim_lua" },
    { name = "path" },
  },
}
