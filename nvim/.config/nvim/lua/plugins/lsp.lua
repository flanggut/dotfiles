local clangd_binary = "clangd"
if vim.fn.isdirectory("/Users/flanggut/homebrew/opt/llvm") ~= 0 then
  clangd_binary = "/Users/flanggut/homebrew/opt/llvm/bin/clangd"
end

return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    version = false,
    dependencies = {
      -- "hrsh7th/cmp-nvim-lsp",
      "saghen/blink.cmp",
      { "zeioth/garbage-day.nvim", event = "BufRead", opts = {} },
    },
    ---@class PluginLspOpts
    opts = {
      inlay_hints = { enabled = false },
      -- capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities()),
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
        { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" }
      keys[#keys + 1] = { "K", vim.lsp.buf.hover, desc = "hover" }
      keys[#keys + 1] = {
        "<leader>e",
        function()
          -- Goto error if exists, else warning
          local errors = vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
          if #errors > 0 then
            vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
          else
            vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
          end
        end,
      }
      keys[#keys + 1] = { "<leader>E", vim.diagnostic.open_float }
      keys[#keys + 1] = { "<leader>sa", vim.lsp.buf.code_action, has = "codeAction" }
      keys[#keys + 1] = { "<leader>sr", require("fzf-lua").lsp_references }
      keys[#keys + 1] = { "<leader>rn", vim.lsp.buf.rename, has = "rename" }
      keys[#keys + 1] = {
        "<leader>sy",
        function()
          require("telescope.builtin").lsp_document_symbols({ symbol_width = 50, symbol_type_width = 12 })
        end,
      }
    end,
  },
}
