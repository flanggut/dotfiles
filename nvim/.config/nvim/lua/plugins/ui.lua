return {
  -- snacks
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
       -- stylua: ignore
       ---@type snacks.dashboard.Item[]
       keys = {
         { icon = " ", key = "f", desc = "Find File", action = ":lua require('fl.functions').myfiles({})" },
         { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
         { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
         { icon = " ", key = "l", desc = "Local Files", action = ":lua Snacks.dashboard.pick('oldfiles', {cwd_only = true})" },
         { icon = " ", key = "m", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
         { icon = " ", key = "s", desc = "Restore Session", section = "session" },
         { icon = "󰒲 ", key = "y", desc = "Lazy", action = ":Lazy" },
         { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
         { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
         { icon = "󰌑 ", key = "h", desc = "Hide Dashboard", action = ":e" },
         { icon = " ", key = "q", desc = "Quit", action = ":qa" },
       },
        },
      },
    },
  },

  -- noice
  {
    "folke/noice.nvim",
    keys = {
      -- disable the keymap
      { "<c-f>", false },
      { "<c-b>", false },
    },
  },

  -- better highlights based on vim modes
  {
    "mvllow/modes.nvim",
    event = "LazyFile",
    config = function()
      require("modes").setup()
    end,
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    event = "VimEnter",
    config = function()
      require("bufferline").setup({
        ---@diagnostic disable-next-line: missing-fields
        options = {
          show_close_icon = false,
          show_buffer_close_icons = false,
          sort_by = "relative_directory",
          max_name_length = 35,
        },
        highlights = {
          ---@diagnostic disable-next-line: missing-fields
          buffer_selected = {
            bold = true,
          },
          ---@diagnostic disable-next-line: missing-fields
          fill = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            bg = {
              attribute = "bg",
              highlight = "Normal",
            },
          },
        },
      })
      vim.keymap.set("n", "gh", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "gl", ":BufferLineCycleNext<CR>", { noremap = true, silent = true })
      vim.keymap.set("n", "gq", ":BufferLinePickClose<CR>", { noremap = true, silent = true })
    end,
  },

  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      -- local configuration = vim.fn["gruvbox_material#get_configuration"]()
      -- local palette = vim.fn["gruvbox_material#get_palette"](
      -- configuration.background,
      -- configuration.foreground,
      -- configuration.colors_override
      -- )
      local palette = require("rose-pine.palette")

      local function os_indicator()
        if vim.fn.has("macunix") == 1 then
          return " "
        else
          return " "
        end
      end

      local function lsp_names()
        local names = ""
        for _, client in ipairs(vim.lsp.get_clients()) do
          if names == "" then
            names = client.name
          else
            names = names .. ", " .. client.name
          end
        end
        return names
      end

      local lint_progress = function()
        local linters = require("lint").get_running()
        if #linters == 0 then
          return "󰦕"
        end
        return "󱉶 " .. table.concat(linters, ", ")
      end

      local function get_repo_stat(index)
        if vim.g.loaded_signify then
          local repostats = vim.api.nvim_call_function("sy#repo#get_stats", {})
          if repostats[index] > -1 then
            return repostats[index]
          end
        end
        return -1
      end

      local function added()
        local stat = get_repo_stat(1)
        if stat > -1 then
          return string.format(" %s", stat)
        end
        return ""
      end

      local function modified()
        local stat = get_repo_stat(2)
        if stat > -1 then
          return string.format(" %s", stat)
        end
        return ""
      end

      local function removed()
        local stat = get_repo_stat(3)
        if stat > -1 then
          return string.format(" %s", stat)
        end
        return ""
      end

      lualine.setup({
        options = {
          globalstatus = true,
          disabled_filetypes = { statusline = { "lazy", "dashboard" } },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { os_indicator, "mode" },
          lualine_b = {
            { lsp_names },
            { lint_progress },
            { "diagnostics", symbols = LazyVim.config.icons.diagnostics },
          },
          lualine_c = {
            { "filename", padding = { left = 1, right = 1 } },
          },
          lualine_x = {
            { added, color = { fg = palette.pine }, separator = {} },
            { removed, color = { fg = palette.love }, separator = {} },
            { modified, color = { fg = palette.foam } },
            -- { "diff", symbols = {added = " " , removed = " ", modified = "柳"} },
            "filetype",
            "encoding",
            "filesize",
            "fileformat",
          },
        },
      })
    end,
  },

  -- Smooth Scrolling
  {
    "karb94/neoscroll.nvim",
    event = "BufRead",
    config = function()
      require("neoscroll").setup({
        easing_function = "circular",
        mappings = { "<C-u>", "<C-d>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
      })
    end,
  },
}
