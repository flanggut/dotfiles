---@diagnostic disable: inject-field
return {
  -- which-key
  {
    "folke/which-key.nvim",
    opts = {
      plugins = { spelling = true },
      spec = {
        { "<leader>x", "gcc", mode = "n", noremap = false, nowait = true },
        { "<leader>x", "gc", mode = "v", noremap = false, nowait = true },
        { "<leader>f", "<cmd>LazyFormat<CR>", desc = "Format" },
        { "<leader>cd", "<cmd>lua R('fl.functions').generate_compile_commands()<CR>", desc = "Compile commands" },
        {
          "<leader>cD",
          "<cmd>lua R('fl.functions').generate_compile_commands(true)<CR>",
          desc = "Compile commands with deps",
        },
        {
          "<leader>F",
          function()
            if vim.b.autoformat == nil then
              vim.b.autoformat = false
            else
              vim.b.autoformat = not vim.b.autoformat
            end
            vim.notify("Autoformat toggled: " .. tostring(vim.b.autoformat), vim.log.levels.INFO, {})
          end,
          desc = "Toggle auto format",
        },
        {
          "<leader>op",
          "<cmd>lua R('fl.functions').open_in_browser()<CR>",
          desc = "Open in browser",
        },
        { "<leader>p", "<cmd>w<CR><cmd>lua R('fl.functions').file_runner()<CR>", desc = "Runner" },
        --
        { "<leader><leader>l", "<cmd>LspRestart<CR>", desc = "Restart LSP servers" },
        { "<leader><leader>p", "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>", desc = "Runner" },
        { "<leader><leader>s", "<cmd>lua R('fl.snippets').load()<CR>", desc = "Reload snippets" },
      },
    },
  },

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
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump({ mode = "fuzzy" })
        end,
        desc = "Flash",
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
      { "<M-h>", function() require("tmux").move_left() end,   desc = "Tmux Left" },
      { "<M-j>", function() require("tmux").move_bottom() end, desc = "Tmux Down" },
      { "<M-k>", function() require("tmux").move_top() end,    desc = "Tmux Up" },
      { "<M-l>", function() require("tmux").move_right() end,  desc = "Tmux Right" },
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

  -- linediff
  {
    "AndrewRadev/linediff.vim",
    cmd = "Linediff",
  },

  -- file explorer
  {
    "stevearc/oil.nvim",
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    event = "VeryLazy",
    keys = {
      {
        "<C-n>",
        function()
          require("oil").open_float()
        end,
        desc = "Oil Files (cwd)",
      },
    },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      keymaps = {
        -- See :help oil-actions for a list of all available actions
        ["l"] = { "actions.select", mode = "n" },
        ["h"] = { "actions.parent", mode = "n" },
        ["f"] = {
          function()
            local dirname = require("oil").get_current_dir()
            require("oil").close()
            require("fzf-lua").live_grep_native({
              cwd = dirname,
            })
          end,
          mode = "n",
        },
        ["y"] = {
          function()
            local dirname = require("oil").get_current_dir()
            local fname = require("oil").get_cursor_entry().name
            vim.fn.setreg(vim.v.register, dirname .. fname)
            require("oil").close()
          end,
          mode = "n",
        },
        ["q"] = { "actions.close", mode = "n" },
        ["<C-n>"] = { "actions.close", mode = "n" },
      },
      float = {
        max_width = 0.5,
        max_height = 0.6,
      },
    },
  },

  -- {
  --   "echasnovski/mini.files",
  --   keys = {
  --     {
  --       "<C-n>",
  --       function()
  --         if not MiniFiles.close() then
  --           MiniFiles.open(vim.api.nvim_buf_get_name(0))
  --         end
  --       end,
  --       desc = "Mini Files (cwd)",
  --     },
  --   },
  --   config = function()
  --     require("mini.files").setup({
  --       mappings = {
  --         go_in_plus = "<CR>",
  --       },
  --     })
  --     -- Yank in register full path of entry under cursor
  --     local yank_path = function()
  --       local path = (MiniFiles.get_fs_entry() or {}).path
  --       if path == nil then
  --         return vim.notify("Cursor is not on valid entry")
  --       end
  --       vim.fn.setreg(vim.v.register, path)
  --       MiniFiles.close()
  --     end
  --
  --     -- Live grep in directory
  --     local live_grep = function()
  --       local path = (MiniFiles.get_fs_entry() or {}).path
  --       if path == nil then
  --         return vim.notify("Cursor is not on valid entry")
  --       end
  --       MiniFiles.close()
  --       local dirname = vim.fs.dirname(path)
  --       require("fzf-lua").live_grep_native({
  --         cwd = dirname,
  --       })
  --     end
  --
  --     vim.api.nvim_create_autocmd("User", {
  --       callback = function(args)
  --         local b = args.data.buf_id
  --         vim.keymap.set("n", "<c-l>", live_grep, { buffer = b, desc = "Live Grep current path" })
  --         vim.keymap.set("n", "gy", yank_path, { buffer = b, desc = "Yank path" })
  --       end,
  --       pattern = "MiniFilesBufferCreate",
  --     })
  --   end,
  -- },

  {
    "mhinz/vim-signify",
    keys = {
      { "<leader>is", "<cmd>SignifyEnable<CR>", desc = "Enable Signify" },
    },
  },

  -- CSV file support
  {
    "hat0uma/csvview.nvim",
    ft = { "csv" },
    config = function()
      require("csvview").setup()
    end,
  },

  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    build = ":UpdateRemotePlugins",
    keys = {
      { "<leader>MI", "<cmd>MoltenInit<CR>", desc = "Molten Init" },
    },
    init = function()
      -- set opts
      vim.g.molten_output_win_max_height = 30
      -- Remove highlight for cell
      -- vim.api.nvim_set_hl(0, "MoltenCell", {})
      -- Add keybinds when molten is initialized.
      vim.api.nvim_create_autocmd("User", {
        pattern = "MoltenInitPost",
        callback = function()
          vim.keymap.set(
            "v",
            "<space>l",
            ":<C-u>MoltenEvaluateVisual<CR>gv<esc>",
            { desc = "Molten execute visual selection", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<space>L",
            ":MoltenEvaluateLine<CR>",
            { desc = "Molten evalute line", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<space>mr",
            ":MoltenReevaluateCell<CR>",
            { desc = "Molten re-evalute cell", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<space>md",
            ":MoltenDelete<CR>",
            { desc = "Molten delete active cell", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<space>mD",
            ":MoltenDeinit<CR>",
            { desc = "Molten de-init", buffer = true, silent = true }
          )
          vim.keymap.set(
            "n",
            "<space>mi",
            ":MoltenInterrupt<CR>",
            { desc = "Molten keyboard interrupt", buffer = true, silent = true }
          )
        end,
      })
    end,
  },

  {
    "andrewferrier/debugprint.nvim",
    dependencies = {
      "echasnovski/mini.nvim", -- Needed for :ToggleCommentDebugPrints(NeoVim 0.9 only)
      -- and line highlighting (optional)
    },
    lazy = false, -- Required to make line highlighting work before debugprint is first used
    version = "*", -- Remove if you DON'T want to use the stable version
    opts = {
      keymaps = {
        normal = {
          variable_below = "glj",
          variable_above = "glk",
        },
      },
      highlight_lines = false,
      print_tag = "FLGG",
      display_counter = false,
    },
  },
}
