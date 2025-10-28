return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("rose-pine").setup({
        --- @usage 'auto'|'main'|'moon'|'dawn'
        variant = "dawn",
      })

      vim.cmd("colorscheme rose-pine")

      local palette = require("rose-pine.palette")
      vim.api.nvim_set_hl(0, "SnacksIndent", { fg = palette.highlight_med })
    end,
  },
}
