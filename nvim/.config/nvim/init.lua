local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-------------------- PLUGINS -------------------------------

-- Auto install packer.nvim if not exists
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local packer_init_required = vim.fn.isdirectory(packer_install_path) == 0
if packer_init_required then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.api.nvim_command 'packadd packer.nvim'
end
vim.api.nvim_exec(
  [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
  ]],
  false
)

-- Start up packer, sync packages afterwards if required
require('packer').startup({function()
  local use = require('packer').use

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Speedup plugin loading
  use 'lewis6991/impatient.nvim'

  -- treesitter
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'RRethy/nvim-treesitter-textsubjects'
  use 'mizlan/iswap.nvim'

  -- nvim-lsp
  use 'neovim/nvim-lspconfig'
  use 'ray-x/lsp_signature.nvim'
  use 'williamboman/nvim-lsp-installer'
  use { 'folke/trouble.nvim', requires = 'kyazdani42/nvim-web-devicons' }

  -- telescope
  use {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/popup.nvim', 'nvim-lua/plenary.nvim'} }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'nvim-telescope/telescope-symbols.nvim'
  use 'nvim-telescope/telescope-z.nvim'

  -- lualine
  use {'windwp/windline.nvim', requires = {'kyazdani42/nvim-web-devicons', opt = true} }

  -- nvim-tree
  use {'kyazdani42/nvim-tree.lua', requires = {'kyazdani42/nvim-web-devicons', opt = true} }

  -- nvim-cmp and snippets
  use {'hrsh7th/nvim-cmp',
    requires = {
      {'L3MON4D3/LuaSnip'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},
      {'saadparwaiz1/cmp_luasnip'},
    }
  }

  use {'ggandor/lightspeed.nvim', -- the new sneak
    requires = {},
    config = function ()
      require'lightspeed'.setup {
        limit_ft_matches = 1,
      }
      vim.api.nvim_set_keymap('n', 'f', '<Plug>Lightspeed_s', {noremap = false})
      vim.api.nvim_set_keymap('n', 'F', '<Plug>Lightspeed_S', {noremap = false})
      vim.api.nvim_set_keymap('v', 'f', '<Plug>Lightspeed_s', {noremap = false})
      vim.api.nvim_set_keymap('v', 'F', '<Plug>Lightspeed_S', {noremap = false})
    end
  }

  -- alpha startscreen
  use { 'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' } ,
    config = function ()
      local alpha = require'alpha'
      local startify = require'alpha.themes.startify'
      startify.section.bottom_buttons.val = {
        startify.button( "c", "  Edit config" , ":e ~/.config/nvim/init.lua<CR>"),
        startify.button( "q", "  Quit neovim" , ":qa<CR>"),
      }
      alpha.setup(startify.opts)
    end
  }

  -- barbar
  use {'romgrk/barbar.nvim', requires = {'kyazdani42/nvim-web-devicons'} }

  -- Smooth Scrolling
  use {'karb94/neoscroll.nvim', keys = { "<C-u>", "<C-d>", "gg", "G" },
    config = function()
      require('neoscroll').setup({easing_function = 'circular',})
    end
  }
  use 'edluffy/specs.nvim'

  -- persistence
  use { 'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    module = 'persistence',
    config = function()
      require('persistence').setup()
    end,
  }


  -- notify
  use 'rcarriga/nvim-notify'

  use { 'tpope/vim-scriptease',
    cmd = {
      "Messages", --view messages in quickfix list
      "Verbose", -- view verbose output in preview window.
      "Time", -- measure how long it takes to run some stuff.
    },
  }

  -- the usual
  use 'mhinz/vim-signify'
  use 'tpope/vim-repeat'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
  use 'kevinhwang91/nvim-bqf'

  -- theme
  use 'sainnhe/gruvbox-material'

  use {'folke/zen-mode.nvim', config = function() require('zen-mode').setup {} end }
  use {'onsails/lspkind-nvim', config = function() require('lspkind').init {} end }

  use 'danymat/neogen'
  use 'lukas-reineke/indent-blankline.nvim' -- indent line
  use 'windwp/nvim-autopairs' -- insert pairs automatically
  use 'b3nj5m1n/kommentary' -- comments
  use 'mcchrish/nnn.vim' -- best file browser
  use 'RRethy/vim-illuminate'
  use 'numtostr/FTerm.nvim'
  use 'christoomey/vim-tmux-navigator'
  use 'tversteeg/registers.nvim'

end,
config = {
  compile_path = vim.fn.stdpath('config')..'/lua/packer_compiled.lua',
  profile = {
    enable = false,
    threshold = 0,
  }
}})
if packer_init_required then
 require'packer'.sync()
end
require('impatient')
require('packer_compiled')

-------------------- Theme Setup --------------------------
vim.o.background = "dark" -- or "light" for light mode
if vim.fn.has('termguicolors') == 1 then
   vim.o.termguicolors = true
end
vim.cmd [[colorscheme gruvbox-material]]

-------------------- Basic Setup --------------------------
require'fl.core'
require'fl.globals'
--

-------------------- Plugin Setup --------------------------
-- TREESITTER
local treesitter_config = require 'nvim-treesitter.configs'
treesitter_config.setup {
  ensure_installed = 'maintained',
  ignore_install = { 'elixir' },
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
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["if"] = "@function.outer",
        ["im"] = "@block.outer",
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [")"] = "@function.outer",
      },
      goto_next_end = {
        ["}"] = "@block.outer",
      },
      goto_previous_start = {
        ["("] = "@function.outer",
        ["{"] = "@block.outer",
      },
    },
  },
}

-- TELESCOPE
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
      },
    },
    preview_title = "",
    path_display = function(opts, path)
      local Path = require('plenary.path')
      local strings = require('plenary.strings')
      local tail = require("telescope.utils").path_tail(path)
      local filename = strings.truncate(tail, 45)
      filename = filename .. string.rep(" ", 45 - #tail)
      local cwd
      if opts.cwd then
        cwd = opts.cwd
        if not vim.in_fast_event() then
          cwd = vim.fn.expand(opts.cwd)
        end
      else
        cwd = vim.loop.cwd();
      end
      local relative = Path:new(path):make_relative(cwd)
      relative = strings.truncate(relative, #relative - #tail + 1)
      return string.format("%s  %s", filename, relative)
    end,
    winblend = 0,

    layout_strategy = "horizontal",
    layout_config = {
      height = 0.7,
      prompt_position = "top",
    },

    selection_strategy = "reset",
    sorting_strategy = "ascending",
    scroll_strategy = "cycle",
    color_devicons = true,
  },
  extensions = {
  }
}
require'telescope'.load_extension('fzf')
require'telescope'.load_extension('z')

map('n', '<C-l>', "<cmd>lua require('telescope.builtin').buffers({sort_mru=true, sort_lastused=true, previewer=false})<cr>")
map('n', '<leader>h', "<cmd>lua require('telescope.builtin').command_history()<cr>")
map('n', '<leader>sc', "<cmd>lua require('telescope.builtin').commands()<cr>")
map('n', '<leader>sd', "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/dotfiles'})<cr>")
map('n', '<leader>sf', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
map('n', '<leader>sh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
map('n', '<leader>sj', "<cmd>lua require'telescope'.extensions.z.list({sorter = require'telescope.sorters'.get_fuzzy_file()})<CR>", {silent=true})
map('n', '<leader>sl', "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true, cwd_only=true, previewer=false})<cr>")
map('n', '<leader>sp', "<cmd>lua require('telescope.builtin').registers()<cr>")
map('n', '<leader>sq', "<cmd>lua require('telescope.builtin').quickfix()<cr>")
map('n', '<leader>st', "<cmd>lua require('telescope.builtin').treesitter()<cr>")

map('n', '<C-p>', ':lua R("fl.functions").myfiles({})<CR>', {noremap = true, silent = true})
map('n', '<leader>mg', ':lua R("fl.functions").mygrep({list_files_only=false})<CR>', {noremap = true, silent = true})
map('n', '<leader>ml', ':lua R("fl.functions").mygrep({list_files_only=true})<CR>', {noremap = true, silent = true})

-- NVIM CMP
local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup {
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  sources = {
    { name = 'nvim_lua'},
    { name = 'nvim_lsp'},
    { name = 'luasnip'},
    { name = 'buffer', keyword_length = 4},
    { name = 'path'},
  },
  snippet = {
    expand = function(args)
      require'luasnip'.lsp_expand(args.body)
    end
  },
  formatting = {
    format = require'lspkind'.cmp_format({
      with_text = true,
      menu = {
        nvim_lua = "[api]",
        nvim_lsp = "[lsp]",
        luasnip = "[snp]",
        buffer = "[buf]",
        path = "[pth]",
      },
      maxwidth = 55
    })
  },
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ['<C-j>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<C-k>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
}

-- NVIMTREE
vim.g.nvim_tree_quit_on_open = 1
require'nvim-tree'.setup {
  auto_close = true,
  highjack_cursor = true,
  quit_on_open = true,
  update_focused_file = {
    enable = true,
  },
  view = {
    width = 50,
  }
}
map('n', '<leader>n', '<cmd>lua require"nvim-tree".find_file(true)<CR>')

-- ALPHA
map('n', '<C-s>', '<cmd>Alpha<CR>')

-- BARBAR
vim.g.bufferline = {
  letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
}
map('n', 'gh', "<cmd>BufferPrevious<CR>")
map('n', 'gl', "<cmd>BufferNext<CR>")
map('n', '<leader>j', "<cmd>BufferPick<CR>")
map('n', '<leader>bo', "<cmd>BufferCloseAllButCurrent<CR>")
map('n', '<leader>bd', "<cmd>BufferOrderByDirectory<CR>")
map('n', '<leader>q', "<cmd>BufferClose!<CR>")
map('n', '<A-o>', ':BufferMovePrevious<CR>', {silent = true})
map('n', '<A-p>', ':BufferMoveNext<CR>', {silent = true})


-- KOMMENTARY
require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
})
vim.api.nvim_set_keymap("n", "<leader>x", "<Plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("v", "<leader>x", "<Plug>kommentary_visual_default", {})

-- AUTOPAIRS
require('nvim-autopairs').setup()
require("nvim-autopairs.completion.cmp").setup({
  map_cr = true, --  map <CR> on insert mode
  map_complete = true -- it will auto insert `(` after select function or method item
})

-- INDENTLINE
vim.g.indentLine_enabled = 1
vim.g.indentLine_char = '│'
vim.g.indentLine_fileType = {'c', 'cpp', 'lua', 'python', 'vim'}
vim.g.indent_blankline_char_highlight = 'LineNr'
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- ILLUMINATE
vim.g.Illuminate_ftblacklist = {'nerdtree', 'startify', 'dashboard'}

-- NNN
require('nnn').setup({
	command = 'nnn -o -A',
	set_default_mappings = 0,
	replace_netrw = 1,
  layout = { window = { width= 0.6, height= 0.7, xoffset= 0.95, highlight= 'Debug'} },
})
map('n', '<c-n>', '<cmd>NnnPicker %:p:h<cr>', {silent = true})

-- FTERM
local shell = '/bin/fish'
if vim.fn.has('mac') == 1 then
  shell = '/usr/local/bin/fish'
end
require'FTerm'.setup({
  cmd = shell,
  border = 'double',
  dimensions  = {
      height = 0.8,
      width = 0.8,
      x = 0.9,
      y = 0.7
  },
})
map('n', '<A-i>', '<cmd>lua require("FTerm").toggle()<CR>', {silent = true})
map('t', '<A-i>', '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>', {silent = true})

-- STATUSLINE
require('fl.statusline')

------------------- Navigation + TMUX -----------------
vim.g.tmux_navigator_no_mappings = 1
map('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>', {silent = true})
map('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>', {silent = true})
map('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>', {silent = true})
map('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>', {silent = true})
map('n', '<A-,>', '<cmd>split<cr>', {silent = true})
map('n', '<A-.>', '<cmd>vsplit<cr>', {silent = true})

-------------------  TROUBLE
require("trouble").setup {
  auto_close = true,
}
vim.api.nvim_set_keymap("n", "<leader>oo", "<cmd>TroubleToggle<cr>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<leader>od", "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<leader>ow", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", {silent = true, noremap = true})
vim.api.nvim_set_keymap("n", "<leader>oq", "<cmd>TroubleToggle quickfix<cr>", {silent = true, noremap = true})

------------------- SCROLL + SPECS
require("specs").setup {
  show_jumps = true,
  min_jump = 5,
  popup = {
    delay_ms = 0, -- delay before popup displays
    inc_ms = 20, -- time increments used for fade/resize effects
    blend = 10, -- starting blend, between 0-100 (fully transparent), see :h winblend
    width = 20,
    winhl = "PMenu",
    fader = require("specs").linear_fader,
    resizer = require("specs").shrink_resizer,
  },
  ignore_filetypes = {},
  ignore_buftypes = { nofile = true },
}

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
  buf_set_keymap('n', '<leader>sa', "<cmd>lua require'telescope.builtin'.lsp_code_actions(require'telescope.themes'.get_cursor())<CR>", opts)
  buf_set_keymap('n', '<leader>sr', "<cmd>lua require'telescope.builtin'.lsp_references()<cr>", opts)
  buf_set_keymap('n', '<leader>sy', "<cmd>lua require'telescope.builtin'.lsp_document_symbols({symbol_width = 50, symbol_type_width = 12})<cr>", opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  vim.cmd("highlight LspDiagnosticsVirtualTextError guifg='#EEEEEE'")

  require 'lsp_signature'.on_attach({bind = true, floating_window = false, hint_prefix = '  '})
  require 'illuminate'.on_attach(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

nvim_lsp['clangd'].setup {
  capabilities = capabilities,
  cmd = {
    "clangd", "--background-index", "--completion-style=detailed", "--suggest-missing-includes",
    "--header-insertion=never", "-j=8"
  },
  on_attach = on_attach
}

-- Configure lua language server for neovim development
local lua_settings = {
  Lua = {
    runtime = {
      -- LuaJIT in the case of Neovim
      version = 'LuaJIT',
      path = vim.split(package.path, ';'),
    },
    completion = {
      keywordSnippet = "Disable",
      showWord = "Disable",
    },
    diagnostics = {
      -- Get the language server to recognize the `vim` global
      enable = true,
      globals = {'vim'},
    },
    workspace = {
      -- Make the server aware of Neovim runtime files
      library = {
        [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
      },
    },
  }
}

-- Setup LSPINSTALL servers
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.on_server_ready(function(server)
  local opts = {
    capabilities = capabilities,
    on_attach = on_attach
  }
  if server.name == "sumneki_lua" then
    opts.settings = lua_settings
  end
  -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
  server:setup(opts)
  vim.cmd [[ do User LspAttachBuffers ]]
end)

------------------------- LUASNIP ----------------------------
require("luasnip").snippets = require('fl.snippets').snippets

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

map('n', '<leader>cd', '<cmd>lua R("fl.functions").generate_compile_commands()<CR>')
