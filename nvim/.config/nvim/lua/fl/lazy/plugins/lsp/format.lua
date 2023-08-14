local M = {}

M.autoformat = true

function M.toggle()
  M.autoformat = not M.autoformat
  if M.autoformat then
    require("notify")("Enabled format on save", "info", { title = "Format" })
  else
    require("notify")("Disabled format on save", "warn", { title = "Format" })
  end
end

function M.format()
  local buf = vim.api.nvim_get_current_buf()
  -- local ft = vim.bo[buf].filetype
  -- local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0
  vim.lsp.buf.format(vim.tbl_deep_extend("force", {
    bufnr = buf,
    filter = function(client)
      -- if have_nls then
      -- return client.name == "null-ls"
      -- end
      return client.name ~= "lua_ls"
    end,
  }, {}))
end

function M.on_attach(client, buf)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. buf, {}),
      buffer = buf,
      callback = function()
        if M.autoformat then
          M.format()
        end
      end,
    })
    vim.keymap.set("n", "<leader>f", M.format, { silent = true })
    vim.keymap.set("n", "<leader>af", M.toggle, { silent = true })
  end
end

return M
