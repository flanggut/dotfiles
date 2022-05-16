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

local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
map('n', '<leader>sb', "<cmd>lua require('telescope.builtin').symbols()<cr>")
map('n', '<leader>sc', "<cmd>lua require('telescope.builtin').commands()<cr>")
map('n', '<leader>sf', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
map('n', '<leader>sl', "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true, cwd_only=true, previewer=false})<cr>")
map('n', '<leader>sp', "<cmd>lua require('telescope.builtin').registers()<cr>")
map('n', '<leader>sq', "<cmd>lua require('telescope.builtin').quickfix()<cr>")
map('n', '<leader>st', "<cmd>lua require('telescope.builtin').treesitter()<cr>")
map('n', '<leader>sz', "<cmd>lua require'telescope'.extensions.z.list()<CR>", {silent=true})

map('n', '<C-p>', ':lua R("fl.functions").myfiles({})<CR>', {noremap = true, silent = true})
map('n', '<leader>mg', ':lua R("fl.functions").mygrep({list_files_only=false})<CR>', {noremap = true, silent = true})
map('n', '<leader>ml', ':lua R("fl.functions").mygrep({list_files_only=true})<CR>', {noremap = true, silent = true})

