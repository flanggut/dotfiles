return {
  -- completion
  { "hrsh7th/nvim-cmp", enabled = false },
  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- see the "default configuration" section below for full documentation on how to define
      -- your own keymap. when defining your own, no keybinds will be assigned automatically.
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = {
          function(cmp)
            if cmp.windows.autocomplete.win:is_open() then
              return cmp.select_and_accept()
            end
          end,
          "fallback",
        },

        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },

        ["<C-p>"] = { "scroll_documentation_up", "fallback" },
        ["<C-n>"] = { "scroll_documentation_down", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.is_in_snippet() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
    },
  },
}
