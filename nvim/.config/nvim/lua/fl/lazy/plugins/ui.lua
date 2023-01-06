return {
  -- icons
  'kyazdani42/nvim-web-devicons',
  -- ui components
  "MunifTanjim/nui.nvim",
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
    config = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
  },
  -- better vim.ui
  {
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  -- bufferline
  {
    'akinsho/bufferline.nvim',
    event = "BufRead",
    config = function()
      require('bufferline').setup {
        options = {
          show_close_icon = false,
          show_buffer_close_icons = false,
          sort_by = 'relative_directory',
          max_name_length = 35,
        },
        highlights = {
          buffer_selected = {
            bold = true
          },
          fill = {
            bg = {
              attribute = "bg",
              highlight = "Normal"
            }
          },
        }
      }

      vim.keymap.set('n', 'gh', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', 'gl', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', 'gj', ':BufferLinePick<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', 'gq', ':BufferLinePickClose<CR>', { noremap = true, silent = true })
    end
  },
  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      -- local navic = require("nvim-navic")
      -- local symbols = require("lazyvim.config.settings")
      lualine.setup({
        options = {
          globalstatus = true,
          disabled_filetypes = { statusline = { "lazy", "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
          --   { "branch" },
          --   {
          --     "diff",
          --     symbols = { added = symbols.icons.git.added, modified = symbols.icons.git.modified, removed = symbols.icons.git.removed }, -- changes diff symbols
          --   },
          },
          lualine_c = {
            {
              "diagnostics",
              -- symbols = { error = symbols.icons.diagnostics.Error, warn = symbols.icons.diagnostics.Warn, info = symbols.icons.diagnostics.Info, hint = symbols.icons.diagnostics.Hint }
            },
            { "filename", padding = { left = 1, right = 1 } },
            -- { navic.get_location, cond = navic.is_available }
          },
        }
      })
    end
  },
  -- alpha startscreen
  { 
    'goolord/alpha-nvim',
    event = "VimEnter",

    config = function()
      local alpha = require 'alpha'
      local startify = require 'alpha.themes.startify'
      startify.section.top_buttons.val = {
        startify.button("l", "  Open last session", ":lua require'persistence'.load()<CR>", {}),
        startify.button("e", "  New file", ":ene <CR>", {}),
      }
      startify.section.bottom_buttons.val = {
        startify.button("c", "  Edit config", ":e ~/.config/nvim/lua/fl/plugins.lua<CR>", {}),
        startify.button("q", "  Quit neovim", ":qa<CR>", {}),
      }
      local mru_ignore_ext = { "gitcommit" }
      local mru_ignore = function(path, ext)
        return vim.tbl_contains(mru_ignore_ext, ext) or
            path:find "COMMIT_EDITMSG" or
            path:find "histedit.hg" or
            path:find "commit.hg"
      end
      startify.mru_opts.ignore = mru_ignore

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      alpha.setup(startify.config)
      vim.keymap.set('n', '<C-s>', '<cmd>Alpha<CR>', { noremap = true })
    end
  }
}
