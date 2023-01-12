P = function(v)
  print(vim.inspect(v))
  return v
end

if pcall(require, "plenary") then
  RELOAD = require("plenary.reload").reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

-- require'fl.core'
-- vim.defer_fn(function()
--   require'fl.plugins'
-- end, 0)

require("fl.lazy")
