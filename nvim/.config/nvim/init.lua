P = function(v)
  print(vim.inspect(v))
  return v
end

require("fl.lazy")

if pcall(require, "plenary") then
  RELOAD = require("plenary.reload").reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end
