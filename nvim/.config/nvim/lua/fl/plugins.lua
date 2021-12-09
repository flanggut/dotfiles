-- Auto install packer.nvim if not exists
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local packer_init_required = vim.fn.isdirectory(packer_install_path) == 0

if packer_init_required then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.api.nvim_command 'packadd packer.nvim'
end

vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

-- For nathom/filetype plugin. Remove after neovim 0.6.0 is released.
vim.g.did_load_filetypes = 1

-- Start up packer, sync packages afterwards if required
require('packer').startup({function()
  local use = require('packer').use

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Speedup plugin loading
  use 'nathom/filetype.nvim'
  use {'tweekmonster/startuptime.vim', cmd = 'StartupTime' }

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function ()
      require'fl.treesitter'
    end
  }
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'nvim-treesitter/playground'
  use 'RRethy/nvim-treesitter-textsubjects'
  use 'mizlan/iswap.nvim'
  use 'mfussenegger/nvim-ts-hint-textobject'

  -- nvim-lsp
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'ray-x/lsp_signature.nvim',
      'williamboman/nvim-lsp-installer',
      'folke/lua-dev.nvim',
    },
    wants = {
      'lua-dev.nvim',
      'cmp-nvim-lsp',
      'nvim-lsp-installer',
    },
    config = function()
      require('fl.lsp')
    end,
  }
  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function ()
      require("trouble").setup {
        auto_close = true,
      }
      vim.api.nvim_set_keymap("n", "<leader>oo", "<cmd>TroubleToggle<cr>", {silent = true, noremap = true})
      vim.api.nvim_set_keymap("n", "<leader>od", "<cmd>TroubleToggle lsp_workspace_diagnostics<cr>", {silent = true, noremap = true})
      vim.api.nvim_set_keymap("n", "<leader>ow", "<cmd>TroubleToggle lsp_document_diagnostics<cr>", {silent = true, noremap = true})
      vim.api.nvim_set_keymap("n", "<leader>oq", "<cmd>TroubleToggle quickfix<cr>", {silent = true, noremap = true})
    end
  }

  -- telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/popup.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'nvim-telescope/telescope-symbols.nvim',
      'nvim-telescope/telescope-z.nvim'
    },
    config = function ()
      require'fl.telescope'
    end
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  -- statusline
  use {'windwp/windline.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = function ()
      require('fl.statusline')
    end
  }

  -- nvim-cmp and snippets
  use {'hrsh7th/nvim-cmp',
    requires = {
      {'L3MON4D3/LuaSnip'},
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},
      {'hrsh7th/cmp-cmdline'},
      {'saadparwaiz1/cmp_luasnip'},
    },
    config = function ()
      require('fl.completion')
    end
  }
  use {'L3MON4D3/LuaSnip',
    config = function ()
      require("luasnip").snippets = require('fl.snippets').snippets
    end
  }

  use {'ggandor/lightspeed.nvim', -- the new sneak?
    requires = {},
    config = function ()
      require'lightspeed'.setup {}
      vim.api.nvim_set_keymap('n', 'f', '<Plug>Lightspeed_s', {noremap = false})
      vim.api.nvim_set_keymap('n', 'F', '<Plug>Lightspeed_S', {noremap = false})
      vim.api.nvim_set_keymap('x', 'f', '<Plug>Lightspeed_s', {noremap = false})
      vim.api.nvim_set_keymap('x', 'F', '<Plug>Lightspeed_S', {noremap = false})
      vim.api.nvim_set_keymap('o', 'f', '<Plug>Lightspeed_s', {noremap = false})
      vim.api.nvim_set_keymap('o', 'F', '<Plug>Lightspeed_S', {noremap = false})

      vim.api.nvim_set_keymap('n', 's', '<Plug>Lightspeed_f', {noremap = false})
      vim.api.nvim_set_keymap('n', 'S', '<Plug>Lightspeed_F', {noremap = false})
      vim.api.nvim_set_keymap('x', 's', '<Plug>Lightspeed_f', {noremap = false})
      vim.api.nvim_set_keymap('x', 'S', '<Plug>Lightspeed_F', {noremap = false})
      vim.api.nvim_set_keymap('o', 's', '<Plug>Lightspeed_f', {noremap = false})
      vim.api.nvim_set_keymap('o', 'S', '<Plug>Lightspeed_F', {noremap = false})
      vim.cmd(([[
      let g:lightspeed_last_motion = ''
      augroup lightspeed_last_motion
      autocmd!
      autocmd User LightspeedSxEnter let g:lightspeed_last_motion = 'sx'
      autocmd User LightspeedFtEnter let g:lightspeed_last_motion = 'ft'
      augroup end
      map <expr> ; g:lightspeed_last_motion == 'sx' ? "<Plug>Lightspeed_;_sx" : "<Plug>Lightspeed_;_ft"
      map <expr> , g:lightspeed_last_motion == 'sx' ? "<Plug>Lightspeed_,_sx" : "<Plug>Lightspeed_,_ft"
      ]]))
    end
  }

  -- alpha startscreen
  use { 'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' } ,
    config = function ()
      local alpha = require'alpha'
      local startify = require'alpha.themes.startify'
      startify.section.top_buttons.val = {
        startify.button( "o", "  Open last session", ":lua require'persistence'.load()<CR>"),
        startify.button( "e", "  New file", ":ene <CR>"),
      }
      startify.section.bottom_buttons.val = {
        startify.button( "c", "  Edit config" , ":e ~/.config/nvim/lua/fl/plugins.lua<CR>"),
        startify.button( "q", "  Quit neovim" , ":qa<CR>"),
      }
      alpha.setup(startify.opts)
      vim.api.nvim_set_keymap('n', '<C-s>', '<cmd>Alpha<CR>', {noremap = true})
    end
  }

  -- barbar
  use {'romgrk/barbar.nvim', requires = {'kyazdani42/nvim-web-devicons'},
    setup = function ()
      vim.g.bufferline = {
        letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',
        insert_at_end = true,
      }
      vim.api.nvim_set_keymap('n', 'gh', "<cmd>BufferPrevious<CR>", {noremap = true})
      vim.api.nvim_set_keymap('n', 'gl', "<cmd>BufferNext<CR>", {noremap = true})
      vim.api.nvim_set_keymap('n', '<space>j', "<cmd>BufferPick<CR>", {noremap = true})
      vim.api.nvim_set_keymap('n', '<space>bo', "<cmd>BufferCloseAllButCurrent<CR>", {noremap = true})
      vim.api.nvim_set_keymap('n', '<space>bd', "<cmd>BufferOrderByDirectory<CR>", {noremap = true})
      vim.api.nvim_set_keymap('n', '<space>q', "<cmd>BufferClose!<CR>", {noremap = true})
      vim.api.nvim_set_keymap('n', '<A-o>', ':BufferMovePrevious<CR>', {noremap = true, silent = true})
      vim.api.nvim_set_keymap('n', '<A-p>', ':BufferMoveNext<CR>', {noremap = true, silent = true})
    end
  }

  -- Smooth Scrolling
  use {
    'karb94/neoscroll.nvim', keys = { "<C-u>", "<C-d>", "gg", "G" },
    config = function()
      require('neoscroll').setup({easing_function = 'circular',})
    end
  }
  use {
    'edluffy/specs.nvim',
    after = 'neoscroll.nvim',
    config = function ()
      require'specs'.setup {
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
    end
  }

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

  -- comments
  use { 'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup{}
      vim.api.nvim_set_keymap('n', '<space>x', 'gcc', {silent = true})
      vim.api.nvim_set_keymap('x', '<space>x', 'gc', {silent = true})
    end
  }

  -- markdown
  use 'ellisonleao/glow.nvim'

  -- notes
  use {
    'renerocksai/telekasten.nvim',
    config = function()
      local home = vim.fn.expand("~/zettelkasten")
      require('telekasten').setup({
        home         = home,
        dailies      = home .. '/' .. 'daily',
        weeklies     = home .. '/' .. 'weekly',
        templates    = home .. '/' .. 'templates',
        extension    = ".md",

        -- following a link to a non-existing note will create it
        follow_creates_nonexisting = true,
        dailies_create_nonexisting = true,
        weeklies_create_nonexisting = true,

        -- template for new notes (new_note, follow_link)
        template_new_note = home .. '/' .. 'templates/new_note.md',

        -- template for newly created daily notes (goto_today)
        template_new_daily = home .. '/' .. 'templates/daily.md',

        -- template for newly created weekly notes (goto_thisweek)
        template_new_weekly= home .. '/' .. 'templates/weekly.md',
      })
    end
  }

  -- NNN
  use { 'mcchrish/nnn.vim',
    config = function()
      require('nnn').setup({
        command = 'nnn -o -A',
        set_default_mappings = 0,
        replace_netrw = 1,
        layout = { window = { width= 0.6, height= 0.7, xoffset= 0.95, highlight= 'Debug'} },
      })
      vim.api.nvim_set_keymap('n', '<c-n>', '<cmd>NnnPicker %:p<cr>', {silent = true, noremap = true})
    end,
  }

  use { 'lukas-reineke/format.nvim',
    config = function()
      require'format'.setup{
        ["*"] = {
          {cmd = {"sed -i 's/[ \t]*$//'"}} -- remove trailing whitespace
        },
      }
    end,
  }

  use { 'windwp/nvim-autopairs',
    after = 'nvim-cmp',
    config = function ()
      require'nvim-autopairs'.setup()
      require'cmp'.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
    end
  }

  use { 'chipsenkbeil/distant.nvim',
    config = function()
      require('distant').setup {
        -- Applies Chip's personal settings to every machine you connect to:
        -- 1. Ensures that distant servers terminate with no connections
        -- 2. Provides navigation bindings for remote directories
        -- 3. Provides keybinding to jump into a remote file's parent directory
        ['*'] = require('distant.settings').chip_default()
      }
    end
  }

  -- theme
  use {
    'sainnhe/gruvbox-material',
    config = function ()
      vim.cmd [[colorscheme gruvbox-material]]
    end
  }

  -- Illuminate variables
  use {
    'RRethy/vim-illuminate',
    config = function ()
      vim.g.Illuminate_ftblacklist = {'nerdtree', 'startify', 'dashboard'}
    end
  }

  -- documentation generator
  use {
    'danymat/neogen',
    config = function ()
      require'neogen'.setup {
        enabled = true
      }
    end
  }

  -- zen mode
  use {'folke/zen-mode.nvim', config = function() require('zen-mode').setup {} end }

  -- lsp kind symbols
  use {'onsails/lspkind-nvim', config = function() require('lspkind').init {} end }

  use {
    'lukas-reineke/indent-blankline.nvim',
    config = function ()
      vim.g.indentLine_enabled = 1
      vim.g.indentLine_char = '│'
      vim.g.indentLine_fileType = {'c', 'cpp', 'lua', 'python', 'vim'}
      vim.g.indent_blankline_char_highlight = 'LineNr'
      vim.g.indent_blankline_show_trailing_blankline_indent = false
    end
  }

  use {
    'christoomey/vim-tmux-navigator',
    config = function ()
      vim.g.tmux_navigator_no_mappings = 1
      vim.api.nvim_set_keymap('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>', {noremap= true, silent = true})
      vim.api.nvim_set_keymap('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>', {noremap= true, silent = true})
      vim.api.nvim_set_keymap('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>', {noremap= true, silent = true})
      vim.api.nvim_set_keymap('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>', {noremap= true, silent = true})
    end
  }

  -- Terminal
  use {
    'numtostr/FTerm.nvim',
    config = function ()
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
      vim.api.nvim_set_keymap('n', '<A-i>', '<cmd>lua require("FTerm").toggle()<CR>', {silent = true, noremap = true})
      vim.api.nvim_set_keymap('t', '<A-i>', '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>', {silent = true, noremap = true})
    end
  }

  -- the usual
  use 'mhinz/vim-signify'
  use 'tpope/vim-repeat'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
  use 'kevinhwang91/nvim-bqf'
  use 'tversteeg/registers.nvim'

  -- keys
  use {
    'folke/which-key.nvim',
    config = function()
      local wk = require("which-key")
      wk.setup {}
      local leader = {
        c = {
          d = { "<cmd>lua R('fl.functions').generate_compile_commands()<CR>", "Compile commands" }
        },
        i = {
          name = "+insert",
          d = { "<cmd>lua require('neogen').generate()<CR>", "Documentation" },
          s = { "<cmd>ISwap<CR>", "Swap arguments" },
          w = { "<cmd>ISwapWith<CR>", "Swap argument with other" }
        },
        o = {
          p = { "<cmd>lua R('fl.functions').open_in_browser()<CR>", "Compile commands" }
        },
        s = {
          name = "+search",
          d = { "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/dotfiles'})<cr>", "Dotfiles" },
          f = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer Fuzzy" },
          s = { "<cmd>Telescope treesitter<cr>", "Treesitter" },
          y = {
            function()
              require("telescope.builtin").lsp_document_symbols({
                symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
                symbol_width = 50,
                symbol_type_width = 12,
              })
            end,
            "Goto Symbol",
          },
        },
      }
      wk.register(leader, { prefix = "<leader>" })
    end
  }

end,
  config = {
    profile = {
      enable = true,
      threshold = 0,
    }
  }
})
if packer_init_required then
  require'packer'.sync()
end
