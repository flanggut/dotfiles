return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-refactor",
    },
    opts = {
      auto_install = true,
      highlight = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = ",",
          node_incremental = ",",
        },
      },
      refactor = {
        smart_rename = {
          enable = true,
          keymaps = {
            smart_rename = "<leader>rt",
          },
        },
      },
    },
  },
  -- Show context for large scopes
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    config = function()
      require("treesitter-context").setup({})
    end,
  },
  -- Detect more filetypes correctly
  {
    "nvim-lua/plenary.nvim",
    config = function()
      require("plenary.filetype").add_file("fl")
    end,
  },
}
