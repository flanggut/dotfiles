return {
  -- icons
  'kyazdani42/nvim-web-devicons',
  -- ui components
  "MunifTanjim/nui.nvim",
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
    'windwp/windline.nvim',
    config = function()
      require 'fl.statusline'
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
