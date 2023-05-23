return {
  -- which-key
  {
    "folke/which-key.nvim",
    event = "BufRead",
    opts = {
      plugins = { spelling = true },
      key_labels = { ["<leader>"] = "SPC" },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      local leader = {
        c = {
          d = { "<cmd>lua R('fl.functions').generate_compile_commands()<CR>", "Compile commands" },
          D = { "<cmd>lua R('fl.functions').generate_compile_commands(true)<CR>", "Compile commands" },
        },
        i = {
          d = { "<cmd>lua require('neogen').generate()<CR>", "Generate documentation" },
        },
        k = { "<cmd>lua R('fl.functions').leap_identifiers()<CR>", "Leap Identifiers" },
        o = {
          p = { "<cmd>lua R('fl.functions').open_in_browser()<CR>", "Open in browser" },
        },
        p = { "<cmd>w<CR><cmd>lua R('fl.functions').file_runner()<CR>", "Runner" },
        q = { "<cmd>bdelete!<CR>", "Close Buffer" },
        s = {
          name = "+search",
        },
      }
      wk.register(leader, { prefix = "<leader>" })

      local leaderleader = {
        s = { "<cmd>lua R('fl.snippets').load()<CR>", "Reload snippets" },
        l = { "<cmd>LspRestart<CR>", "Restart LSP servers" },
        p = { "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>", "Runner" },
      }
      wk.register(leaderleader, { prefix = "<leader><leader>" })

      wk.register({ ["L"] = { "<cmd>lua R('fl.functions').leap_identifiers()<CR>", "Leap Identifiers" } })
    end,
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      require("luasnip").config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })
      require("fl.snippets").load()
      local snippets_group = vim.api.nvim_create_augroup("ReloadSnippetsOnWrite", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "snippets.lua",
        callback = function()
          R("fl.snippets").load()
          require("cmp_luasnip").clear_cache()
        end,
        group = snippets_group,
      })
    end,
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

  -- trail blazer
  {
    "LeonHeidelbach/trailblazer.nvim",
    config = function()
      require("trailblazer").setup({
        -- your custom config goes here
      })
    end,
  },

  -- surround
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
        { opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
        { opts.mappings.delete, desc = "Delete surrounding" },
        { opts.mappings.find, desc = "Find right surrounding" },
        { opts.mappings.find_left, desc = "Find left surrounding" },
        { opts.mappings.highlight, desc = "Highlight surrounding" },
        { opts.mappings.replace, desc = "Replace surrounding" },
        { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      ---@diagnostic disable-next-line: missing-parameter
      return vim.list_extend(mappings, keys)
    end,
    opts = {
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
      },
    },
    config = function(_, opts)
      -- use gz mappings instead of s to prevent conflict with leap
      require("mini.surround").setup(opts)
    end,
  },

  -- search/replace in multiple files
  {
    "windwp/nvim-spectre",
    -- stylua: ignore
    keys = {
      { "<leader>sg", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    },
  },

  -- tmux integration
  {
    "aserowy/tmux.nvim",
    keys = {
      { "<M-h>", [[<cmd>lua require("tmux").move_left()<cr>]], desc = "Tmux Left" },
      { "<M-j>", [[<cmd>lua require("tmux").move_bottom()<cr>]], desc = "Tmux Down" },
      { "<M-k>", [[<cmd>lua require("tmux").move_up()<cr>]], desc = "Tmux Up" },
      { "<M-l>", [[<cmd>lua require("tmux").move_right()<cr>]], desc = "Tmux Right" },
    },
    config = function()
      return require("tmux").setup({
        navigation = {
          -- enables default keybindings (C-hjkl) for normal mode
          enable_default_keybindings = false,
        },
        resize = {
          -- enables default keybindings (A-hjkl) for normal mode
          enable_default_keybindings = false,
        },
      })
    end,
  },

  -- persistence
  {
    "folke/persistence.nvim",
    event = "BufRead", -- this will only start session saving when an actual file was opened
    config = function()
      require("persistence").setup()
    end,
  },

  -- mini
  {
    "echasnovski/mini.nvim",
    event = "BufRead",
    config = function()
      require("mini.ai").setup({})
      require("mini.cursorword").setup({
        delay = 150,
      })
      require("mini.splitjoin").setup({
        mappings = {
          toggle = "gj",
          split = "",
          join = "",
        },
      })
    end,
  },

  -- indent blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufRead",
    config = function()
      require("indent_blankline").setup({
        space_char_blankline = " ",
        show_current_context = true,
        show_current_context_start = true,
      })
    end,
  },

  -- auto pairs
  {
    "windwp/nvim-autopairs",
    event = "BufRead",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- comments
  {
    "numToStr/Comment.nvim",
    event = "BufRead",
    config = function()
      require("Comment").setup({})
      vim.keymap.set("n", "<space>x", "<plug>(comment_toggle_linewise_current)", { silent = true })
      vim.keymap.set("x", "<space>x", "<plug>(comment_toggle_linewise_visual)", { silent = true })
    end,
  },

  -- linediff
  {
    "AndrewRadev/linediff.vim",
    cmd = "Linediff",
  },

  -- nnn
  {
    "mcchrish/nnn.vim",
    config = function()
      require("nnn").setup({
        command = "nnn -o -A",
        set_default_mappings = 0,
        replace_netrw = 1,
        layout = { window = { width = 0.6, height = 0.7, xoffset = 0.95, highlight = "Debug" } },
      })
    end,
    keys = {
      {
        "<c-n>",
        function()
          ---@diagnostic disable-next-line: missing-parameter
          local path = vim.fn.expand("%:p")
          local nnn_command = path == "" and "NnnPicker" or ("NnnPicker" .. path)
          vim.api.nvim_command(nnn_command)
        end,
      },
    },
  },
}
