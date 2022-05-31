-- Auto install packer.nvim if not exists
local packer_install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
local packer_init_required = vim.fn.isdirectory(packer_install_path) == 0

if packer_init_required then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  vim.api.nvim_command('packadd packer.nvim')
end

local packer_group = vim.api.nvim_create_augroup('PackerAutoCompile', {clear = true})
vim.api.nvim_create_autocmd('BufWritePost', {
  pattern = 'plugins.lua',
  command = 'source <afile> | PackerCompile',
  group = packer_group,
})

-- Start up packer, sync packages afterwards if required
require('packer').startup({function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Theme
  use {
    'sainnhe/gruvbox-material',
    config = function ()
      vim.cmd [[colorscheme gruvbox-material]]
    end
  }
  use 'kyazdani42/nvim-web-devicons'

  -- treesitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function ()
      require'fl.treesitter'
    end
  }
  use {
    'nvim-treesitter/nvim-treesitter-context',
    config = function ()
      require'treesitter-context'.setup{}
    end
  }
  use 'nvim-treesitter/nvim-treesitter-refactor'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'nvim-treesitter/playground'
  use 'RRethy/nvim-treesitter-textsubjects'
  use 'mizlan/iswap.nvim'
  use 'mfussenegger/nvim-ts-hint-textobject'

  use {
    'nvim-lua/plenary.nvim',
    config = function ()
      require'plenary.filetype'.add_file("fl")
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

  -- notify
  use {
    'rcarriga/nvim-notify',
    config = function ()
      vim.notify = require'notify'
    end
  }

  -- nvim-lsp
  use {
    'neovim/nvim-lspconfig',
    opt = true,
    event = 'BufRead',
    requires = {
      'ray-x/lsp_signature.nvim',
      'folke/lua-dev.nvim',
      'jose-elias-alvarez/null-ls.nvim',
      'RRethy/vim-illuminate',
    },
    wants = {
      'lua-dev.nvim',
      'cmp-nvim-lsp',
      'null-ls.nvim',
      'nvim-cmp'
    },
    config = function()
      require'fl.lsp'
    end,
  }

  -- statusline
  use {
    'windwp/windline.nvim',
    requires = {'kyazdani42/nvim-web-devicons'},
    config = function ()
      require'fl.statusline'
    end
  }

  -- lsp status fidget
  use {
    'j-hui/fidget.nvim',
    opt = true,
    event = 'BufReadPre',
    config = function ()
      require'fidget'.setup{
        text = {
          spinner = 'dots'
        }
      }
    end
  }

  -- nvim-cmp and snippets
  use {
    'hrsh7th/nvim-cmp',
    opt = true,
    event = 'BufRead',
    wants = { 'LuaSnip' },
    requires = {
      {'hrsh7th/cmp-buffer'},
      {'hrsh7th/cmp-path'},
      {'hrsh7th/cmp-nvim-lsp'},
      {'hrsh7th/cmp-nvim-lua'},
      {'hrsh7th/cmp-cmdline'},
      {'saadparwaiz1/cmp_luasnip'},
      {
        'L3MON4D3/LuaSnip',
        config = function ()
          require('luasnip').config.set_config {
            history = true,
            updateevents = "TextChanged,TextChangedI",
          }
          require('fl.snippets').load()
          local snippets_group = vim.api.nvim_create_augroup('ReloadSnippetsOnWrite', {clear = true})
          vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = 'snippets.lua',
            callback = function ()
              R('fl.snippets').load()
              require'cmp_luasnip'.clear_cache()
            end,
            group = snippets_group,
          })
        end
      },
    },
    config = function ()
      require('fl.completion')
    end
  }

  -- dressing, better default ui
  use {
    'stevearc/dressing.nvim',
    event = 'BufReadPre'
  }

  use {
    'ggandor/leap.nvim',
    config = function ()
      require('leap').setup {
        case_insensitive = true,
      }
      require('leap').set_default_keymaps(true)
      local function leap_bidirectional()
        require'leap'.leap { ['target-windows'] = { vim.api.nvim_get_current_win() } }
      end
      vim.keymap.set('n', 'f', leap_bidirectional, { silent = true })
    end
  }

  -- alpha startscreen
  use { 'goolord/alpha-nvim',
    requires = { 'kyazdani42/nvim-web-devicons' } ,
    config = function ()
      local alpha = require'alpha'
      local startify = require'alpha.themes.startify'
      startify.section.top_buttons.val = {
        startify.button( "l", "  Open last session", ":lua require'persistence'.load()<CR>", {}),
        startify.button( "e", "  New file", ":ene <CR>", {}),
      }
      startify.section.bottom_buttons.val = {
        startify.button( "c", "  Edit config" , ":e ~/.config/nvim/lua/fl/plugins.lua<CR>", {}),
        startify.button( "q", "  Quit neovim" , ":qa<CR>", {}),
      }
      alpha.setup(startify.opts)
      vim.api.nvim_set_keymap('n', '<C-s>', '<cmd>Alpha<CR>', {noremap = true})
    end
  }

  -- bufferline
  use {
    'akinsho/bufferline.nvim',
    requires = {'kyazdani42/nvim-web-devicons'},
    opt = true,
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

  -- Smooth Scrolling
  use {
    'karb94/neoscroll.nvim',
    opt = true,
    event = 'BufRead',
    config = function()
      require('neoscroll').setup({easing_function = 'circular',})
    end
  }
  use {
    'edluffy/specs.nvim',
    opt = true,
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
    opt = true,
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    module = 'persistence',
    config = function()
      require('persistence').setup()
    end,
  }

  -- mini
  use {
    'echasnovski/mini.nvim',
    opt = true,
    event = 'BufReadPre',
    config = function()
      require('mini.indentscope').setup{
        symbol = '│',
        draw = {
          animation = function() return 10 end,
        }
      }
    end
  }
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


  -- comments
  use { 'numToStr/Comment.nvim',
    opt = true,
    keys = { '<space>x' },
    config = function()
      require('Comment').setup{}
      vim.api.nvim_set_keymap('n', '<space>x', 'gcc', {silent = true})
      vim.api.nvim_set_keymap('x', '<space>x', 'gc', {silent = true})
    end
  }

  -- NNN
  use { 'mcchrish/nnn.vim',
    opt = true,
    keys = { '<c-n>' },
    config = function()
      require('nnn').setup({
        command = 'nnn -o -A',
        set_default_mappings = 0,
        replace_netrw = 1,
        layout = { window = { width= 0.6, height= 0.7, xoffset= 0.95, highlight= 'Debug'} },
      })
      local function nnn_pick()
        local path = vim.fn.expand('%:p', nil, nil)
        local nnn_command = path == '' and 'NnnPicker' or ('NnnPicker' .. path)
        vim.api.nvim_command(nnn_command)
      end
      vim.keymap.set('n', '<c-n>', nnn_pick, {silent = true})
    end,
  }

  use {
    'windwp/nvim-autopairs',
    opt = true,
    after = 'nvim-cmp',
    config = function ()
      require'nvim-autopairs'.setup()
    end
  }

  -- documentation generator
  use {
    'danymat/neogen',
    opt = true,
    event = 'BufRead',
    config = function ()
      require'neogen'.setup {
        enabled = true
      }
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
    opt = true,
    keys = { '<A-i>' },
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
  use 'kevinhwang91/nvim-bqf'
  use 'tversteeg/registers.nvim'
  use { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' }
  use { 'mhinz/vim-signify', event = 'BufRead', }
  use { 'tpope/vim-scriptease', cmd = { 'Messages', 'Verbose', 'Time' }, }

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
        i = {
          d = { "<cmd>lua require('neogen').generate()<CR>", "Generate documentation" },
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
        l = { "<cmd>LspRestart<CR>", "Restart LSP servers" },
      }
      wk.register(leaderleader, { prefix = "<leader><leader>" })

      wk.register({["<C-l>"] = { "<cmd>lua require('telescope.builtin').buffers()<cr>", "Buffers" }})
      wk.register({["<C-k>"] = {
        function()
          require("telescope.builtin").lsp_document_symbols({
            symbols = { "Class", "Function", "Method", "Constructor", "Interface", "Module" },
            symbol_width = 50,
            symbol_type_width = 12,
          })
        end,
        "Goto Symbol",
      }})
    end
  }
  if packer_init_required then
    require'packer'.sync()
  end
end,
  config = {
    display = {
      open_fn = require('packer.util').float,
    },
  }
})
