-------------------- HELPERS -------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local execute = vim.api.nvim_command

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
  execute 'packadd packer.nvim'
end

require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'neovim/nvim-lspconfig'
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use {'nvim-treesitter/nvim-treesitter'}

  use 'arzg/vim-colors-xcode'
  use 'arzg/vim-swift'
  use 'justinmk/vim-sneak'
  use 'majutsushi/tagbar'
  use 'mhinz/vim-startify'
  use 'scrooloose/nerdcommenter'
  use 'ojroques/nvim-bufdel'
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'

end)

-------------------- OPTIONS -------------------------------
cmd 'colorscheme xcodedark'
vim.g.mapleader = ' '

-- Basic must haves
vim.o.compatible = false
vim.o.hidden = true                -- hide buffers instead of closing them
vim.o.number = true                -- line numbers
vim.o.wildmode = 'longest,list'    -- bash like completion in cmndln
vim.o.wildmenu = true
vim.o.showmode = false             -- no mode in cmdln
vim.o.cmdheight = 2
vim.o.updatetime = 300
vim.o.timeoutlen = 500
vim.o.ttimeoutlen = 5
vim.o.linespace = 3
cmd('set signcolumn=yes')           -- TODO: debug why vim.o does not work for this
vim.o.laststatus = 2
vim.o.splitbelow = true
cmd('set diffopt+=vertical')
cmd('set completeopt-=preview')

-- Indentation
vim.o.smarttab = true               -- Better tabs
vim.o.smartindent = true            -- Inserts new level of indentation
vim.o.autoindent = true             -- Copy indentation from previous line
vim.o.tabstop = 2                   -- Columns a tab counts for
vim.o.softtabstop = 2               -- Columns a tab inserts in insert mode
vim.o.shiftwidth = 2                -- Columns inserted with the reindent operations
vim.o.shiftround = true             -- Always indent by multiple of shiftwidth
vim.o.expandtab = true              -- Always use spaces instead of tabs

-- Search
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-------------------- PLUGIN SETUP --------------------------
-- treesitter
local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'maintained', highlight = {enable = true}}

-- airline
vim.g.airline_powerline_fonts = true
vim.api.nvim_set_var('airline#extensions#tabline#enabled', 'true')
vim.g.airline_theme = 'minimalist'

-- buffdel
map('n', '<leader>q', '<cmd>BufDel<CR>')

-- NERD Commenter
vim.g.NERDDefaultAlign = 'left'
vim.g.NERDSpaceDelims = 1
vim.g.NERDCreateDefaultMappings = 0
map('n', '<leader>x', ':call NERDComment(0, "toggle")<CR>')
map('v', '<leader>x', ':call NERDComment(0, "toggle")<CR>')

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
cmd("highlight Sneak cterm=bold ctermbg=yellow ctermfg=black") -- TODO: debug

-- startify
map('n', '<leader>S', '<cmd>Startify<CR>')
vim.g.startify_change_to_dir =  0
vim.g.startify_files_number = 20
vim.g.startify_enable_special = 0
vim.g.startify_bookmarks = {{ c = '~/.config/nvim/init.lua'}}

