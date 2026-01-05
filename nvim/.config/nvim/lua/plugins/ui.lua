local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  -- snacks
  {
    "folke/snacks.nvim",
    keys = {
      { "<c-s>",             mode = { "n" }, "<cmd>lua Snacks.dashboard()<cr>",             desc = "Dashboard" },
      { "<leader>q",         mode = { "n" }, "<cmd>lua Snacks.bufdelete()<CR>",             desc = "Delete buffer" },
      { "<leader><leader>n", mode = { "n" }, "<cmd>lua Snacks.notifier.show_history()<CR>", desc = "Notifier History" },
    },
    ---@param opts snacks.Config
    opts = function(_, opts)
      opts.dashboard = {
        preset = {
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua R('fl.functions').fzfiles()" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "l", desc = "Local Files", action = ":lua Snacks.picker.recent({ filter = { cwd = true } })" },
            { icon = " ", key = "m", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "y", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "d", desc = "adb logcat", action = ":lua R('fl.functions').stream_cmd('adb logcat')" },
            { icon = "󰌑 ", key = "<c-s>", desc = "Hide Dashboard", action = "" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      }
      opts.notifier = {
        width = { min = 40, max = 0.8 },
      }
      opts.picker = {
        formatters = {
          file = {
            filename_first = true,
            truncate = 60,
          },
        },
        layout = {
          cycle = false,
        },
      }
      opts.scroll = {
        animate = {
          easing = "outCirc",
        },
      }
      opts.terminal = {
        win = {
          keys = {
            nav_h = { "<M-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<M-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<M-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<M-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      }
    end
  },

  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    init = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
    end,
    ---@module 'edgy'
    ---@param opts Edgy.Config
    opts = function(_, opts)
      opts.bottom = {
        -- toggleterm / lazyterm at the bottom with a height of 40% of the screen
        {
          ft = "toggleterm",
          size = { height = 0.4 },
          -- exclude floating windows
          filter = function(_, win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end,
        },
        {
          ft = "lazyterm",
          title = "LazyTerm",
          size = { height = 0.4 },
          filter = function(buf)
            return not vim.b[buf].lazyterm_cmd
          end,
        },
        {
          ft = "help",
          size = { height = 20 },
          -- only show help buffers
          filter = function(buf)
            return vim.bo[buf].buftype == "help"
          end,
        },
        "Trouble",
        { ft = "qf", title = "QuickFix" },
      }
      opts.exit_when_last = true
      opts.options = {
        right = { size = 0.5 },
      }
      for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "snacks_terminal",
          size = { height = 0.4, width = 0.4 },
          title = "%{b:snacks_terminal.id}: %{b:term_title}",
          filter = function(_, win) -- buf, win
            return vim.w[win].snacks_win
                and vim.w[win].snacks_win.position == pos
                and vim.w[win].snacks_win.relative == "editor"
                and not vim.w[win].trouble_preview
          end,
        })
      end
    end,
  },

  -- noice
  {
    "folke/noice.nvim",
    keys = {
      -- disable the keymap
      { "<c-f>", false },
      { "<c-b>", false },
    },
    opts = {
      views = {
        cmdline_popup = {
          position = {
            row = 30,
            col = "50%",
          },
          size = {
            min_width = 60,
            width = "auto",
            height = "auto",
          },
        },
        cmdline_popupmenu = {
          position = {
            row = 33,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
            max_height = 15,
          },
        },
      },
      presets = {
        bottom_search = false,
        command_pallete = false,
      },
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

  -- highlight on yank
  {
    "y3owk1n/undo-glow.nvim",
    event = "LazyFile",
    version = "*",
    opts = {
      animation = {
        enabled = true,
      },
    },
  },

  -- bufferline
  {
    "akinsho/bufferline.nvim",
    event = "LazyFile",
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
    opts = function()
      local palette = require("rose-pine.palette")

      local function os_indicator()
        if vim.fn.has("macunix") == 1 then
          return " "
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
        -- local linters = require("lint")._resolve_linter_by_ft(vim.bo.filetype)
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

      local opts = {
        options = {
          globalstatus = vim.o.laststatus == 3,
          disabled_filetypes = {
            statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard", "Avante", "AvanteSelectedFiles" },
          },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { os_indicator, separator = { left = "" } }, { "mode" } },
          lualine_b = {
            { lsp_names },
            { lint_progress },
            { "diagnostics", symbols = LazyVim.config.icons.diagnostics },
          },
          lualine_c = {
            { "filename", padding = { left = 1, right = 1 } },
          },
          lualine_x = {
            { added,    color = { fg = palette.pine }, separator = {} },
            { removed,  color = { fg = palette.love }, separator = {} },
            { modified, color = { fg = palette.foam } },
            -- { "diff", symbols = {added = " " , removed = " ", modified = "柳"} },
            "filetype",
            "encoding",
            "filesize",
            "fileformat",
          },
          lualine_z = {
            { 'location', separator = { right = '' } },
          }
        },
      }
      return opts
    end,
  },
}
