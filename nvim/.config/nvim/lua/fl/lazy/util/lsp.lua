---@class lazyvim.util.lsp
local M = {}

function M.get_clients(...)
  ---@diagnostic disable-next-line: deprecated
  local fn = vim.lsp.get_clients or vim.lsp.get_active_clients
  return fn(...)
end

---@return _.lspconfig.options
function M.get_config(server)
  local configs = require("lspconfig.configs")
  return rawget(configs, server)
end

---@param opts? LazyFormatter| {filter?: (string|lsp.Client.filter), bufnr?: number}
function M.formatter(opts)
  opts = opts or {}
  local filter = opts.filter
  filter = type(filter) == "string" and M.filter(filter) or filter
  ---@cast filter lsp.Client.filter?
  ---@type LazyFormatter
  local ret = {
    name = "LSP",
    primary = true,
    priority = 1,
    format = function(buf)
      M.format({ bufnr = buf, filter = filter })
    end,
    sources = function(buf)
      local clients = M.get_clients({ bufnr = buf })
      ---@param client lsp.Client
      local ret = vim.tbl_filter(function(client)
        return (not filter or filter(client))
          and (
            client.supports_method("textDocument/formatting")
            or client.supports_method("textDocument/rangeFormatting")
          )
      end, clients)
      ---@param client lsp.Client
      return vim.tbl_map(function(client)
        return client.name
      end, ret)
    end,
  }
  return vim.tbl_deep_extend("force", ret, opts) --[[@as LazyFormatter]]
end

---@param opts? {filter?: lsp.Client.filter, bufnr?: number}
function M.format(opts)
  vim.lsp.buf.format(opts or {})
end

return M
