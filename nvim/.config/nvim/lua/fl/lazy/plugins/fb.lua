if string.find(vim.fn.expand(vim.loop.cwd() or ""), "fbsource", 0) then
  return {
    dir = "~/fbsource/fbcode/editor_support/nvim/",
    name = "meta.nvim",
    dependencies = { "jose-elias-alvarez/null-ls.nvim" },
    event = "BufRead",
    config = function()
      require("meta")
      require("meta.metamate").init({
        completionKeymap = "<C-f>",
        -- change the languages to target. defaults to php, python, rust
        filetypes = { "cpp", "python" },
      })
    end,
  }
else
  return {}
end
