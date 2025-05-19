local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

--- Define some global helper functions
function P(v)
  vim.notify(vim.inspect(v))
  return v
end

function R(name)
  if pcall(require, "plenary") then
    require("plenary.reload").reload_module(name)
    return require(name)
  else
    return nil
  end
end

--- Setup lazy
require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins", opts = { colorscheme = "rose-pine" } },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    lazy = true,
    version = false,
  },
  install = {
    -- install missing plugins on startup. This doesn't increase startup time.
    missing = true,
    -- try to load one of these colorschemes when starting an installation during startup
    colorscheme = { "rose-pine" },
  },
  checker = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "tohtml",
        "tutor",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
      },
    },
  },
  dev = {
    -- Directory where you store your local plugin projects. If a function is used,
    -- the plugin directory (e.g. `~/projects/plugin-name`) must be returned.
    ---@type string | fun(plugin: LazyPlugin): string
    path = "~/github",
    ---@type string[] plugins that match these patterns will use your local versions instead of being fetched from GitHub
    patterns = { "flanggut" }, -- For example {"folke"}
    fallback = true, -- Fallback to git when local plugin doesn't exist
  },
})
