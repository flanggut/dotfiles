return {
  -- better vim.notify
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>nd",
        function()
          require("notify").dismiss({ silent = true, pending = true })
        end,
        desc = "Delete all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
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

  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    keys = {
      { "<C-s>", "<cmd>Dashboard<CR>" },
    },
    opts = function()
      local logo = [[
        ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗██╗███╗   ███╗
        ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║██║████╗ ████║
        ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║██║██╔████╔██║
        ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝██║██║╚██╔╝██║
        ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]
      logo = string.rep("\n", 15) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
        },
        config = {
          header = vim.split(logo, "\n"),
          -- stylua: ignore
          center = {
            { action = 'lua require("fl.functions").myfiles({})', desc = " Find file",    icon = " ", key = "f" },
            { action = "Telescope oldfiles include_current_session=true cwd_only=true previewer=false", desc = " Local file", icon = " ", key = "l" },
            { action = "Telescope oldfiles include_current_session=true previewer=false", desc = " Recent files", icon = " ", key = "m" },
            { action = 'lua require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
            { action = 'Telescope find_files cwd=~/.config/nvim/ follow=true hidden=true', desc = " Config",       icon = " ", key = "c" },
            { action = "Lazy",                              desc = " Lazy",            icon = "󰒲 ", key = "L" },
            { action = "qa",                                desc = " Quit",            icon = " ", key = "q" },
            -- { action = "Telescope live_grep",               desc = " Find text",       icon = " ", key = "g" },
            -- { action = "LazyExtras",                        desc = " Lazy Extras",     icon = " ", key = "x" },
          },
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      end

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      return opts
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
