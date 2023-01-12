return {
  -- snippets
  {
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip').config.set_config {
        history = true,
        updateevents = "TextChanged,TextChangedI",
      }
      require('fl.snippets').load()
      local snippets_group = vim.api.nvim_create_augroup('ReloadSnippetsOnWrite', { clear = true })
      vim.api.nvim_create_autocmd('BufWritePost', {
        pattern = 'snippets.lua',
        callback = function()
          R('fl.snippets').load()
          require 'cmp_luasnip'.clear_cache()
        end,
        group = snippets_group,
      })
    end
  },

  -- completion
  {
    'hrsh7th/nvim-cmp',
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lua',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      require('fl.completion')
    end,
  },

  -- which-key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      key_labels = { ["<leader>"] = "SPC" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      local leader = {
        a = {
          s = { "<cmd>ISwapWith<CR>", "Swap argument with other" }
        },
        c = {
          d = { "<cmd>lua R('fl.functions').generate_compile_commands()<CR>", "Compile commands" },
          D = { "<cmd>lua R('fl.functions').generate_compile_commands(true)<CR>", "Compile commands" }
        },
        f = { "<cmd>lua vim.lsp.buf.format()<CR>", "LSP Format" },
        i = {
          d = { "<cmd>lua require('neogen').generate()<CR>", "Generate documentation" },
          s = { "<cmd>ISwapWith<CR>", "Swap argument with other" }
        },
        k = { "<cmd>lua R('fl.functions').leap_identifiers()<CR>", "Leap Identifiers" },
        o = {
          p = { "<cmd>lua R('fl.functions').open_in_browser()<CR>", "Open in browser" },
        },
        p = { "<cmd>w<CR><cmd>lua R('fl.functions').file_runner()<CR>", "Runner" },
        q = { "<cmd>bdelete!<CR>", "Close Buffer" },
        s = {
          name = "+search",
        }
      }
      wk.register(leader, { prefix = "<leader>" })

      local leaderleader = {
        h = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
        s = { "<cmd>lua R('fl.snippets').load()<CR>", "Reload snippets" },
        l = { "<cmd>LspRestart<CR>", "Restart LSP servers" },
        p = { "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>", "Runner" },
      }
      wk.register(leaderleader, { prefix = "<leader><leader>" })

      wk.register({ ["L"] = { "<cmd>lua R('fl.functions').leap_identifiers()<CR>", "Leap Identifiers" } })
      wk.register({ ["<C-k>"] = {
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
            symbol_width = 50,
            symbol_type_width = 12,
          })
        end,
        "Goto Symbol",
      } })
      wk.register({ ["<C-l>"] = { "<cmd>lua require('telescope.builtin').buffers()<cr>", "Buffers" } })
      wk.register({ ["<C-p>"] = { "<cmd>lua R('fl.functions').myfiles({})<cr>", "Files" } })
    end
  },

  -- easily jump to any location and enhanced f/t motions for Leap
  {
    "ggandor/leap.nvim",
    event = "VeryLazy",
    dependencies = { { "ggandor/flit.nvim", opts = { labeled_modes = "nv" } } },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
    end,
  },

  -- illuminate
  {
    "RRethy/vim-illuminate",
    event = "BufRead",
    opts = { delay = 200 },
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
    -- stylua: ignore
    keys = {
      { "]]", function() require("illuminate").goto_next_reference(false) end, desc = "Next Reference", },
      { "[[", function() require("illuminate").goto_prev_reference(false) end, desc = "Prev Reference" },
    },
  },

  -- persistence
  { 
    'folke/persistence.nvim',
    event = 'BufRead', -- this will only start session saving when an actual file was opened
    config = function()
      require('persistence').setup()
    end,
  },

  -- mini
  {
    'echasnovski/mini.nvim',
    event = 'BufRead',
    config = function()
      require('mini.indentscope').setup {
        symbol = '│',
        draw = {
          animation = function() return 10 end,
        }
      }
      require('mini.ai').setup {}
      require("mini.pairs").setup()
    end
  },

  -- indent blankline
  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufRead',
    config = function()
      vim.g.indentLine_enabled = 1
      vim.g.indentLine_char = '│'
      vim.g.indentLine_fileType = { 'c', 'cpp', 'lua', 'python', 'vim' }
      vim.g.indent_blankline_char_highlight = 'LineNr'
      vim.g.indent_blankline_show_trailing_blankline_indent = false
    end
  },

  -- comments
  { 
    'numToStr/Comment.nvim',
    event = 'BufRead',
    config = function()
      require('Comment').setup {}
      vim.keymap.set('n', '<space>x', '<plug>(comment_toggle_linewise_current)', { silent = true })
      vim.keymap.set('x', '<space>x', '<plug>(comment_toggle_linewise_visual)', { silent = true })
    end
  },

  -- linediff
  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff'
  },

  -- nnn
  { 
    'mcchrish/nnn.vim',
    config = function()
      require('nnn').setup({
        command = 'nnn -o -A',
        set_default_mappings = 0,
        replace_netrw = 1,
        layout = { window = { width = 0.6, height = 0.7, xoffset = 0.95, highlight = 'Debug' } },
      })
    end,
    keys = {
      {
        "<c-n>",
        function()
          ---@diagnostic disable-next-line: missing-parameter
          local path = vim.fn.expand('%:p')
          local nnn_command = path == '' and 'NnnPicker' or ('NnnPicker' .. path)
          vim.api.nvim_command(nnn_command)
        end
      },
    },
  }
}
