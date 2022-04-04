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

-- Start up packer, sync packages afterwards if required
require('packer').startup({function()
  local use = require('packer').use

  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Speedup plugin loading
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
  use {
    'lewis6991/spellsitter.nvim',
    config = function()
      require('spellsitter').setup()
    end
  }

  -- nvim-lsp
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'ray-x/lsp_signature.nvim',
      'williamboman/nvim-lsp-installer',
      'folke/lua-dev.nvim',
      'jose-elias-alvarez/null-ls.nvim',
    },
    wants = {
      'lua-dev.nvim',
      'cmp-nvim-lsp',
      'nvim-lsp-installer',
      'null-ls.nvim'
    },
    config = function()
      require'fl.lsp'
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
      vim.api.nvim_set_keymap("n", "F", "<cmd>Telescope current_buffer_fuzzy_find<cr>", {silent = true, noremap = true})
    end
  }
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {'nvim-telescope/telescope-file-browser.nvim'}

  -- statusline
  use {'windwp/windline.nvim',
    requires = {'kyazdani42/nvim-web-devicons', opt = true},
    config = function ()
      require'fl.statusline'
    end
  }
  use {
    "SmiteshP/nvim-gps",
    requires = "nvim-treesitter/nvim-treesitter",
    config = function ()
      require("nvim-gps").setup()
    end
  }

  -- lsp status fidget
  use {
    'j-hui/fidget.nvim',
    config = function ()
      require'fidget'.setup{
        text = {
          spinner = "dots"
        }
      }
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
  use {
    'L3MON4D3/LuaSnip',
    config = function ()
      require('luasnip').config.set_config {
        history = true,
        updateevents = "TextChanged,TextChangedI",
      }
      require('fl.snippets').load()
      vim.cmd([[
        command! ReloadSnippets lua R('fl.snippets').load()
        augroup reload_snippets
        au!
        au BufWritePost snippets.lua ReloadSnippets
        augroup END
      ]])
    end
  }

  -- dressing, better default ui
  use {'stevearc/dressing.nvim'}

  use {'ggandor/lightspeed.nvim', -- the new sneak?
    requires = {},
    config = function ()
      require'lightspeed'.setup {
        ignore_case = true
      }
      vim.api.nvim_set_keymap('n', 'f', '<Plug>Lightspeed_omni_s', {})
      vim.api.nvim_set_keymap('n', 's', '<Plug>Lightspeed_f', {})
      vim.api.nvim_set_keymap('n', 'S', '<Plug>Lightspeed_F', {})
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
        startify.button( "l", "  Open last session", ":lua require'persistence'.load()<CR>"),
        startify.button( "e", "  New file", ":ene <CR>"),
        startify.button( "o", "  Neorg", ":Neorg workspace meta<CR>"),
      }
      startify.section.bottom_buttons.val = {
        startify.button( "c", "  Edit config" , ":e ~/.config/nvim/lua/fl/plugins.lua<CR>"),
        startify.button( "q", "  Quit neovim" , ":qa<CR>"),
      }
      alpha.setup(startify.opts)
      vim.api.nvim_set_keymap('n', '<C-s>', '<cmd>Alpha<CR>', {noremap = true})
    end
  }

  -- bufferline
  use {
    'akinsho/bufferline.nvim',
    requires = {'kyazdani42/nvim-web-devicons'},
    event = "BufReadPre",
    config = function()
      require('bufferline').setup{
        options = {
          show_close_icon = false,
          show_buffer_close_icons = false,
          sort_by = 'relative_directory',
          max_name_length = 35,
        },
        highlights = {
          buffer_selected = {
            gui = "bold"
          },
          fill = {
            guibg = {
              attribute = "bg",
              highlight = "Normal"
            }
          },
        }
      }

      vim.api.nvim_set_keymap('n', 'gh', ':BufferLineCyclePrev<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', 'gl', ':BufferLineCycleNext<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', 'gj', ':BufferLinePick<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', 'gq', ':BufferLinePickClose<CR>', { noremap = true, silent = true })
    end
  }

  -- harpoon
  use {
    'ThePrimeagen/harpoon',
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
  use {
    'rcarriga/nvim-notify',
    config = function ()
      vim.notify = require'notify'
    end
  }

  -- mini
  use {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.indentscope').setup{
        symbol = '│',
        draw = {
          animation = function() return 10 end,
        }
      }
    end
  }

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
    'nvim-neorg/neorg',
    requires = {"nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope"},
    config = function()
      require('neorg').setup ({
        load = {
          ["core.defaults"] = {},
          ["core.integrations.telescope"] = {},
          ["core.keybinds"] = {
            config = {
              default_keybinds = true, -- Generate the default keybinds
              neorg_leader = "<Leader>o" -- This is the default if unspecified
            }
          },
          ["core.norg.concealer"] = {},
          ["core.norg.completion"] = {
            config = {
              engine = "nvim-cmp"
            }
          },
          ["core.norg.dirman"] = {
            config = {
              workspaces = {
                meta = "~/neorg",
              }
            }
          },
          ["core.gtd.base"] = {
            config = {
              workspace = "meta",
            }
          },
          ["core.norg.journal"] = {},
        },
      })
    end,
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
    event = "BufReadPre",
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
  use 'tpope/vim-repeat'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
  use 'kevinhwang91/nvim-bqf'
  use 'tversteeg/registers.nvim'

  use {
    'mhinz/vim-signify',
    opt = true,
    event = 'BufRead',
  }

  -- keys
  use {
    'folke/which-key.nvim',
    config = function()
      local wk = require("which-key")
      wk.setup {}
      local leader = {
        a = {
          s = { "<cmd>ISwapWith<CR>", "Swap argument with other" }
        },
        c = {
          d = { "<cmd>lua R('fl.functions').generate_compile_commands()<CR>", "Compile commands" }
        },
        h = {
          name = "+harpoon",
          i = { "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>", "List Files" },
          f = { "<cmd>lua require('harpoon.mark').add_file()<CR>", "Add File" },
        },
        i = {
          d = { "<cmd>lua require('neogen').generate()<CR>", "Generate documentation" },
        },
        k = {
          function()
            require("telescope.builtin").lsp_document_symbols({
              symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
              symbol_width = 50,
              symbol_type_width = 12,
            })
          end,
          "Goto Symbol",
        },
        o = {
          p = { "<cmd>lua R('fl.functions').open_in_browser()<CR>", "Open in browser" }
        },
        p = { "<cmd>w<CR><cmd>lua R('fl.functions').file_runner()<CR>", "Python" },
        q = { "<cmd>bdelete!<CR>", "Close Buffer" },
        s = {
          name = "+search",
          d = { "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/dotfiles'})<cr>", "Dotfiles" },
          f = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Buffer Fuzzy" },
          h = { "<cmd>Telescope command_history<cr>", "Command History" },
          H = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
          s = { "<cmd>Telescope treesitter<cr>", "Treesitter" },
          v = { "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/.local/share/nvim/site/pack/packer/'})<cr>", "Vim Plugins" },
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
      local leaderleader = {
        h = { "<cmd>Telescope help_tags<cr>", "Help Tags" },
        s = { "<cmd>lua R('fl.snippets').load()<CR>", "Reload snippets" },
      }
      wk.register(leaderleader, { prefix = "<leader><leader>" })
      wk.register({["<C-l>"] = { "<cmd>lua require('telescope.builtin').buffers()<cr>", "Buffers" }})
    end
  }

end,
  config = {
    display = {
      open_fn = require('packer.util').float,
    },
    profile = {
      enable = true,
      threshold = 0,
    },
  }
})
if packer_init_required then
  require'packer'.sync()
end

require("plenary.filetype").add_file("fl")
