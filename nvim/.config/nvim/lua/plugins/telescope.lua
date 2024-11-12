return {
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/popup.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-z.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      {
        "<C-k>",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
            symbol_width = 50,
            symbol_type_width = 12,
          })
        end,
        "Goto Symbol",
      },
      { "<C-l>", "<cmd>Telescope buffers<cr>", "Buffers" },
      { "<C-p>", "<cmd>lua require('fl.functions').myfiles({})<cr>", "Files" },
      { "<leader>sc", "<cmd>lua require('telescope.builtin').commands()<cr>", "Vim Commands" },
      {
        "<leader>sd",
        "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/dotfiles'})<cr>",
        "Dotfiles",
      },
      { "<leader>se", "<cmd>lua require('telescope.builtin').symbols()<cr>", "Emoji" },
      { "<leader>sf", "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer Fuzzy" },
      { "<leader>sh", "<cmd>Telescope command_history<cr>", "Command History" },
      { "<leader>sH", "<cmd>Telescope help_tags<cr>", "Help Tags" },
      {
        "<leader>sl",
        "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true, cwd_only=true, previewer=false})<cr>",
        "Previous Files",
      },
      { "<leader>sm", "<cmd>Noice telescope<cr>", "Noice Messages" },
      { "<leader>sp", "<cmd>lua require('telescope.builtin').registers()<cr>", "Registers" },
      { "<leader>sq", "<cmd>lua require('telescope.builtin').quickfix()<cr>", "Quickfix" },
      { "<leader>st", "<cmd>lua require('telescope.builtin').treesitter()<cr>", "Treesitter" },
      { "<leader>ss", "<cmd>Telescope treesitter<cr>", "Treesitter" },
      {
        "<leader>sv",
        "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/.local/share/nvim/site/pack/packer/'})<cr>",
        "Vim Plugins",
      },
      {
        "<leader>sy",
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
            symbol_width = 50,
            symbol_type_width = 12,
          })
        end,
        "Goto Symbol",
      },
      { "<leader><leader>g", "<cmd>Telescope live_grep<cr>", "Telescope Live Grep" },
      { "<leader><leader>h", "<cmd>Telescope help_tags<cr>", "Telescope Help Tags" },
    },
    opts = {
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
            ["<esc>"] = require("telescope.actions").close,
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<C-e>"] = require("telescope.actions").delete_buffer,
          },
        },
        preview_title = "",
        path_display = function(opts, path)
          local Path = require("plenary.path")
          local strings = require("plenary.strings")
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
            cwd = vim.fn.getcwd()
          end
          local relative = Path:new(path):make_relative(cwd)
          relative = strings.truncate(relative, #relative - #tail + 1)
          return string.format("%s  %s", filename, relative)
        end,
      },
      pickers = {
        buffers = require("telescope.themes").get_cursor({
          layout_config = {
            width = 100,
            height = 25,
          },
          sort_mru = true,
          sort_lastused = true,
          previewer = false,
          mappings = {
            i = {
              ["<C-l>"] = require("telescope.actions").close,
            },
          },
        }),
      },
      extensions = {
        quicknote = {
          defaultScope = "CWD",
        },
      },
    },
  },
}
