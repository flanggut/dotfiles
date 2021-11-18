local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup {
  experimental = {
    ghost_text = true,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  sources = {
    { name = 'nvim_lua'},
    { name = 'nvim_lsp'},
    { name = 'luasnip'},
    { name = 'buffer', keyword_length = 4},
    { name = 'path'},
  },
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end
  },
  formatting = {
    format = function(entry, vim_item)
      local lspkind_format = require'lspkind'.cmp_format({
        with_text = true,
        menu = {
          nvim_lua = "[api]",
          nvim_lsp = "[lsp]",
          luasnip = "[snp]",
          buffer = "[buf]",
          path = "[pth]",
        },
        maxwidth = 60
      })
      vim_item.abbr = vim_item.abbr:gsub("^%s+", "")
      return lspkind_format(entry, vim_item)
    end
  },
  mapping = {
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-f>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<C-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ['<C-l>'] = function(fallback)
      if luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<C-j>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<C-k>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
}

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline('/', {
--   sources = {
--     { name = 'buffer' }
--   }
-- })

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })

