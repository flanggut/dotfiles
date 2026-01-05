return {
  -- {
  --   "esmuellert/vscode-diff.nvim",
  --   dependencies = { "MunifTanjim/nui.nvim" },
  --   cmd = "CodeDiff",
  -- },
  {
    "mhinz/vim-signify",
    cmd = { "SignifyEnable" },
  },

  {
    "numToStr/Comment.nvim",
    opts = {
      -- add any options here
    },
  },
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      {
        "<leader>gu",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Replace in files (grug-far)",
      },
      {
        "gl",
        mode = { "v" },
        function()
          require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
        end,
        desc = "Replace in files (grug-far)",
      },
    },
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip").config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })
      require("fl.snippets").load()
      local snippets_group = vim.api.nvim_create_augroup("ReloadSnippetsOnWrite", { clear = true })
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "snippets.lua",
        callback = function()
          R("fl.snippets").load()
          require("cmp_luasnip").clear_cache()
        end,
        group = snippets_group,
      })
    end,
  },
}
