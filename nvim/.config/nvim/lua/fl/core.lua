-------------------- Options -------------------------------
-- disable some builtin vim plugins for faster startup
local disabled_built_ins = {
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
   "rrhelper",
   "spellfile_plugin",
   "vimball",
   "vimballPlugin",
   "zip",
   "zipPlugin",
}
for _, plugin in pairs(disabled_built_ins) do
   vim.g["loaded_" .. plugin] = 1
end

-- Basic must haves
vim.o.cmdheight = 2
vim.o.compatible = false
vim.o.completeopt='menuone,noselect'
vim.o.foldlevelstart = 1
vim.o.hidden = true
vim.o.inccommand = 'nosplit'
vim.o.laststatus = 2
vim.o.linespace = 3
vim.o.showmode = false
vim.o.splitbelow = true
vim.o.ttimeoutlen = 5
vim.o.updatetime = 100
vim.o.wildmenu = true
vim.o.wildmode = 'longest:full,full'
vim.o.backspace = [[indent,eol,start]]

vim.wo.list = true
vim.o.listchars = 'tab:▶ ,trail:•'

vim.wo.foldmethod = 'indent'
vim.wo.foldnestmax = 1

vim.wo.number = true

vim.wo.signcolumn = 'yes'

vim.opt.shada = { "!", "'500", "<50", "s10", "h" }
vim.opt.swapfile = false
vim.opt.undofile = false

vim.cmd('set diffopt+=vertical')

-- Indentation
vim.o.autoindent = true             -- Copy indentation from previous line
vim.o.breakindent = true            -- Indent breaks.
vim.o.expandtab = true              -- Always use spaces instead of tabs
vim.o.shiftround = true             -- Always indent by multiple of shiftwidth
vim.o.shiftwidth = 2                -- Columns inserted with the reindent operations
vim.o.showbreak = [[↪ ]]            -- Show line break
vim.o.smartindent = true            -- Inserts new level of indentation
vim.o.smarttab = true               -- Better tabs
vim.o.softtabstop = 2               -- Columns a tab inserts in insert mode
vim.o.tabstop = 2                   -- Columns a tab counts for
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
if vim.fn.has('termguicolors') == 1 then
   vim.o.termguicolors = true
end

-- highlight text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  command = "lua vim.highlight.on_yank({higroup='IncSearch', timeout=150, on_visual=true})"
})

-- set correct filetype for fish
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.fish",
  command = "set filetype=fish"
})

-------------------- Basic Keybinds ------------------------
local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

--Remap space as leader key
vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

--Remap for dealing with word wrap
vim.api.nvim_set_keymap('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.api.nvim_set_keymap('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

map('n', '<esc><esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>l', "<C-^>")
map('n', '-', '^')
map('n', '+', '$')


-- Y yank until the end of line  (note: this is now a default on master)
map('n', 'Y', 'y$')
-- yank to clipboard
map('n', '<leader>y', [["+y]])
map('v', '<leader>y', [["+y]])

map('n', '<leader>co', [[<cmd>copen<CR>]])
map('n', '<leader>cc', [[<cmd>cclose<CR>]])
-- search and replace visual selection
map('v', '<leader>r', [["hy:%s/<C-r>h//gc<left><left><left>]])
-- toggle fold
map('n', '<leader>F', "za", {noremap=false})
-- better star search
map('n', '*', [[:let @/= '\<' . expand('<cword>') . '\C\>' <bar> set hls <cr>]], {noremap=false, silent=true})
-- move visual selection up or down
map('v', '<C-j>', [[:m '>+1<CR>gv=gv]], {noremap = true})
map('v', '<C-k>', [[:m '<-2<CR>gv=gv]], {noremap = true})
-- undo breakpoints
map('i', ',', ',<c-g>u', {noremap = true})
map('i', '.', '.<c-g>u', {noremap = true})
map('i', '(', '(<c-g>u', {noremap = true})
map('i', '<', '<<c-g>u', {noremap = true})

-- Unmap common typos
map('n', 'q:', "<nop>", {noremap=true})
map('n', 'Q', "<nop>", {noremap=true})
