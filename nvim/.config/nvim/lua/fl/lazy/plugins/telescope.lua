return {
  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-symbols.nvim',
      'nvim-telescope/telescope-z.nvim'
    },
    config = function ()
      require('telescope').setup{
        picker = {
          hidden = false,
        },
        defaults = {
          prompt_prefix = "     ",
          selection_caret = "  ",
          entry_prefix = "  ",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.8,
            height = 0.8,
            preview_cutoff = 120,
          },
          winblend = 0,
          scroll_strategy = "cycle",
          color_devicons = true,
          mappings = {
            i = {
              ["<esc>"] = require('telescope.actions').close,
              ["<C-j>"] = require('telescope.actions').move_selection_next,
              ["<C-k>"] = require('telescope.actions').move_selection_previous,
              ["<C-e>"] = require('telescope.actions').delete_buffer,
            },
          },
          preview_title = "",
          path_display = function(opts, path)
            local Path = require('plenary.path')
            local strings = require('plenary.strings')
            local tail = require("telescope.utils").path_tail(path)
            local filename = strings.truncate(tail, 45)
            filename = filename .. string.rep(" ", 45 - #tail)
            local cwd
            if opts.cwd then
              cwd = opts.cwd
              if not vim.in_fast_event() then
                cwd = vim.fn.expand(opts.cwd)
              end
            else
              cwd = vim.loop.cwd();
            end
            local relative = Path:new(path):make_relative(cwd)
            relative = strings.truncate(relative, #relative - #tail + 1)
            return string.format("%s  %s", filename, relative)
          end,
        },
        pickers = {
          buffers = require('telescope.themes').get_cursor({
            layout_config = {
              width = 100,
              height = 25,
            },
            sort_mru=true,
            sort_lastused=true,
            previewer=false,
            mappings = {
              i = {
                ["<C-l>"] = require('telescope.actions').close
              }
            },
          }),
        },
        extensions = {
        }
      }
      require'telescope'.load_extension('fzf')
      require'telescope'.load_extension('z')
    end,
  }
  -- fzf native
  { 
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make' 
  }
}
