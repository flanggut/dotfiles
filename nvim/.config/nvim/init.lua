require'fl.globals'
require'fl.core'
require'fl.plugins'

local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-------------------- Theme Setup --------------------------
vim.o.background = "dark" -- or "light" for light mode
if vim.fn.has('termguicolors') == 1 then
   vim.o.termguicolors = true
end
vim.cmd [[colorscheme gruvbox-material]]

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
map('o', 'm', ':<C-U>lua require("tsht").nodes()<CR>', {noremap = false, silent = true})
map('v', 'm', ':lua require("tsht").nodes()<CR>', {noremap = true, silent = true})

-- TELESCOPE
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = require('telescope.actions').close,
        ["<C-j>"] = require('telescope.actions').move_selection_next,
        ["<C-k>"] = require('telescope.actions').move_selection_previous,
        ["<C-e>"] = require('telescope.actions').delete_buffer,
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
-- map('n', '<C-l>', "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true, cwd_only=true, previewer=false})<cr>")
map('n', '<leader>h', "<cmd>lua require('telescope.builtin').command_history()<cr>")
map('n', '<leader>sc', "<cmd>lua require('telescope.builtin').commands()<cr>")
map('n', '<leader>sd', "<cmd>lua require('telescope.builtin').find_files({hidden=true, cwd='~/dotfiles'})<cr>")
map('n', '<leader>sf', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
map('n', '<leader>sh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
-- map('n', '<leader>sl', "<cmd>lua require('telescope.builtin').buffers({sort_mru=true, sort_lastused=true, previewer=false})<cr>")
map('n', '<leader>sl', "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true, cwd_only=true, previewer=false})<cr>")
map('n', '<leader>sp', "<cmd>lua require('telescope.builtin').registers()<cr>")
map('n', '<leader>sq', "<cmd>lua require('telescope.builtin').quickfix()<cr>")
map('n', '<leader>st', "<cmd>lua require('telescope.builtin').treesitter()<cr>")
map('n', '<leader>sz', "<cmd>lua require'telescope'.extensions.z.list()<CR>", {silent=true})

map('n', '<C-p>', ':lua R("fl.functions").myfiles({})<CR>', {noremap = true, silent = true})
map('n', '<leader>mg', ':lua R("fl.functions").mygrep({list_files_only=false})<CR>', {noremap = true, silent = true})
map('n', '<leader>ml', ':lua R("fl.functions").mygrep({list_files_only=true})<CR>', {noremap = true, silent = true})

-- NVIM CMP
local cmp = require('cmp')
local luasnip = require('luasnip')
cmp.setup {
  experimental = {
    ghost_text = true,
  },
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
    format = function(entry, vim_item)
      local lspkind_format = require'lspkind'.cmp_format({
        with_text = true,
        menu = {
          nvim_lua = "[api]",
          nvim_lsp = "[lsp]",
          luasnip = "[snp]",
          buffer = "[buf]",
          path = "[pth]",
        },
        maxwidth = 60
      })
      vim_item.abbr = vim_item.abbr:gsub("^%s+", "")
      return lspkind_format(entry, vim_item)
    end
  },
  mapping = {
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-f>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<C-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
    ["<CR>"] = cmp.mapping.confirm {
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

-- INDENTLINE
vim.g.indentLine_enabled = 1
vim.g.indentLine_char = '│'
vim.g.indentLine_fileType = {'c', 'cpp', 'lua', 'python', 'vim'}
vim.g.indent_blankline_char_highlight = 'LineNr'
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- ILLUMINATE
vim.g.Illuminate_ftblacklist = {'nerdtree', 'startify', 'dashboard'}

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
map('n', '<A-t>', '<cmd>lua require("FTerm").toggle()<CR>', {silent = true})
map('t', '<A-t>', '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>', {silent = true})

------------------- Navigation + TMUX -----------------
vim.g.tmux_navigator_no_mappings = 1
map('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>', {silent = true})
map('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>', {silent = true})
map('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>', {silent = true})
map('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>', {silent = true})
map('n', '<A-.>', '<cmd>FocusSplitRight<cr>', {silent = true})

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

-- Setup LSPINSTALL servers
local luadev = require('lua-dev').setup({
  lspconfig = {
    capabilities = capabilities,
    on_attach = on_attach
  }
})

local lsp_installer = require("nvim-lsp-installer")
lsp_installer.on_server_ready(function(server)
  local opts = {
    capabilities = capabilities,
    on_attach = on_attach
  }
  if server.name == "sumneko_lua" then
    opts = luadev
  end
  -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
  server:setup(opts)
  vim.cmd [[ do User LspAttachBuffers ]]
end)

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
