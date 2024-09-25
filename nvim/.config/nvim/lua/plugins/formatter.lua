return {
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>iF",
        function()
          require("conform").format({ formatters = { "injected" } })
        end,
        mode = { "n", "v" },
        desc = "Format Injected Langs",
      },
    },
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
      -- Install the conform formatter on VeryLazy
      require("fl.util").on_very_lazy(function()
        require("fl.util.format").register({
          name = "conform.nvim",
          priority = 100,
          primary = true,
          format = function(buf)
            require("conform").format({ bufnr = buf, timeout_ms = 5000 })
          end,
          sources = function(buf)
            local ret = require("conform").list_formatters(buf)
            return vim.tbl_map(function(v)
              return v.name
            end, ret)
          end,
        })
      end)
    end,
    opts = {
      formatters_by_ft = {
        json = { "fixjson" },
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        python = { "black" },
      },
      -- LazyVim will merge the options you set here with builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string,table>
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- -- Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
    config = function(_, opts)
      opts.formatters = opts.formatters or {}
      for name, formatter in pairs(opts.formatters) do
        if type(formatter) == "table" then
          local ok, defaults = pcall(require, "conform.formatters." .. name)
          if ok and type(defaults) == "table" then
            opts.formatters[name] = vim.tbl_deep_extend("force", {}, defaults, formatter)
          end
        end
      end
      require("conform").setup(opts)
      -- require("conform").formatters.black = {
      --   prepend_args = { "--line-length", "80" },
      -- }
      require("fl.lazy.util.format").setup()
    end,
  },
}
