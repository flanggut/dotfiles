local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
	  {import ="plugins"},
  },
  defaults = {
    lazy = true,
    version = "*", -- try installing the latest stable version for plugins that support semver
    -- only enable certain plugins for vscode
    cond = vim.g.vscode and function(plugin)
      local p = plugin[1]
      return p == "nvim-treesitter/nvim-treesitter"
        or p == "numToStr/Comment.nvim"
        or p == "folke/flash.nvim"
        or p == "karb94/neoscroll.nvim"
        or p == "karb94/neoscroll.nvim"
    end or nil,
  },
  install = {
    -- install missing plugins on startup. This doesn't increase startup time.
    missing = true,
    -- try to load one of these colorschemes when starting an installation during startup
    -- colorscheme = { "gruvbox-material" },
    colorscheme = { "rose-pine" },
  },
  checker = { enabled = false },
  change_detection = { enabled = true, notify = false },
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
})
vim.keymap.set("n", "<leader>L", "<cmd>:Lazy<cr>")
