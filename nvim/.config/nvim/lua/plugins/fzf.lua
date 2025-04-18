return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>sd",
        function()
          Snacks.picker.diagnostics_buffer()
        end,
        desc = "Buffer Diagnostics",
      },
      {
        "<leader>sf",
        function()
          Snacks.picker.lines({ layout = { preset = "select" } })
        end,
        desc = "Buffer Lines",
      },
      {
        "<leader>si",
        function()
          Snacks.picker.treesitter()
        end,
        desc = "Treesitter",
      },
      {
        "<leader>sl",
        function()
          Snacks.picker.recent({ filter = { cwd = true } })
        end,
        desc = "Local Files",
      },
      {
        "<leader>sP",
        function()
          Snacks.picker.files({ dirs = { vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }, title = "Lazy Plugins" })
        end,
        desc = "Vim Plugins",
      },
      {
        "<C-k>",
        function()
          Snacks.picker.lsp_symbols()
        end,
        desc = "Goto Symbol",
      },
      {
        "<C-l>",
        function()
          Snacks.picker.buffers({ layout = { preset = "select" } })
        end,
        desc = "Buffers",
      },
    },
  },
}
-- History of old pickers
--
-- {
--   "ibhagwan/fzf-lua",
--   opts = {
--     files = {
--       formatter = "path.filename_first",
--       previewer = false,
--     },
--     oldfiles = {
--       formatter = "path.filename_first",
--       previewer = false,
--     },
--     lsp = {
--       path_shorten = 1,
--     },
--   },
--   keys = {
--     {
--       "<leader>sd",
--       function()
--         Snacks.picker.diagnostics_buffer()
--       end,
--       desc = "Buffer Diagnostics",
--     },
--     {
--       "<leader>sf",
--       function()
--         Snacks.picker.lines({ layout = { preset = "select" } })
--       end,
--       desc = "Buffer Lines",
--     },
--     {
--       "<leader>si",
--       function()
--         Snacks.picker.treesitter()
--       end,
--       desc = "Treesitter",
--     },
--     {
--       "<leader>sl",
--       function()
--         Snacks.picker({
--           multi = { "buffers", "recent" },
--           format = "file", -- use `file` format for all sources
--           matcher = {
--             cwd_bonus = true, -- boost cwd matches
--             frecency = true, -- use frecency boosting
--             sort_empty = true, -- sort even when the filter is empty
--           },
--           transform = "unique_file",
--         })
--       end,
--       desc = "Local Files",
--     },
--     {
--       "<leader>sP",
--       function()
--         Snacks.picker.files({ dirs = { vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") }, title = "Lazy Plugins" })
--         -- require("fzf-lua").files({
--         --   ---@diagnostic disable-next-line: param-type-mismatch
--         --   cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
--         -- })
--       end,
--       desc = "Vim Plugins",
--     },
--     {
--       "<C-k>",
--       function()
--         Snacks.picker.lsp_symbols()
--       end,
--       desc = "Goto Symbol",
--     },
-- {
--   "<C-l>",
--   function()
--     require("fzf-lua").buffers({
--       formatter = "path.filename_first",
--       previewer = false,
--       winopts = {
--         relative = "cursor",
--         row = 1.01,
--         col = 0,
--         height = 0.2,
--         width = 0.5,
--       },
--     })
--   end,
--   desc = "Buffers",
-- },
--     {
--       "<C-l>",
--       function()
--         Snacks.picker.buffers({ layout = { preset = "select" } })
--       end,
--       desc = "Buffers",
--     },
--   },
-- },

-- Telescope
-- {
--   "nvim-telescope/telescope.nvim",
--   dependencies = {
--     "nvim-telescope/telescope-symbols.nvim",
--   },
--   cmd = "Telescope",
--   keys = {
-- {
--   "<C-k>",
--   function()
--     require("telescope.builtin").lsp_document_symbols({
--       symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
--       symbol_width = 50,
--       symbol_type_width = 12,
--     })
--   end,
--   "Goto Symbol",
-- },
-- { "<C-l>", "<cmd>Telescope buffers<cr>", "Buffers" },
-- { "<C-p>", "<cmd>lua require('fl.functions').myfiles({})<cr>", "Files" },
-- { "<leader>sc", "<cmd>lua require('telescope.builtin').commands()<cr>", "Vim Commands" },
-- {
--   "<leader>sd",
--   "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/dotfiles'})<cr>",
--   "Dotfiles",
-- },
-- { "<leader>se", "<cmd>lua require('telescope.builtin').symbols()<cr>", "Emoji" },
-- { "<leader>sf", "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer Fuzzy" },
-- { "<leader>sh", "<cmd>Telescope command_history<cr>", "Command History" },
-- { "<leader>sH", "<cmd>Telescope help_tags<cr>", "Help Tags" },
-- {
--   "<leader>sl",
--   "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true, cwd_only=true, previewer=false})<cr>",
--   "Previous Files",
-- },
-- { "<leader>sm", "<cmd>Noice telescope<cr>", "Noice Messages" },
-- { "<leader>sp", "<cmd>lua require('telescope.builtin').registers()<cr>", "Registers" },
-- { "<leader>sq", "<cmd>lua require('telescope.builtin').quickfix()<cr>", "Quickfix" },
-- { "<leader>st", "<cmd>lua require('telescope.builtin').treesitter()<cr>", "Treesitter" },
-- { "<leader>ss", "<cmd>Telescope treesitter<cr>", "Treesitter" },
-- {
--   "<leader>sP",
--   function()
--     require("telescope.builtin").find_files({
--       ---@diagnostic disable-next-line: param-type-mismatch
--       cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
--     })
--   end,
--   "Vim Plugins",
-- },
-- {
--   "<leader>sy",
--   function()
--     require("telescope.builtin").lsp_document_symbols({
--       symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
--       symbol_width = 50,
--       symbol_type_width = 12,
--     })
--   end,
--   "Goto Symbol",
-- },
-- { "<leader><leader>g", "<cmd>Telescope live_grep<cr>", "Telescope Live Grep" },
-- { "<leader><leader>h", "<cmd>Telescope help_tags<cr>", "Telescope Help Tags" },
-- },
-- opts = {
--   picker = {
--     hidden = false,
--   },
--   defaults = {
--     prompt_prefix = "     ",
--     selection_caret = "  ",
--     entry_prefix = "  ",
--     initial_mode = "insert",
--     selection_strategy = "reset",
--     sorting_strategy = "ascending",
--     layout_strategy = "horizontal",
--     layout_config = {
--       horizontal = {
--         prompt_position = "top",
--         preview_width = 0.55,
--         results_width = 0.8,
--       },
--       vertical = {
--         mirror = false,
--       },
--       width = 0.8,
--       height = 0.8,
--       preview_cutoff = 120,
--     },
--     winblend = 0,
--     scroll_strategy = "cycle",
--     color_devicons = true,
--     mappings = {
--       i = {
--         ["<esc>"] = require("telescope.actions").close,
--         ["<C-j>"] = require("telescope.actions").move_selection_next,
--         ["<C-k>"] = require("telescope.actions").move_selection_previous,
--         ["<C-e>"] = require("telescope.actions").delete_buffer,
--       },
--     },
--     preview_title = "",
--     path_display = function(opts, path)
--       local Path = require("plenary.path")
--       local strings = require("plenary.strings")
--       local tail = require("telescope.utils").path_tail(path)
--       local filename = strings.truncate(tail, 45)
--       filename = filename .. string.rep(" ", 45 - #tail)
--       local cwd
--       if opts.cwd then
--         cwd = opts.cwd
--         if not vim.in_fast_event() then
--           cwd = vim.fn.expand(opts.cwd)
--         end
--       else
--         cwd = vim.fn.getcwd()
--       end
--       local relative = Path:new(path):make_relative(cwd)
--       relative = strings.truncate(relative, #relative - #tail + 1)
--       return string.format("%s  %s", filename, relative)
--     end,
--   },
--   pickers = {
--     buffers = require("telescope.themes").get_cursor({
--       layout_config = {
--         width = 100,
--         height = 25,
--       },
--       sort_mru = true,
--       sort_lastused = true,
--       previewer = false,
--       mappings = {
-- i = {
--           ["<C-l>"] = require("telescope.actions").close,
--         },
--       },
--     }),
--   },
-- },
-- },
