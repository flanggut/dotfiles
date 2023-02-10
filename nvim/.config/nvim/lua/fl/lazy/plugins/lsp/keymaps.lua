local M = {}

---@type PluginLspKeys
M._keys = nil

---@return (LazyKeys|{has?:string})[]
function M.get()
  ---@class PluginLspKeys
  -- stylua: ignore
  M._keys = M._keys
    or {
      { "<C-j>", "<cmd>Lspsaga goto_definition<CR>" },
      { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
      { "K", "<cmd>Lspsaga hover_doc ++keep<CR>" },
      { "<leader>e", vim.diagnostic.goto_next },
      { "<leader>E", vim.diagnostic.open_float },
      { "<leader>sa", "<cmd>Lspsaga code_action<CR>", has = "codeAction" },
      { "<leader>sr", require("telescope.builtin").lsp_references },
      { "<leader>rn", vim.lsp.buf.rename, has = "rename" },
      { "<leader>sy", function() require("telescope.builtin").lsp_document_symbols({ symbol_width = 50, symbol_type_width = 12 }) end, },
    }
  return M._keys
end

function M.on_attach(client, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = {} ---@type table<string,LazyKeys|{has?:string}>

  for _, value in ipairs(M.get()) do
    local keys = Keys.parse(value)
    if keys[2] == vim.NIL or keys[2] == false then
      keymaps[keys.id] = nil
    else
      keymaps[keys.id] = keys
    end
  end

  for _, keys in pairs(keymaps) do
    if not keys.has or client.server_capabilities[keys.has .. "Provider"] then
      local opts = Keys.opts(keys)
      ---@diagnostic disable-next-line: no-unknown
      opts.has = nil
      opts.silent = true
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
    end
  end
end

return M
