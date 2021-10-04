local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.cmd [[colorscheme gruvbox-material]]
-------------------- Basic Keybinds ------------------------
vim.g.mapleader = ' '
map('n', '<esc><esc>', '<cmd>nohlsearch<CR>')
map('n', '<esc>l', "<C-^>") map('n', '<leader>l', "<C-^>")
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

-- restore the last session
map('n', '<leader>pl', [[<cmd>lua require('persistence').load()<cr>]])

-------------------- Options -------------------------------

-- Basic must haves
vim.o.compatible = false
vim.o.hidden = true                -- hide buffers instead of closing them
vim.o.wildmode = 'longest,list'    -- bash like completion in cmndln
vim.o.wildmenu = true
vim.o.showmode = false             -- no mode in cmdln
vim.o.cmdheight = 2
vim.o.updatetime = 100
vim.o.ttimeoutlen = 5
vim.o.linespace = 3
vim.o.laststatus = 2
vim.o.splitbelow = true
vim.o.completeopt='menuone,noselect'
vim.wo.number = true                -- line numbers
vim.wo.foldmethod = 'indent'
vim.wo.foldnestmax = 1
vim.o.foldlevelstart = 1

vim.cmd('set diffopt+=vertical')
vim.cmd('set signcolumn=yes')

-- Indentation
vim.o.expandtab = true              -- Always use spaces instead of tabs
vim.o.smarttab = true               -- Better tabs
vim.o.smartindent = true            -- Inserts new level of indentation
vim.o.autoindent = true             -- Copy indentation from previous line
vim.o.tabstop = 2                   -- Columns a tab counts for
vim.o.softtabstop = 2               -- Columns a tab inserts in insert mode
vim.o.shiftwidth = 2                -- Columns inserted with the reindent operations
vim.o.shiftround = true             -- Always indent by multiple of shiftwidth

-- Search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- highlight text on yank
vim.cmd([[
  au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
]])

-- set correct filetype for fish
vim.cmd([[
  au BufNewFile,BufRead *.fish set filetype=fish
]])
