return {
  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = "BufReadPost",
    config = function()
      require 'fl.treesitter'
    end
  },
  -- Show context for large scopes
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require 'treesitter-context'.setup {}
    end
  },
  -- Various little helpers.
  'nvim-treesitter/nvim-treesitter-refactor',
  'nvim-treesitter/nvim-treesitter-textobjects',
  'nvim-treesitter/playground',
  'RRethy/nvim-treesitter-textsubjects',
  'mfussenegger/nvim-ts-hint-textobject',
  -- Swap things around
  {
    'mizlan/iswap.nvim',
    config = function ()
      require('iswap').setup{}
    end
  },
  -- Detect more filetypes correctly
  {
    'nvim-lua/plenary.nvim',
    config = function()
      require 'plenary.filetype'.add_file("fl")
    end
  }
}
