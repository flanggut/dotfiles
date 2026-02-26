local ff = require("fl.functions")

if ff.is_fb() then
  local editor_support_dir = os.getenv("EDITOR_SUPPORT")
  if editor_support_dir == nil or editor_support_dir == "" then
    vim.notify("EDITOR_SUPPORT not defined", vim.log.levels.WARN)
    return {}
  end
  return {
    {
      dir = editor_support_dir,
      name = "meta.nvim",
      -- dependencies = { "jose-elias-alvarez/null-ls.nvim" },
      event = "VeryLazy",
      config = function()
        require("meta.cmds")
        require("meta.metamate").init({
          -- change the languages to target. defaults to php, python, rust
          filetypes = { "cpp", "python" },
          completionKeymap = "<C-f>",
        })
        require("meta.lsp")
        vim.lsp.enable({
          "rust-analyzer@meta", -- for Rust - Run `:RustAnalyzerReload` on TARGETS changes
          "fb-pyright-ls@meta", -- for Python
          "pyre@meta",          -- for Python type checking
          "pyre-codenav@meta",  -- for Python code navigation using Pyre
          "wasabi@meta",        -- for [Wasabi](<https://www.internalfb.com/intern/wiki/Bento_Team/Language_Services_(LSPs)/Wasabi/>) support, a new, experimental Python LS at Meta
          "thriftlsp@meta",     -- for Thrift
          -- "cppls@meta",         -- for C++
          -- "buckls@meta",        -- for Buck
          "buck2@meta", -- new LS for Buck/Starlark
          -- "erlang@meta",        -- for Erlang in Whatsapp repos
          -- "gopls@meta",         -- for Golang
          -- "eslint@meta",        -- for JavaScript linting
          "prettier@meta", -- for JavaScript formatting
          "flow@meta",     -- for JavaScript type checking
          -- "hhvm",               -- for Hack
          -- "linttool@meta",      -- for linting and formatting
          -- "sourcekit-lsp@meta", -- for Swift (experimental)
          -- "relay@meta",         -- for GraphQL/relay
          -- "kotlin@meta",        -- for Kotlin
        })
      end,
    },
  }
else
  return {}
end
