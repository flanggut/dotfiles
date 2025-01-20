local fbflake8_pattern = "[^:]+:(%d+):(%d+): (%w)(%d+)(.+)"
local fbflake8_groups = { "lnum", "col", "severity", "code", "message" }

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettier" },
        python = { "black" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      events = { "BufWritePost", "BufReadPost", "InsertLeave" },
      linters_by_ft = {
        fish = { "fish" },
        json = { "jsonlint" },
        python = { "fbflake8", "ruff" },
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
      },
      --   -- LazyVim extension to easily override linter options
      --   -- or add custom linters.
      --   ---@type table<string,table>
      linters = {
        fbflake8 = {
          condition = function(ctx)
            local find = vim.fs.find({ ".arcrc" }, { path = ctx.filename, upward = true })
            local valid = not next(find) == nil
            if valid then
              vim.notify_once("Using linter: fblake8")
            end
            return valid
          end,
          cmd = "/usr/local/bin/flake8",
          append_fname = true,
          stream = "both",
          ignore_exitcode = true,
          parser = require("lint.parser").from_pattern(
            fbflake8_pattern,
            fbflake8_groups,
            { ["E"] = vim.diagnostic.severity.ERROR },
            {
              ["source"] = "flake8",
              ["severity"] = vim.diagnostic.severity.WARN,
            }
          ),
        },
        ruff = {
          condition = function(ctx)
            local find = vim.fs.find({ ".arcrc" }, { path = ctx.filename, upward = true })
            local valid = next(find) == nil
            if valid then
              vim.notify_once("Using linter: ruff")
            end
            return valid
          end,
        },
        -- -- Example of using selene only when a selene.toml file is present
        -- selene = {
        --   -- `condition` is another LazyVim extension that allows you to
        --   -- dynamically enable/disable linters based on the context.
        --   condition = function(ctx)
        --     return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
      },
    },
  },
}
