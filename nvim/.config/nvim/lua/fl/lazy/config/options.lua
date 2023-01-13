-- Leader first
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic must haves
vim.o.cmdheight = 2
vim.o.compatible = false
vim.o.completeopt = "menu,menuone,noselect"
vim.o.foldlevelstart = 1
vim.o.hidden = true
vim.o.inccommand = "nosplit"
vim.o.laststatus = 2
vim.o.linespace = 3
vim.o.showmode = false
vim.o.splitbelow = true
vim.o.ttimeoutlen = 5
vim.o.updatetime = 100
vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.backspace = [[indent,eol,start]]

vim.wo.list = true
vim.o.listchars = "tab:▶ ,trail:•"

vim.wo.foldmethod = "indent"
vim.wo.foldnestmax = 1

vim.wo.number = true

vim.wo.signcolumn = "yes"

vim.opt.shada = { "!", "'500", "<50", "s10", "h" }
vim.opt.swapfile = false
vim.opt.undofile = false

vim.cmd("set diffopt+=vertical")

-- Indentation
vim.o.autoindent = true -- Copy indentation from previous line
vim.o.breakindent = true -- Indent breaks.
vim.o.expandtab = true -- Always use spaces instead of tabs
vim.o.shiftround = true -- Always indent by multiple of shiftwidth
vim.o.shiftwidth = 2 -- Columns inserted with the reindent operations
vim.o.showbreak = [[↪ ]] -- Show line break
vim.o.smartindent = true -- Inserts new level of indentation
vim.o.smarttab = true -- Better tabs
vim.o.softtabstop = 2 -- Columns a tab inserts in insert mode
vim.o.tabstop = 2 -- Columns a tab counts for
vim.o.title = true

-- Search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- Scrolling
vim.o.scrolloff = 8

-- Theme
vim.o.background = "dark" -- or "light" for light mode
if vim.fn.has("termguicolors") == 1 then
  vim.o.termguicolors = true
end
