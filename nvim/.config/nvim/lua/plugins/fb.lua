if string.find(vim.fn.expand(vim.fn.getcwd() or ""), "fbsource", 0) then
  return {
    dir = "~/fbsource/fbcode/editor_support/nvim/",
    name = "meta.nvim",
    dependencies = { "jose-elias-alvarez/null-ls.nvim" },
    event = "BufRead",
    keys = {
      {
        "<c-i>",
        mode = { "i" },
        function()
          vim.notify("MM accept", vim.log.levels.INFO)
          require("meta.metamate").accept() -- accept if available
        end,
        desc = "Metamate Complete",
      },
    },
    config = function()
      require("meta")
      require("meta.metamate").init({
        -- change the languages to target. defaults to php, python, rust
        filetypes = { "cpp", "python" },
      })
    end,
  }
else
  return {}
end
