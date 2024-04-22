---@diagnostic disable: inject-field
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

      -- leader
      local leader = {
        c = {
          d = { "<cmd>lua R('fl.functions').generate_compile_commands()<CR>", "Compile commands" },
          D = { "<cmd>lua R('fl.functions').generate_compile_commands(true)<CR>", "Compile commands" },
        },
        f = { "<cmd>LazyFormat<CR>", "Format" },
        F = {
          function()
            if vim.b.autoformat == nil then
              vim.b.autoformat = false
            else
              vim.b.autoformat = not vim.b.autoformat
            end
            vim.notify("Autoformat toggled: " .. tostring(vim.b.autoformat), "info", {})
          end,
          "Toggle auto format",
        },
        i = {},
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

      -- leader leader
      local leaderleader = {
        l = { "<cmd>LspRestart<CR>", "Restart LSP servers" },
        o = { "<cmd>TroubleToggle<CR>", "Toggle Trouble" },
        p = { "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>", "Runner" },
        s = { "<cmd>lua R('fl.snippets').load()<CR>", "Reload snippets" },
      }
      wk.register(leaderleader, { prefix = "<leader><leader>" })
    end,
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      auto_close = true,
      mode = "document_diagnostics",
    },
    -- stylua: ignore
    keys = {
      { "gR",function() require("trouble").open("lsp_references") end, desc = "Trouble lsp references", },
    },
  },

  -- snippets
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
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

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      modes = {
        search = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({ mode = "fuzzy" })
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o", "x" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Flash Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
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

  -- search/replace treesitter structures
  {
    "cshuaimin/ssr.nvim",
    keys = {
      {
        "<leader>ssr",
        function()
          require("ssr").open()
        end,
        desc = "Structural Search/Replace",
      },
    },
  },

  -- tmux integration
  {
    "aserowy/tmux.nvim",
    -- stylua: ignore
    keys = {
      { "<M-h>", function() require("tmux").move_left() end, desc = "Tmux Left" },
      { "<M-j>", function() require("tmux").move_bottom() end, desc = "Tmux Down" },
      { "<M-k>", function() require("tmux").move_top() end, desc = "Tmux Up" },
      { "<M-l>", function() require("tmux").move_right() end, desc = "Tmux Right" },
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

  -- terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      on_close = function(terminal)
        terminal.send("history clear-session")
      end,
    },
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
    version = false,
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
    main = "ibl",
    config = function()
      local palette = require("rose-pine.palette")
      local highlight = {
        "FLIndent",
      }
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, highlight[1], { fg = palette.highlight_med })
      end)
      require("ibl").setup({ indent = { highlight = highlight } })
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
    keys = {
      {
        "<space>x",
        mode = { "n" },
        "<plug>(comment_toggle_linewise_current)",
        desc = "Comment",
      },
      {
        "<space>x",
        mode = { "x" },
        "<plug>(comment_toggle_linewise_visual)",
        desc = "Comment",
      },
    },
    config = function()
      require("Comment").setup()
    end,
  },

  -- linediff
  {
    "AndrewRadev/linediff.vim",
    cmd = "Linediff",
  },

  -- {
  --   "ThePrimeagen/harpoon",
  --   event = "BufRead",
  --   keys = {
  --     {
  --       "mm",
  --       mode = { "n" },
  --       function()
  --         require("harpoon.mark").add_file()
  --         require("notify")("harpoon added", "info")
  --       end,
  --       desc = "Harpoon add_file",
  --     },
  --     {
  --       "mo",
  --       mode = { "n" },
  --       function()
  --         require("harpoon.ui").toggle_quick_menu()
  --       end,
  --       desc = "Harpoon toggle_quick_menu",
  --     },
  --     {
  --       "<c-f>",
  --       mode = { "n" },
  --       "<cmd>Telescope harpoon marks<cr>",
  --       desc = "Harpoon toggle_quick_menu",
  --     },
  --   },
  --   config = function()
  --     require("telescope").load_extension("harpoon")
  --   end,
  -- },

  -- trail blazer
  {
    "LeonHeidelbach/trailblazer.nvim",
    keys = {
      { "mm", [[<cmd>TrailBlazerNewTrailMark<cr>]], desc = "New Trail Mark" },
      { "mp", [[<cmd>TrailBlazerTrackBack<cr>]], desc = "Pop Trail Mark" },
      {
        "mk",
        function()
          require("trailblazer").move_to_nearest(nil, "up", nil)
        end,
        desc = "Nearest Trail Mark Up",
      },
      {
        "mj",
        function()
          require("trailblazer").move_to_nearest(nil, "down", nil)
        end,
        desc = "Nearest Trail Mark Down",
      },
      {
        "ml",
        function()
          require("trailblazer").toggle_trail_mark_list("quickfix")
        end,
        desc = "Trail Mark List",
      },
    },
    config = function()
      require("trailblazer").setup({
        auto_save_trailblazer_state_on_exit = true,
        auto_load_trailblazer_state_on_enter = true,
        trail_options = {
          trail_mark_in_text_highlights_enabled = false,
        },
        force_mappings = {},
      })
    end,
  },

  -- nnn
  -- {
  --   "mcchrish/nnn.vim",
  --   config = function()
  --     require("nnn").setup({
  --       command = "nnn -o -A",
  --       set_default_mappings = 0,
  --       replace_netrw = 1,
  --       layout = { window = { width = 0.6, height = 0.7, xoffset = 0.95, highlight = "Debug" } },
  --     })
  --   end,
  --   keys = {
  --     {
  --       "<c-n>",
  --       function()
  --         ---@diagnostic disable-next-line: missing-parameter
  --         local path = vim.fn.expand("%:p")
  --         local nnn_command = path == "" and "NnnPicker" or ("NnnPicker" .. path)
  --         vim.api.nvim_command(nnn_command)
  --       end,
  --     },
  --   },
  -- },

  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      {
        "<C-n>",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = vim.fn.expand("%:p:h"),
            position = "float",
            reveal = true,
            reveal_force_cwd = true,
          })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>ne",
        function()
          require("neo-tree.command").execute({
            toggle = true,
            dir = vim.fn.expand("%:p:h"),
            position = "float",
            reveal = true,
            reveal_force_cwd = true,
          })
        end,
        desc = "Explorer NeoTree (cwd)",
      },
      {
        "<leader>be",
        function()
          require("neo-tree.command").execute({ source = "buffers", toggle = true })
        end,
        desc = "Buffer explorer",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      if vim.fn.argc(-1) == 1 then
        ---@diagnostic disable-next-line: param-type-mismatch
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      sources = { "filesystem", "document_symbols" },
      open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
      window = {
        height = 50,
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        window = {
          mappings = {
            ["/"] = "fuzzy_finder",
            ["<space>"] = "none",
            ["h"] = "navigate_up",
            ["l"] = "set_root",
            ["L"] = function(state)
              require("neo-tree.command").execute({ action = "close" })
              require("telescope.builtin").live_grep({
                search_dirs = { state.path },
                prompt_title = string.format("Grep in [%s]", vim.fs.basename(state.path)),
              })
            end,
          },
          fuzzy_finder_mappings = {
            ["<down>"] = "move_cursor_down",
            ["<C-n>"] = "move_cursor_down",
            ["<C-j>"] = "move_cursor_down",
            ["<up>"] = "move_cursor_up",
            ["<C-p>"] = "move_cursor_up",
            ["<C-k>"] = "move_cursor_up",
          },
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)
    end,
  },

  {
    "mhinz/vim-signify",
    keys = {
      { "<leader>is", "<cmd>SignifyEnable<CR>", desc = "Enable Signify" },
    },
  },

  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = {
      { "<leader>tt", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
      -- Your setup opts here
    },
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    build = ":UpdateRemotePlugins",
    init = function()
      -- this is an example, not a default. Please see the readme for more configuration options
      -- vim.g.molten_output_win_max_height = 12
    end,
  },
  {
    "GCBallesteros/NotebookNavigator.nvim",
    dependencies = {
      "echasnovski/mini.comment",
      -- "hkupty/iron.nvim", -- repl provider
      -- "akinsho/toggleterm.nvim", -- alternative repl provider
      "benlubas/molten-nvim", -- alternative repl provider
      "anuvyklack/hydra.nvim",
    },
    keys = {
      { "<leader>P", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
    },
    config = function()
      local nn = require("notebook-navigator")
      nn.setup({
        repl_provider = "molten",
        activate_hydra_keys = "<leader>hn",
        show_hydra_hint = false,
        hydra_keys = {
          comment = "c",
          run = "p",
          run_and_move = "P",
          move_up = "k",
          move_down = "j",
          add_cell_before = "i",
          add_cell_after = "x",
        },
      })
    end,
  },
}
