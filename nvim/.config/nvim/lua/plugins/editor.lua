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
        { "<c-/>", "<cmd>lua Snacks.terminal()<CR>", desc = "🦊 Toggle Terminal" },
        --
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
        { "<leader>un", "<cmd>lua Snacks.notifier.hide()<CR>", desc = "🦊 Hide all notifications" },
        --
        { "<leader><leader>l", "<cmd>LspRestart<CR>", desc = "Restart LSP servers" },
        { "<leader><leader>o", "<cmd>Trouble diagnostics toggle<CR>", desc = "Toggle Trouble" },
        { "<leader><leader>p", "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>", desc = "Runner" },
        { "<leader><leader>s", "<cmd>lua R('fl.snippets').load()<CR>", desc = "Reload snippets" },
      })
    end,
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
  },

  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>gu",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Replace in files (grug-far)",
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
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
      local Rule = require("nvim-autopairs.rule")
      local npairs = require("nvim-autopairs")
      npairs.add_rule(Rule("```", "```", { "markdown", "vimwiki", "rmarkdown", "rmd", "pandoc", "hgcommit" }))
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

  -- file explorer
  {
    "echasnovski/mini.files",
    keys = {
      {
        "<C-n>",
        function()
          if not MiniFiles.close() then
            MiniFiles.open(vim.api.nvim_buf_get_name(0))
          end
        end,
        desc = "Mini Files (cwd)",
      },
    },
    config = function()
      require("mini.files").setup({
        mappings = {
          go_in_plus = "<CR>",
        },
      })
    end,
  },

  {
    "mhinz/vim-signify",
    keys = {
      { "<leader>is", "<cmd>SignifyEnable<CR>", desc = "Enable Signify" },
    },
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
