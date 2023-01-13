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
    'nvim-lualine/lualine.nvim',
    dependencies = {
      {'mhinz/vim-signify', event = 'BufRead',},
    },
    event = "VeryLazy",
    config = function()
      local lualine = require("lualine")
      local configuration = vim.fn['gruvbox_material#get_configuration']()
      local palette = vim.fn['gruvbox_material#get_palette'](configuration.background, configuration.foreground, configuration.colors_override)

      local function os_indicator()
        if vim.fn.has('macunix') == 1 then
          return ' '
        else
          return ' '
        end
      end

      local function lsp_names()
        names = ""
        for _, client in ipairs(vim.lsp.get_active_clients()) do
          names = client.name
        end
        return names
      end

      local function get_repo_stat(index)
        if vim.g.loaded_signify then
          local repostats = vim.api.nvim_call_function('sy#repo#get_stats', {bufnr})
          if repostats[index] > -1 then
            return repostats[index]
          end
        end
        return -1
      end

      local function added()
        local stat = get_repo_stat(1)
        if stat > -1 then
          return string.format(' %s', stat)
        end
        return ''
      end

      local function modified()
        local stat = get_repo_stat(2)
        if stat > -1 then
          return string.format('柳%s', stat)
        end
        return ''
      end

      local function removed()
        local stat = get_repo_stat(3)
        if stat > -1 then
          return string.format(' %s', stat)
        end
        return ''
      end

      lualine.setup({
        options = {
          globalstatus = true,
          disabled_filetypes = { statusline = { "lazy", "alpha" } },
        },
        sections = {
          lualine_a = { os_indicator, "mode" },
          lualine_b = {
            { lsp_names },
            { "diagnostics", symbols = { error = " ", warn = " " , info = " " , hint = " " } },
          },
          lualine_c = {
            { "filename", padding = { left = 1, right = 1 } },
          },
          lualine_x = {
            { added, color = {fg = palette.green[1]}, separator = {} },
            { removed, color = {fg = palette.red[1]}, separator = {} },
            { modified, color = {fg = palette.blue[1]}, },
            -- { "diff", symbols = {added = " " , removed = " ", modified = "柳"} },
            'filetype', 'encoding', 'fileformat',
          },
        }
      })
    end
  },

  -- lsp status fidget
  {
    'j-hui/fidget.nvim',
    event = 'BufReadPre',
    config = function()
      require 'fidget'.setup {
        text = {
          spinner = 'dots'
        }
      }
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
  },

  -- Smooth Scrolling
  {
    'karb94/neoscroll.nvim',
    event = 'BufRead',
    config = function()
      require('neoscroll').setup({ easing_function = 'circular', })
    end
  },
  {
    'edluffy/specs.nvim',
    event = 'BufRead',
    config = function()
      require('specs').setup {
        show_jumps = true,
        min_jump = 5,
        popup = {
          delay_ms = 0, -- delay before popup displays
          inc_ms = 20, -- time increments used for fade/resize effects
          blend = 10, -- starting blend, between 0-100 (fully transparent), see :h winblend
          width = 20,
          winhl = "PMenu",
          fader = require("specs").linear_fader,
          resizer = require("specs").shrink_resizer,
        },
        ignore_filetypes = {},
        ignore_buftypes = { nofile = true },
      }
    end
  }

}
