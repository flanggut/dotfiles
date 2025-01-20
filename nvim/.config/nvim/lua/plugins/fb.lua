if string.find(vim.fn.expand(vim.fn.getcwd() or ""), "fbsource", 0) then
  return {
    dir = "~/fbsource/fbcode/editor_support/nvim/",
    name = "meta.nvim",
    dependencies = { "jose-elias-alvarez/null-ls.nvim" },
    event = "VeryLazy",
    config = function()
      require("meta")
      require("meta.metamate").init({
        -- change the languages to target. defaults to php, python, rust
        filetypes = { "cpp", "python" },
        completionKeymap = "<C-f>",
      })
      vim.api.nvim_create_autocmd({ "BufRead" }, {
        pattern = { "*.cpp", "*.h" },
        callback = function()
          require("fl.functions").generate_compile_commands(false)
        end,
      })
    end,
  }
else
  return {}
end
