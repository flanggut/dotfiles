local M = {}

---@type PluginLspKeys
M._keys = nil

---@return (LazyKeys|{has?:string})[]
function M.get()
  ---@class PluginLspKeys
  -- stylua: ignore
  M._keys = M._keys
    or {
      { "<C-j>", "<cmd>lua vim.lsp.buf.definition()<CR>" },
      { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help", has = "signatureHelp" },
      { "K", vim.lsp.buf.hover, desc = "hover" },
      { "<leader>e", vim.diagnostic.goto_next },
      { "<leader>E", vim.diagnostic.open_float },
      { "<leader>sa", vim.lsp.buf.code_action, has = "codeAction" },
      { "<leader>sr", require("telescope.builtin").lsp_references },
      { "<leader>rn", vim.lsp.buf.rename, has = "rename" },
      { "<leader>sy", function() require("telescope.builtin").lsp_document_symbols({ symbol_width = 50, symbol_type_width = 12 }) end, },
    }
  return M._keys
end

---@param name string
function M.opts(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

function M.get_clients(...)
  ---@diagnostic disable-next-line: deprecated
  local fn = vim.lsp.get_clients or vim.lsp.get_active_clients
  return fn(...)
end

---@param method string
function M.has(buffer, method)
  method = method:find("/") and method or "textDocument/" .. method
  local clients = M.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    if client.supports_method(method) then
      return true
    end
  end
  return false
end

---@return (LazyKeys|{has?:string})[]
function M.resolve(buffer)
  local Keys = require("lazy.core.handler.keys")
  if not Keys.resolve then
    return {}
  end
  local spec = M.get()
  local opts = M.opts("nvim-lspconfig")
  local clients = M.get_clients({ bufnr = buffer })
  for _, client in ipairs(clients) do
    local maps = opts.servers[client.name] and opts.servers[client.name].keys or {}
    vim.list_extend(spec, maps)
  end
  return Keys.resolve(spec)
end

function M.on_attach(_, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = M.resolve(buffer)

  for _, keys in pairs(keymaps) do
    if not keys.has or M.has(buffer, keys.has) then
      local opts = Keys.opts(keys)
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys.lhs, keys.rhs, opts)
    end
  end
end

return M
