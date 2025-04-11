local clangd_binary = "clangd"
-- if vim.fn.isdirectory("/Users/flanggut/homebrew/opt/llvm") ~= 0 then
--   clangd_binary = "/Users/flanggut/homebrew/opt/llvm/bin/clangd"
-- end
-- if vim.fn.isdirectory("/Users/flanggut/homebrew/opt/llvm@19") ~= 0 then
--   clangd_binary = "/Users/flanggut/homebrew/opt/llvm@19/bin/clangd"
--   vim.notify("clangd: " .. clangd_binary)
-- end

return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    version = false,
    ---@class PluginLspOpts
    opts = {
      inlay_hints = { enabled = false },
      servers = {
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
    },
  },
  -- Keymap configurations.
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<C-j>", "<cmd>lua vim.lsp.buf.definition()<CR>" }
      keys[#keys + 1] =
        { "<c-o>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" }
      keys[#keys + 1] = { "K", vim.lsp.buf.hover, desc = "hover" }
      keys[#keys + 1] = {
        "<leader>e",
        function()
          -- Goto error if exists, else warning
          local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          if #errors > 0 then
            vim.diagnostic.jump({ severity = vim.diagnostic.severity.ERROR })
          else
            vim.diagnostic.jump({ severity = vim.diagnostic.severity.WARN })
          end
        end,
      }
      keys[#keys + 1] = { "<leader>E", vim.diagnostic.open_float }
      keys[#keys + 1] = { "<leader>sa", vim.lsp.buf.code_action, has = "codeAction" }
      keys[#keys + 1] = {
        "<leader>sr",
        function()
          Snacks.picker.lsp_references()
        end,
      }
      keys[#keys + 1] = { "<leader>rn", vim.lsp.buf.rename, has = "rename" }
      keys[#keys + 1] = { "<leader>cc", "<cmd>cclose<cr>", has = "rename" }
    end,
  },
}
