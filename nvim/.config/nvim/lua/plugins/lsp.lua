local clangd_binary = "clangd"
local llvm_local_dir = os.getenv("HOME") .. "/homebrew/opt/llvm@20"
if vim.fn.isdirectory(llvm_local_dir) ~= 0 then
  clangd_binary = llvm_local_dir .. "/bin/clangd"
end

return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    version = false,
    ---@class PluginLspOpts
    opts = {
      servers = {
        ['*'] = {
          keys = {
            { "<C-j>",      vim.lsp.buf.definition,     has = "definition" },
            { "K",          vim.lsp.buf.hover,          has = "hover" },
            { "<leader>sa", vim.lsp.buf.code_action,    has = "codeAction" },
            { "<leader>rn", vim.lsp.buf.rename,         has = "rename" },
            { "<leader>E",  vim.diagnostic.open_float },
            { "<c-o>",      vim.lsp.buf.signature_help, has = "signatureHelp", mode = "i" },
            { "<leader>sr",
              function()
                Snacks.picker.lsp_references()
              end
            },
            { "<leader>e",
              function()
                -- Goto error if exists, else warning, else hint
                local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                if #errors > 0 then
                  vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR, count = 1 })
                  return
                end
                local warnings = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                if #warnings > 0 then
                  vim.diagnostic.jump({ severity = vim.diagnostic.severity.WARN, count = 1 })
                  return
                end
                local hints = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
                if #hints > 0 then
                  vim.diagnostic.jump({ severity = vim.diagnostic.severity.HINT, count = 1 })
                  return
                end
              end, }
          },
          { "<leader>cc", "<cmd>cclose<cr>", has = "rename" }
        },
        clangd = {
          cmd = {
            clangd_binary,
            "--background-index",
            "--completion-style=detailed",
            "--header-insertion=never",
            "--offset-encoding=utf-16",
          },
        },
        pylsp = {
          plugins = {
            pyflakes = { enabled = false },
            pycodestyle = { enabled = false },
            autopep8 = { enabled = false },
            yapf = { enabled = false },
            mccabe = { enabled = false },
            pylsp_mypy = { enabled = false },
            pylsp_black = { enabled = false },
            pylsp_isort = { enabled = false },
          },
        },
      },
      setup = {
        pylsp = function()
          if string.find(vim.fn.expand(vim.fn.getcwd() or ""), "fbsource", 0) then
            return true
          end
          return false
        end,
      },
      inlay_hints = { enabled = false },
    },
  },
}
