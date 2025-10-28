---@diagnostic disable: inject-field
return {
  -- which-key
  {
    "folke/which-key.nvim",
    opts = {
      plugins = { spelling = true },
      spec = {
        { "<leader>x",  "gcc",                                                        mode = "n",               noremap = false, nowait = true },
        { "<leader>x",  "gc",                                                         mode = "v",               noremap = false, nowait = true },
        { "<leader>f",  "<cmd>LazyFormat<CR>",                                        desc = "Format" },
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
        { "<leader>p",         "<cmd>w<CR><cmd>lua R('fl.functions').file_runner()<CR>", desc = "Runner" },
        {
          "<leader>if",
          "<cmd>lua R('fl.functions').stream_cmd()<CR>",
          desc = "Stream ls output",
        },
        {
          "<leader>dm",
          function()
            Snacks.terminal.toggle("dmt", {
              win = {
                position = "right",
                width = 0.8,
                height = 1.0,
              }
            })
          end,
          desc = "Restart LSP servers"
        },
        { "<leader><leader>l", "<cmd>LspRestart<CR>",                                    desc = "Restart LSP servers" },
        { "<leader><leader>p", "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>",  desc = "Runner" },
        { "<leader><leader>s", "<cmd>lua R('fl.snippets').load()<CR>",                   desc = "Reload snippets" },
      },
    },
  },

  {
    "numToStr/Comment.nvim",
    opts = {
      -- add any options here
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
      {
        "gl",
        mode = { "v" },
        function()
          require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
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
      { "<M-h>", function() require("tmux").move_left() end,   mode = "t", desc = "Tmux Left" },
      { "<M-h>", function() require("tmux").move_left() end,   mode = "n", desc = "Tmux Left" },
      { "<M-j>", function() require("tmux").move_bottom() end, mode = "n", desc = "Tmux Down" },
      { "<M-k>", function() require("tmux").move_top() end,    mode = "n", desc = "Tmux Up" },
      { "<M-l>", function() require("tmux").move_right() end,  mode = "n", desc = "Tmux Right" },
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
        copy_sync = {
          sync_registers_keymap_put = false,
        },
      })
    end,
  },

  -- mini
  {
    "nvim-mini/mini.nvim",
    version = false,
    event = "BufRead",
    config = function()
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
  -- {
  --   "windwp/nvim-autopairs",
  --   event = "InsertEnter",
  --   config = function()
  --     require("nvim-autopairs").setup()
  --     local Rule = require("nvim-autopairs.rule")
  --     local npairs = require("nvim-autopairs")
  --     npairs.add_rule(Rule("```", "```", { "markdown", "vimwiki", "rmarkdown", "rmd", "pandoc", "hgcommit" }))
  --   end,
  -- },

  -- linediff
  {
    "AndrewRadev/linediff.vim",
    cmd = "Linediff",
  },

  -- file explorer
  {
    "stevearc/oil.nvim",
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
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
      columns = {
        "icon",
        -- "permissions",
        "size",
        -- "mtime",
      },
      keymaps = {
        -- See :help oil-actions for a list of all available actions
        ["l"] = { "actions.select", mode = "n" },
        ["h"] = { "actions.parent", mode = "n" },
        ["f"] = {
          function()
            local dirname = require("oil").get_current_dir()
            require("oil").close()
            require("fl.functions").grep_in_directory(dirname)
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
        ["<esc><esc>"] = { "actions.close", mode = "n" },
      },
      float = {
        border = "rounded",
        max_width = 0.5,
        max_height = 0.6,
      },
    },
  },

  {
    "mhinz/vim-signify",
    cmd = { "SignifyEnable" },
  },

  -- CSV file support
  {
    "hat0uma/csvview.nvim",
    ft = { "csv" },
    config = function()
      require("csvview").setup()
    end,
  },
}
