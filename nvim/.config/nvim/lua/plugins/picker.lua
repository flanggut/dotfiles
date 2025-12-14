return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>sf",
        function()
          Snacks.picker.lines({ layout = { preset = "select" } })
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>si",
        function()
          Snacks.picker.treesitter()
        end,
        desc = "Treesitter",
      },
      {
        "<leader>sl",
        function()
          Snacks.picker.recent({ filter = { cwd = true } })
        end,
        desc = "Local Files",
      },
      {
        "<leader>sP",
        function()
          Snacks.picker.files({ dirs = { vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }, title = "Lazy Plugins" })
        end,
        desc = "Vim Plugins",
      },
      {
        "<C-k>",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "Goto Symbol",
      },
      {
        "<C-l>",
        function()
          Snacks.picker.buffers({ layout = { preset = "select" } })
        end,
        desc = "Buffers",
      },
      {
        "<leader>sL",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent Files",
      },
    },
    opts = {
      bigfile = {
        line_length = 100000, -- average line length (useful for minified files)
      },
    },
  },
}
