-------------------- HELPERS -------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()

local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function t(str) -- replace termcode
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-------------------- PLUGINS -------------------------------

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.api.nvim_command 'packadd packer.nvim'
end

require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- nvim-lspconfig
  use 'neovim/nvim-lspconfig'

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use 'nvim-telescope/telescope-z.nvim'

  -- treesitter
  use {'nvim-treesitter/nvim-treesitter'}

  -- lualine
  use {
    'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = function()
      require('lualine').setup{
        options = {
          theme = 'gruvbox_material',
          disabled_filetypes = {},
          icons_enabled = true,
        },
      }
    end
  }

  -- nvim-tree
  use {
    'kyazdani42/nvim-tree.lua',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
  }

  -- nvim-compe
  use 'hrsh7th/nvim-compe'

  --  bufferline lua
  use {'akinsho/nvim-bufferline.lua', requires = 'kyazdani42/nvim-web-devicons'}

  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'

  use 'arzg/vim-swift'
  use 'b3nj5m1n/kommentary'
  use 'justinmk/vim-sneak'
  use 'mcchrish/nnn.vim'
  use 'mhinz/vim-startify'
  use 'mhinz/vim-signify'
  use 'mhinz/vim-sayonara'
  use 'ntpeters/vim-better-whitespace'
  use 'psliwka/vim-smoothie'
  use 'sainnhe/gruvbox-material'
  use 'RRethy/nvim-base16'
  use 'RRethy/vim-illuminate'
  use 'voldikss/vim-floaterm'
  use 'Yggdroot/indentLine'

end)

-------------------- Basic Keybinds ------------------------
vim.g.mapleader = ' '
map('n', '<esc><esc>', '<cmd>nohlsearch<CR>')
cmd('nnoremap <tab> <C-w>w')
map('n', '<esc>l', "<C-^>")
map('n', '<leader>l', "<C-^>")
map('n', '<leader>y', [["+y]])
map('v', '<leader>y', [["+y]])

-------------------- Options -------------------------------
vim.o.background = "dark" -- or "light" for light mode
if vim.fn.has('termguicolors') == 1 then
   vim.o.termguicolors = true
end
cmd 'colorscheme gruvbox-material'

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
cmd('set diffopt+=vertical')
cmd('set signcolumn=yes')
-- cmd([[autocmd BufEnter * if expand("%:p:h") !~ '^/tmp' | silent! lcd %:p:h | endif]])

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

-------------------- PLUGIN SETUP --------------------------
-- treesitter
local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'maintained', highlight = {enable = true}}

-- telescope
local actions = require('telescope.actions')
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  }
}
require'telescope'.load_extension'z'
map('n', '<C-k>', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>")
map('n', '<C-l>', "<cmd>lua require('telescope.builtin').buffers()<cr>")
map('n', '<C-p>', "<cmd>lua require('telescope.builtin').find_files()<cr>")
map('n', '<leader>h', "<cmd>lua require('telescope.builtin').command_history()<cr>")
map('n', '<leader>jr', "<cmd>lua require('telescope.builtin').lsp_references()<cr>")
map('n', '<leader>z', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
vim.api.nvim_set_keymap('n', '<leader>O', [[<cmd>lua require'telescope'.extensions.z.list{}<CR>]], {noremap=true, silent=true})

-- nvim compe
require'compe'.setup {
  preselect = 'always';

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = false;
    omni = false;
  };
}
cmd('inoremap <silent><expr> <C-Space> compe#complete()')
cmd("inoremap <silent><expr> <CR>      compe#confirm('<CR>')")

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use c-j/k to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.cj_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<C-j>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.ck_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<C-k>"
  end
end
_G.tab_accept = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-y>"
  else
    return t "<Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<C-j>", "v:lua.cj_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<C-j>", "v:lua.cj_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<C-k>", "v:lua.ck_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<C-k>", "v:lua.ck_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_accept()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_accept()", {expr = true})

-- nvim tree
map('n', '<leader>n', '<cmd>NvimTreeFindFile<CR>')
map('n', '<leader>N', '<cmd>NvimTreeToggle<CR>')
vim.g.nvim_tree_width = 42
vim.g.nvim_tree_auto_close = 1
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_lsp_diagnostics = 1

-- sayonara
map('n', '<leader>q', '<cmd>Sayonara<CR>')

-- kommentary
require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
})
vim.api.nvim_set_keymap("n", "<leader>x", "<Plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("v", "<leader>x", "<Plug>kommentary_visual_default", {})

-- sneak
vim.api.nvim_set_var('sneak#s_next', 1)
vim.api.nvim_set_var('sneak#f_reset', 1)
vim.api.nvim_set_var('sneak#t_reset', 1)
vim.api.nvim_set_var('sneak#prompt', '> ')
vim.api.nvim_set_var('sneak#absolute_dir', 0)
map('n', 'f', '<Plug>Sneak_f', {noremap = false})
map('n', 'F', '<Plug>Sneak_F', {noremap = false})
map('o', 'f', '<Plug>Sneak_f', {noremap = false})
map('o', 'F', '<Plug>Sneak_F', {noremap = false})
cmd("nmap <expr> N sneak#is_sneaking() ? '<Plug>Sneak_,' : 'N'")
cmd("nmap <expr> n sneak#is_sneaking() ? '<Plug>Sneak_;' : 'n'")

-- startify
map('n', '<leader>S', '<cmd>Startify<CR>')
vim.g.startify_change_to_dir =  0
vim.g.startify_files_number = 20
vim.g.startify_enable_special = 0
vim.g.startify_bookmarks = {{ c = '~/.config/nvim/init.lua'}}
cmd("let g:startify_custom_indices = map(range(1,100), 'string(v:val)')")

-- bufferline
require'bufferline'.setup{}

-- indentline
vim.g.indentLine_char = '│'
vim.g.indentLine_first_char = '│'
vim.g.indentLine_showFirstIndentLevel = 1

-- better whitespace
map('n', '<leader>sw', '<cmd>StripWhitespace<CR>')
vim.g.better_whitespace_enabled = 1
vim.g.strip_whitespace_on_save = 0
vim.g.strip_max_file_size = 10000
vim.g.strip_whitelines_at_eof = 1
vim.g.better_whitespace_filetypes_blacklist= { 'packer' }

-- illuminate
map('n', '<a-n>', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>')
map('n', '<a-p>', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>')
vim.g.Illuminate_ftblacklist = {'nerdtree', 'startify', 'dashboard'}

-- nnn
cmd([[let g:nnn#layout = { 'window': { 'width': 0.6, 'height': 0.7, 'xoffset': 0.95, 'highlight': 'Debug'} }]])
cmd([[let g:nnn#set_default_mappings = 0]])
cmd([[let g:nnn#command = 'nnn -A']])
map('n', '<c-n>', '<cmd>NnnPicker %:p:h<cr>', {silent = true})

-- floatterm
if vim.fn.has('mac') == 1 then
  vim.g.floatterm_shell = '/usr/local/bin/fish'
else
  vim.g.floatterm_shell = '/bin/fish'
end
vim.g.floaterm_autoclose = 1
vim.g.floaterm_height = 0.8
vim.g.floaterm_width = 0.8
vim.g.floaterm_position = 'bottomright'
map('n', '<c-s>', '<cmd>FloatermToggle<cr>', {silent = true})
map('t', '<c-s>', '<c-\\><c-n><cmd>FloatermToggle<cr>', {silent = true})
map('n', '<leader>ca', '<cmd>FloatermNew commands_for_file.py %:p<cr>', {silent = true})
-- vim.cmd('autocmd FileType python nnoremap <silent> <leader>p :w<cr>:FloatermNew python3 %<cr>')

-- fzf custom pickers
if string.find(vim.fn.expand(vim.loop.cwd()), "fbsource") then
cmd([[command! -bang -nargs=? -complete=dir Files call fzf#run({'source': "find . -maxdepth 1 -type f", 'sink': 'e', 'options': '--bind=change:reload:"arc myles -n 100 --list {q}"', 'down': '30%' })]])
  vim.api.nvim_set_keymap('n', '<leader>p', '<cmd>Files<CR>', {noremap=true})
end

-------------------- LSP SETUP ------------------------------
local nvim_lsp = require ('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', '<C-j>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('i', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  cmd("highlight LspDiagnosticsVirtualTextError guifg='#EEEEEE'")
  require 'illuminate'.on_attach(client)
end

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
local servers = { "clangd" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end

--------------------- Custom functions -----------------
function CodeLink()
  vim.api.nvim_exec(
    [[
        let file = expand( "%:f" )
        let path = substitute(file, ".*/fbsource/", "", "")
        let line = line('.')

        let g = "https://www.internalfb.com/code/fbsource/\[master\]/" . path . "?lines=". line
        echom g
        silent exec "!open \'". g ."'"
    ]],
    true)
end
map('n', '<leader>op', '<cmd>lua CodeLink()<CR>')

-------------- Load local nvimrc --------------
-- local local_vimrc = vim.fn.getcwd()..'/.nvimrc'
-- if vim.loop.fs_stat(local_vimrc) then
--   vim.cmd('source '..local_vimrc)
-- end
