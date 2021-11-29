require'fl.globals'
require'fl.core'
require'fl.plugins'

-------------------- Plugin Setup --------------------------
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

local function map(mode, lhs, rhs, opts) -- map keybind
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
map('n', '<C-l>', "<cmd>lua require('telescope.builtin').buffers({sort_mru=true, sort_lastused=true, previewer=false})<cr>")
map('n', '<leader>h', "<cmd>lua require('telescope.builtin').command_history()<cr>")
map('n', '<leader>sb', "<cmd>lua require('telescope.builtin').symbols()<cr>")
map('n', '<leader>sc', "<cmd>lua require('telescope.builtin').commands()<cr>")
map('n', '<leader>sf', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>")
map('n', '<leader>sh', "<cmd>lua require('telescope.builtin').help_tags()<cr>")
map('n', '<leader>sl', "<cmd>lua require('telescope.builtin').oldfiles({include_current_session=true, cwd_only=true, previewer=false})<cr>")
map('n', '<leader>sp', "<cmd>lua require('telescope.builtin').registers()<cr>")
map('n', '<leader>sq', "<cmd>lua require('telescope.builtin').quickfix()<cr>")
map('n', '<leader>st', "<cmd>lua require('telescope.builtin').treesitter()<cr>")
map('n', '<leader>sz', "<cmd>lua require'telescope'.extensions.z.list()<CR>", {silent=true})

map('n', '<C-p>', ':lua R("fl.functions").myfiles({})<CR>', {noremap = true, silent = true})
map('n', '<leader>mg', ':lua R("fl.functions").mygrep({list_files_only=false})<CR>', {noremap = true, silent = true})
map('n', '<leader>ml', ':lua R("fl.functions").mygrep({list_files_only=true})<CR>', {noremap = true, silent = true})

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
    vim.cmd([[
      au BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)
    ]])
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
