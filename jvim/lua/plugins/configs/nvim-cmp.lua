local present, plugin = pcall(require, "cmp")

if not present then
  return
end

local default = {
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  mapping = {
    ['<C-b>'] = plugin.mapping(plugin.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = plugin.mapping(plugin.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = plugin.mapping(plugin.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = plugin.config.disable, -- Specify `plugin.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = plugin.mapping({
      i = plugin.mapping.abort(),
      c = plugin.mapping.close(),
    }),
    ['<CR>'] = plugin.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
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
  sources = plugin.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
}

-- Set configuration for specific filetype.
plugin.setup.filetype('gitcommit', {
  sources = plugin.config.sources({
    { name = 'plugin_git' }, -- You can specify the `plugin_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})
-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
plugin.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
plugin.setup.cmdline(':', {
  sources = plugin.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


plugin.setup(default)
