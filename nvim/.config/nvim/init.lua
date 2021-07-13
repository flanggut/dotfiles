
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()

local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
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

  -- treesitter
  use {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'RRethy/nvim-treesitter-textsubjects'

  -- nvim-lsp
  use 'neovim/nvim-lspconfig'
  use 'glepnir/lspsaga.nvim'
  use 'ray-x/lsp_signature.nvim'

  -- telescope
  use {'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
  use 'nvim-telescope/telescope-z.nvim'

  -- lualine
  use {'hoob3rt/lualine.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true}
  }

  -- nvim-tree
  use {'kyazdani42/nvim-tree.lua',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
  }

  -- nvim-compe and vsnip
  use {'hrsh7th/nvim-compe',
    requires = {{'hrsh7th/vim-vsnip'}, {'hrsh7th/vim-vsnip-integ'}}
  }

  -- barbar
  use {'romgrk/barbar.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
  }

  -- the usual
  use {'junegunn/fzf', 'junegunn/fzf.vim'}
  use {'tpope/vim-repeat', 'tpope/vim-surround'}
  use {'mhinz/vim-startify', 'mhinz/vim-signify'}

  use 'lukas-reineke/indent-blankline.nvim' -- indent line
  use 'sainnhe/gruvbox-material' -- color scheme of choice
  use 'ggandor/lightspeed.nvim' -- the new sneak
  use 'windwp/nvim-autopairs' -- insert pairs automatically
  use 'psliwka/vim-smoothie' -- smooth scrolling
  use 'b3nj5m1n/kommentary' -- comments
  use 'mcchrish/nnn.vim' -- best file browser
  use 'ntpeters/vim-better-whitespace'
  use 'RRethy/vim-illuminate'
  use 'voldikss/vim-floaterm'
  use 'christoomey/vim-tmux-navigator'
  use 'famiu/nvim-reload'
  use 'tversteeg/registers.nvim'
  use 'mizlan/iswap.nvim'
  use 'matbme/JABS.nvim'
  use 'arzg/vim-swift' -- swift language support
  use 'kristijanhusak/orgmode.nvim'

end)

-------------------- Basic Keybinds ------------------------
vim.g.mapleader = ' '
map('n', '<esc><esc>', '<cmd>nohlsearch<CR>')
map('n', '<esc>l', "<C-^>")
map('n', '<leader>l', "<C-^>")
map('n', '<leader>y', [["+y]])
map('v', '<leader>y', [["+y]])
map('v', '<leader>r', [["hy:%s/<C-r>h//gc<left><left><left>]])
map('n', '<leader>F', "za", {noremap=false})
map('n', '*', [[:let @/= '\<' . expand('<cword>') . '\C\>' <bar> set hls <cr>]], {noremap=false})
-- Unmap common typos
map('n', 'q:', "<nop>", {noremap=true})
map('n', 'Q', "<nop>", {noremap=true})

-------------------- Options -------------------------------
vim.o.background = "dark" -- or "light" for light mode
if vim.fn.has('termguicolors') == 1 then
   vim.o.termguicolors = true
end
vim.api.nvim_command([[
  augroup MyColors
    autocmd ColorScheme gruvbox-material highlight link TSError Normal
  augroup END
]])

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
vim.wo.foldmethod = 'indent'
vim.wo.foldnestmax = 1
vim.o.foldlevelstart = 1
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

-- highlight text on yank
vim.cmd([[
  au TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=150, on_visual=true}
]])

-- set correct filetype for fish
vim.cmd([[
  au BufNewFile,BufRead *.fish set filetype=fish
]])

-------------------- Plugin Setup --------------------------
-- TREESITTER
local tsconf = require 'nvim-treesitter.configs'
tsconf.setup {
  ensure_installed = 'maintained',
  highlight = {enable = true},
  incremental_selection = {
    enable = true,
    keymaps = {
      node_incremental = ',',
      node_decremental = 'm',
    }
  },
  refactor = {
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "<leader>rr",
      },
    },
  },
  textsubjects = {
    enable = true,
    keymaps = {
      ['.'] = 'textsubjects-smart',
      [';'] = 'textsubjects-big',
    },
  },
}

-- TELESCOPE
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
    sorting_strategy = "ascending",

    preview_title = "",

    layout_strategy = "bottom_pane",
    layout_config = {
      height = 25,
    },

    border = true,
    borderchars = {
      "z",
      prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
      results = { " " },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰"},
    },
  }
}
require'telescope'.load_extension'z'
-- map('n', '<C-l>', "<cmd>lua require('telescope.builtin').buffers()<cr>")
map('n', '<C-l>', "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true,cwd_only=true})<cr>")
if not string.find(vim.fn.expand(vim.loop.cwd()), "fbsource") and not string.find(vim.fn.expand(vim.loop.cwd()), "ovrsource")  then
  map('n', '<C-p>', "<cmd>lua require('telescope.builtin').find_files()<cr>")
end
map('n', '<leader>h', "<cmd>lua require('telescope.builtin').command_history()<cr>")
map('n', '<leader>sf', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
map('n', '<leader>sl', "<cmd>lua require'telescope'.extensions.z.list({sorter = require('telescope.sorters').get_fzy_sorter()})<CR>", {silent=true})
-- map('n', '<leader>eo', "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true,cwd_only=true})<cr>")
map('n', '<leader>se', "<cmd>lua require('telescope.builtin').treesitter()<cr>")
map('n', '<leader>sq', "<cmd>cclose<cr><cmd>lua require('telescope.builtin').quickfix()<cr>")
-- fzf custom pickers
if string.find(vim.fn.expand(vim.loop.cwd()), "fbsource") then
cmd([[command! -bang -nargs=? -complete=dir Files call fzf#run({'source': "find . -maxdepth 1 -type f", 'sink': 'e', 'options': '--bind=change:reload:"arc myles -n 100 --list {q}"', 'down': '30%' })]])
  vim.api.nvim_set_keymap('n', '<C-p>', '<cmd>Files<CR>', {noremap=true})
end

-- NVIM COMPE
require'compe'.setup {
  preselect = 'always';

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
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
vim.api.nvim_set_keymap("i", "<C-j>", "v:lua.cj_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<C-j>", "v:lua.cj_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<C-k>", "v:lua.ck_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<C-k>", "v:lua.ck_complete()", {expr = true})

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end
vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})


-- NVIMTREE
tree = {}
tree.open = function ()
   require'bufferline.state'.set_offset(51, '')
   require'nvim-tree'.find_file(true)
end

tree.close = function ()
   require'bufferline.state'.set_offset(0)
   require'nvim-tree'.close()
end

map('n', '<leader>n', '<cmd>lua tree.open()<CR>zz')
map('n', '<leader>m', '<cmd>lua tree.close()<CR>')
vim.g.nvim_tree_width = 50
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_auto_close = 1

-- BARBAR
map('n', 'gh', "<cmd>BufferPrevious<CR>")
map('n', 'gl', "<cmd>BufferNext<CR>")
map('n', '<leader>j', "<cmd>BufferPick<CR>")
map('n', '<leader>bo', "<cmd>BufferCloseAllButCurrent<CR>")
map('n', '<leader>bd', "<cmd>BufferOrderByDirectory<CR>")
map('n', '<leader>q', "<cmd>BufferClose<CR>")

-- KOMMENTARY
require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
})
vim.api.nvim_set_keymap("n", "<leader>x", "<Plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("v", "<leader>x", "<Plug>kommentary_visual_default", {})

-- AUTOPAIRS
require('nvim-autopairs').setup()

-- STARTIFY
map('n', '<leader>S', '<cmd>Startify<CR>')
vim.g.startify_change_to_dir =  0
vim.g.startify_files_number = 20
vim.g.startify_enable_special = 0
vim.g.startify_bookmarks = {{ c = '~/.config/nvim/init.lua'}}
cmd("let g:startify_custom_indices = map(range(1,100), 'string(v:val)')")

-- INDENTLINE
vim.g.indentLine_enabled = 1
vim.g.indentLine_char = '│'
vim.g.indentLine_fileType = {'c', 'cpp', 'lua', 'python', 'vim'}

-- BETTER WHITESPACE
map('n', '<leader>sw', '<cmd>StripWhitespace<CR>')
vim.g.better_whitespace_enabled = 1
vim.g.strip_whitespace_on_save = 0
vim.g.strip_max_file_size = 10000
vim.g.strip_whitelines_at_eof = 1
vim.g.better_whitespace_filetypes_blacklist= { 'packer', 'lspsaga' }

-- ILLUMINATE
map('n', '<a-n>', '<cmd>lua require"illuminate".next_reference{wrap=true}<cr>')
map('n', '<a-p>', '<cmd>lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>')
vim.g.Illuminate_ftblacklist = {'nerdtree', 'startify', 'dashboard'}

-- NNN
cmd([[let g:nnn#layout = { 'window': { 'width': 0.6, 'height': 0.7, 'xoffset': 0.95, 'highlight': 'Debug'} }]])
cmd([[let g:nnn#set_default_mappings = 0]])
cmd([[let g:nnn#command = 'nnn -A -n']])
map('n', '<c-n>', '<cmd>NnnPicker %:p:h<cr>', {silent = true})

-- FLOATTERM
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
map('n', '<leader>cd', '<cmd>FloatermNew commands_for_file.py %:p<cr>', {silent = true})
-- vim.cmd('autocmd FileType python nnoremap <silent> <leader>p :w<cr>:FloatermNew python3 %<cr>')

-- LUALINE
require'lualine'.setup{
  options = {
    theme = 'gruvbox_material',
    disabled_filetypes = {},
    icons_enabled = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch'},
    lualine_c = {'filename'},
    lualine_x = {
      {
        function()
          local msg = 'none'
          local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
          local clients = vim.lsp.get_active_clients()
          if next(clients) == nil then return msg end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon = ' :',
      },
      {
        'diagnostics',
        sources = {'nvim_lsp'},
        symbols = {error = ' ', warn = ' ', info = ' '},
        color_error = '#ea6962',
        color_warn = '#d8a657',
        color_info = '#89b482'
      },
      'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  }
}

-- HOP
-- vim.api.nvim_set_keymap('n', 'f', "<cmd>lua require'hop'.hint_char1()<cr>", {})
-- vim.api.nvim_set_keymap('v', 'f', "<cmd>lua require'hop'.hint_char1()<cr>", {})
-- vim.api.nvim_set_keymap('n', 'L', "<cmd>lua require'hop'.hint_lines()<cr>", {})
-- vim.api.nvim_set_keymap('v', 'L', "<cmd>lua require'hop'.hint_lines()<cr>", {})
-- vim.api.nvim_set_keymap('n', 's', "<cmd>lua require'hop'.hint_char2()<cr>", {})
-- vim.api.nvim_set_keymap('n', 'H', "<cmd>lua require'hop'.hint_words()<cr>", {})

------------------- Navigation + TMUX -----------------
vim.g.tmux_navigator_no_mappings = 1
map('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>', {silent = true})
map('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>', {silent = true})
map('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>', {silent = true})
map('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>', {silent = true})
map('n', '<A-,>', '<cmd>split<cr>', {silent = true})
map('n', '<A-.>', '<cmd>vsplit<cr>', {silent = true})

-------------------- LSP Setup ------------------------------
local nvim_lsp = require ('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', '<C-j>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('i', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>ea', "<cmd>lua require'telescope.builtin'.lsp_code_actions()<CR>", opts)
  buf_set_keymap('n', '<leader>ei', "<cmd>lua require'telescope.builtin'.lsp_implementations()<CR>", opts)
  buf_set_keymap('n', '<leader>er', "<cmd>lua require'telescope.builtin'.lsp_references()<cr>", opts)
  buf_set_keymap('n', '<leader>es', "<cmd>lua require'telescope.builtin'.lsp_document_symbols()<cr>", opts)
  -- buf_set_keymap('n', '<leader>e', "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>", opts)
  buf_set_keymap('n', '<leader>sr', "<cmd>lua require'lspsaga.rename'.rename()<CR>", opts)
  buf_set_keymap('n', '<leader>sa', "<cmd>lua require'lspsaga.codeaction'.code_action()<CR>", opts)
  buf_set_keymap('n', '<leader>sf', "<cmd>lua require'lspsaga.provider'.lsp_finder()<CR>", opts)
  buf_set_keymap('n', '<C-k>', "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
  -- buf_set_keymap('i', '<C-h>', "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)
  buf_set_keymap('n', '<C-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
  buf_set_keymap('n', '<C-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  cmd("highlight LspDiagnosticsVirtualTextError guifg='#EEEEEE'")
  require 'lsp_signature'.on_attach({bind = true, floating_window = false, hint_prefix = '  '})

  -- LSPSAGA
  local saga = require 'lspsaga'
  saga.init_lsp_saga {
    max_preview_lines = 15,
    finder_action_keys = {
      open = '<CR>', vsplit = 's',split = 'i',quit = 'q',scroll_down = '<C-f>', scroll_up = '<C-b>' -- quit can be a table
    },
  }

  cmd("highlight LspSagaFinderSelection guifg='#A89984' gui='bold'")
  cmd("highlight LspSagaCodeActionContent guifg='#A89984' gui='bold'")
  cmd("highlight LspSagaRenameBorder guifg='#A89984'")
  cmd("highlight LspSagaHoverBorder guifg='#A89984'")
  cmd("highlight LspSagaSignatureHelpBorder guifg='#A89984'")
  cmd("highlight LspSagaCodeActionBorder guifg='#A89984'")
  cmd("highlight LspSagaDefPreviewBorder guifg='#A89984'")
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}

nvim_lsp['clangd'].setup {
  capabilities = capabilities,
  cmd = {
    "clangd", "--background-index", "--completion-style=detailed",
    "--header-insertion=never", "-j=8"
  },
  on_attach = on_attach
}

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
