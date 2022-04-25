local treesitter_config = require 'nvim-treesitter.configs'
treesitter_config.setup {
  ensure_installed = 'all',
  ignore_install = { 'elixir', 'phpdoc' },
  highlight = {enable = true},
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = ',',
      node_incremental = ',',
    }
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
      ['.'] = 'textsubjects-smart',
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
  playground = {
    enable = true,
  },
}
vim.api.nvim_set_keymap('o', 'm', ':<C-U>lua require("tsht").nodes()<CR>', {noremap = false, silent = true})
vim.api.nvim_set_keymap('v', 'm', ':lua require("tsht").nodes()<CR>', {noremap = true, silent = true})
