--Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- remove highlight from search
vim.keymap.set("n", "<esc><esc>", "<cmd>nohlsearch<CR>")

vim.notify("LOADING KEYMAPS")
-- toggle two most recent files
vim.keymap.set("n", "<leader>.", "<c-6>")

-- goto line start/end
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

-- Y yank until the end of line  (note: this is now a default on master)
vim.keymap.set("n", "Y", "y$", { noremap = true })

-- yank to clipboard
vim.keymap.set("n", "<leader>y", [["+y]], { noremap = true })
vim.keymap.set("v", "<leader>y", [["+y]], { noremap = true })

-- open/close quickfix list
vim.keymap.set("n", "<leader>co", [[<cmd>copen<CR>]], { noremap = true })
vim.keymap.set("n", "<leader>cc", [[<cmd>cclose<CR>]], { noremap = true })

-- search and replace visual selection
vim.keymap.set("v", "<leader>r", [["hy:%s/<C-r>h//gc<left><left><left>]], { noremap = true })

-- toggle fold
-- vim.keymap.set("n", "<leader>F", "za", { noremap = false })

-- fold lines matching search string
vim.keymap.set(
  "n",
  "<leader>oo",
  [[:setlocal foldexpr=(getline(v:lnum)=~@/)?0:1 foldmethod=expr foldlevel=0 foldcolumn=2 foldminlines=0<CR><CR>]],
  { noremap = false, silent = true }
)
vim.keymap.set("n", "<leader>om", [[:setlocal foldmethod=manual<CR><CR>]], { noremap = false, silent = true })

-- better star search
vim.keymap.set(
  "n",
  "*",
  [[:let @/= '\<' . expand('<cword>') . '\C\>' <bar> set hls <cr>]],
  { noremap = false, silent = true }
)

-- move visual selection up or down
vim.keymap.set("v", "<C-j>", [[:m '>+1<CR>gv=gv]], { noremap = true })
vim.keymap.set("v", "<C-k>", [[:m '<-2<CR>gv=gv]], { noremap = true })

-- undo breakpoints on several keys in insert mode
vim.keymap.set("i", ",", ",<c-g>u", { noremap = true })
vim.keymap.set("i", ".", ".<c-g>u", { noremap = true })
vim.keymap.set("i", "(", "(<c-g>u", { noremap = true })
vim.keymap.set("i", "<", "<<c-g>u", { noremap = true })

-- Unmap common typos
vim.keymap.set("n", "q:", "<nop>", { noremap = true })
vim.keymap.set("n", "Q", "<nop>", { noremap = true })
