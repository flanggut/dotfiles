-- load global config
require("config.lazy")

-- define some global helper functions
P = function(v)
  vim.notify(vim.inspect(v))
  return v
end

if pcall(require, "plenary") then
  RELOAD = require("plenary.reload").reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end
