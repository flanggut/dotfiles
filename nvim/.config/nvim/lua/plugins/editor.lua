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
          desc = "Stream CMD",
        },
        {
          "<leader>hi",
          function()
            R('fl.functions').float_cmd({ '__fzf_hg' })
          end,
          desc = "Stream CMD",
        },
        { "<leader><leader>l", "<cmd>LspRestart<CR>",                                    desc = "Restart LSP servers" },
        { "<leader><leader>p", "<cmd>w<CR><cmd>lua R('fl.functions').tmux_prev2()<CR>",  desc = "Runner" },
        { "<leader><leader>s", "<cmd>lua R('fl.snippets').load()<CR>",                   desc = "Reload snippets" },
      },
    },
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

  -- tmux integration
  {
    "aserowy/tmux.nvim",
    -- stylua: ignore
    keys = {
      { "<M-h>", function() require("tmux").move_left() end,   mode = { "n", "t" }, desc = "Tmux Left" },
      { "<M-j>", function() require("tmux").move_bottom() end, mode = { "n", "t" }, desc = "Tmux Down" },
      { "<M-k>", function() require("tmux").move_top() end,    mode = { "n", "t" }, desc = "Tmux Up" },
      { "<M-l>", function() require("tmux").move_right() end,  mode = { "n", "t" }, desc = "Tmux Right" },
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

  -- CSV file support
  {
    "hat0uma/csvview.nvim",
    ft = { "csv" },
    config = function()
      require("csvview").setup()
    end,
  },
}
