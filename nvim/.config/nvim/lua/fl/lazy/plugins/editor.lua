---@diagnostic disable: inject-field
return {
  -- which-key
  {
    "folke/which-key.nvim",
    event = "BufRead",
    opts = {
      plugins = { spelling = true },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>cd", "<cmd>lua R('fl.functions').generate_compile_commands()<CR>", desc = "Compile commands" },
        {
          "<leader>cD",
          "<cmd>lua R('fl.functions').generate_compile_commands(true)<CR>",
          desc = "Compile commands with deps",
        },
        { "<leader>f", "<cmd>LazyFormat<CR>", desc = "Format" },
        {
          "<leader>F",
          function()
            if vim.b.autoformat == nil then
              vim.b.autoformat = false
            else
              vim.b.autoformat = not vim.b.autoformat
            end
            vim.notify("Autoformat toggled: " .. tostring(vim.b.autoformat), "info", {})
          end,
          desc = "Toggle auto format",
        },
        {
          "<leader>op",
          "<cmd>lua R('fl.functions').open_in_browser()<CR>",
          desc = "Open in browser",
        },
        { "<leader>p", "<cmd>w<CR><cmd>lua R('fl.functions').file_runner()<CR>", desc = "Runner" },
        { "<leader><leader>l", "<cmd>LspRestart<CR>", desc = "Restart LSP servers" },
        { "<leader><leader>o", "<cmd>Trouble diagnostics toggle<CR>", desc = "Toggle Trouble" },
        { "<leader><leader>p", "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>", desc = "Runner" },
        { "<leader><leader>s", "<cmd>lua R('fl.snippets').load()<CR>", desc = "Reload snippets" },
      })
    end,
  },

  {
    "psjay/buffer-closer.nvim",
    event = "BufRead",
    config = function()
      require("buffer-closer").setup({
        close_key = "<leader>q",
      })
    end,
  },

  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      auto_close = true,
      auto_preview = false,
      follow = false,
      pinned = true,
    },
    keys = {
      {
        "{",
        function()
          ---@diagnostic disable-next-line: missing-parameter
          require("trouble").prev()
          ---@diagnostic disable-next-line: missing-parameter
          require("trouble").jump()
        end,
        desc = "Trouble prev and jump",
      },
      {
        "}",
        function()
          ---@diagnostic disable-next-line: missing-parameter
          require("trouble").next()
          ---@diagnostic disable-next-line: missing-parameter
          require("trouble").jump()
        end,
        desc = "Trouble next and jump",
      },
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
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
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
      { "<leader>spe", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>gu",
        function()
          require("grug-far").grug_far({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Replace in files (grug-far)",
      },
    },
    config = function()
      require("grug-far").setup({})
    end,
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
    opts = {},
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
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      {
        "<C-n>",
        function()
          require("oil").open_float()
        end,
        desc = "Explorer Oil (cwd)",
      },
    },
    opts = {
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
      },
      columns = {
        "icon",
        -- "permissions",
        "size",
        -- "mtime",
      },
      keymaps = {
        ["h"] = "actions.parent",
        ["q"] = "actions.close",
      },
      float = {
        -- Padding around the floating window
        padding = 2,
        max_width = 100,
        max_height = 50,
        border = "rounded",
      },
    },
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
  },
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   branch = "v3.x",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --     "MunifTanjim/nui.nvim",
  --   },
  --   cmd = "Neotree",
  --   keys = {
  --     {
  --       "<C-n>",
  --       function()
  --         require("neo-tree.command").execute({
  --           toggle = true,
  --           dir = vim.fn.expand("%:p:h"),
  --           position = "float",
  --           reveal = true,
  --           reveal_force_cwd = true,
  --         })
  --       end,
  --       desc = "Explorer NeoTree (cwd)",
  --     },
  --     {
  --       "<leader>ne",
  --       function()
  --         require("neo-tree.command").execute({
  --           toggle = true,
  --           dir = vim.fn.expand("%:p:h"),
  --           position = "float",
  --           reveal = true,
  --           reveal_force_cwd = true,
  --         })
  --       end,
  --       desc = "Explorer NeoTree (cwd)",
  --     },
  --     {
  --       "<leader>be",
  --       function()
  --         require("neo-tree.command").execute({ source = "buffers", toggle = true })
  --       end,
  --       desc = "Buffer explorer",
  --     },
  --   },
  --   deactivate = function()
  --     vim.cmd([[Neotree close]])
  --   end,
  --   init = function()
  --     if vim.fn.argc(-1) == 1 then
  --       ---@diagnostic disable-next-line: param-type-mismatch
  --       local stat = vim.loop.fs_stat(vim.fn.argv(0))
  --       if stat and stat.type == "directory" then
  --         require("neo-tree")
  --       end
  --     end
  --   end,
  --   opts = {
  --     sources = { "filesystem", "document_symbols" },
  --     open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
  --     window = {
  --       height = 50,
  --     },
  --     filesystem = {
  --       bind_to_cwd = false,
  --       follow_current_file = { enabled = true },
  --       window = {
  --         mappings = {
  --           ["."] = "toggle_hidden",
  --           ["/"] = "fuzzy_sorter",
  --           ["<space>"] = "none",
  --           ["h"] = "navigate_up",
  --           ["l"] = "set_root",
  --           ["L"] = function(state)
  --             require("neo-tree.command").execute({ action = "close" })
  --             require("telescope.builtin").live_grep({
  --               search_dirs = { state.path },
  --               prompt_title = string.format("Grep in [%s]", vim.fs.basename(state.path)),
  --             })
  --           end,
  --         },
  --         fuzzy_finder_mappings = {
  --           ["<down>"] = "move_cursor_down",
  --           ["<C-n>"] = "move_cursor_down",
  --           ["<C-j>"] = "move_cursor_down",
  --           ["<up>"] = "move_cursor_up",
  --           ["<C-p>"] = "move_cursor_up",
  --           ["<C-k>"] = "move_cursor_up",
  --         },
  --       },
  --     },
  --     default_component_configs = {
  --       indent = {
  --         with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
  --         expander_collapsed = "",
  --         expander_expanded = "",
  --         expander_highlight = "NeoTreeExpander",
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require("neo-tree").setup(opts)
  --   end,
  -- },

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

  -- Track
  {
    "dharmx/track.nvim",
    cmd = {
      "Track",
      "Mark",
      "MarkOpened",
      "StashBundle",
      "RestoreBundle",
      "AlternateBundle",
      "Unmark",
    },
    keys = {
      { "gM", "<cmd>Mark<CR>", desc = "Mark file" },
      { "gm", "<cmd>Track<CR>", desc = "Open marks" },
    },
    config = function()
      require("track").setup({})
    end,
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
      -- "akinsho/toggleterm.nvim", -- alternative repl provider
      "benlubas/molten-nvim", -- alternative repl provider
      "nvimtools/hydra.nvim",
    },
    ft = { "python" },
    keys = {
      -- { "<leader>ip", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
      -- {
      --   "<leader>ih",
      --   function()
      --   end,
      -- },
    },
    config = function()
      local nn = require("notebook-navigator")
      nn.setup({
        repl_provider = "molten",
      })
      local Hydra = require("hydra")
      Hydra({
        -- string? only used in auto-generated hint
        name = "NotebookNavigator",
        -- string | string[] modes where the hydra exists, same as `vim.keymap.set()` accepts
        mode = "n",
        hint = [[ Hint String  ]],
        config = {
          hint = {
            type = "window",
            position = "bottom",
          },
        },
        heads = {
          {
            "p",
            function()
              require("notebook-navigator").run_and_move()
            end,
            {},
          },
        },
      })
    end,
  },

  {
    "David-Kunz/gen.nvim",
    cmd = { "Gen" },
    keys = {
      { "<leader>og", "<cmd>Gen Generate_Code<cr>" },
    },
    config = function()
      local opts = {
        model = "llama3.1:8b", -- The default model to use.
        host = "localhost", -- The host running the Ollama service.
        port = "11434", -- The port on which the Ollama service is listening.
        quit_map = "q", -- set keymap for close the response window
        retry_map = "<c-r>", -- set keymap to re-send the current prompt
        init = function(_)
          pcall(io.popen, "ollama serve > /dev/null 2>&1 &")
        end,
        -- Function to initialize Ollama
        command = function(options)
          ---@diagnostic disable-next-line: unused-local
          local body = { model = options.model, stream = true }
          return "curl --silent --no-buffer -X POST http://"
            .. options.host
            .. ":"
            .. options.port
            .. "/api/chat -d $body"
        end,
        -- The command for the Ollama service. You can use placeholders $prompt, $model and $body (shellescaped).
        -- This can also be a command string.
        -- The executed command must return a JSON object with { response, context }
        -- (context property is optional).
        -- list_models = '<omitted lua function>', -- Retrieves a list of model names
        display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split".
        show_prompt = false, -- Shows the prompt submitted to Ollama.
        show_model = false, -- Displays which model you are using at the beginning of your chat session.
        no_auto_close = false, -- Never closes the window automatically.
        debug = false, -- Prints errors and the command which is run.
      }
      require("gen").setup(opts)
      require("gen").prompts["Generate_Code"] = {
        prompt = "Generate code for the following problem: $input. Only ouput the result in format ```$filetype\n...\n```",
      }
    end,
  },
}
