return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local treesitter_config = require("nvim-treesitter.configs")
      ---@diagnostic disable-next-line: missing-fields
      treesitter_config.setup({
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
              smart_rename = "<leader>rr",
            },
          },
        },
        textsubjects = {
          enable = true,
          keymaps = {
            ["."] = "textsubjects-smart",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["if"] = "@function.outer",
              ["im"] = "@block.outer",
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [")"] = "@function.outer",
            },
            goto_next_end = {
              ["}"] = "@block.outer",
            },
            goto_previous_start = {
              ["("] = "@function.outer",
              ["{"] = "@block.outer",
            },
          },
        },
      })
      vim.keymap.set("v", "m", ':lua require("tsht").nodes()<CR>', { noremap = true, silent = true })
    end,
  },
  -- Show context for large scopes
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    config = function()
      require("treesitter-context").setup({})
    end,
  },
  -- Various little helpers.
  {
    "nvim-treesitter/nvim-treesitter-refactor",
    event = "BufReadPost",
  },
  "nvim-treesitter/nvim-treesitter-textobjects",
  "RRethy/nvim-treesitter-textsubjects",
  "mfussenegger/nvim-ts-hint-textobject",
  -- Swap things around
  {
    "mizlan/iswap.nvim",
    keys = {
      { "<leader>is", "<cmd>ISwapWith<cr>", desc = "Swap argument with other" },
    },
    config = function()
      require("iswap").setup({})
    end,
  },
  -- Detect more filetypes correctly
  {
    "nvim-lua/plenary.nvim",
    config = function()
      require("plenary.filetype").add_file("fl")
    end,
  },

  -- log file highlighting
  {
    "fei6409/log-highlight.nvim",
    event = "BufReadPost",
    config = function()
      require("log-highlight").setup({})
    end,
  },
}
