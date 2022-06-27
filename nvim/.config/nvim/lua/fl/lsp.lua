local nvim_lsp = require('lspconfig')
local util = require('lspconfig.util')

local default_on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }
  buf_set_keymap('n', '<leader>j', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<C-j>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('i', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>sa', "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap('n', '<leader>sr', "<cmd>lua require'telescope.builtin'.lsp_references()<cr>", opts)
  buf_set_keymap('n', '<leader>sy',
    "<cmd>lua require'telescope.builtin'.lsp_document_symbols({symbol_width = 50, symbol_type_width = 12})<cr>", opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    vim.cmd([[
    au BufWritePre *.cpp,*.h lua vim.lsp.buf.formatting_sync(nil, 1000)
    ]])
  end
  if client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("v", "<leader>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  vim.cmd("highlight LspDiagnosticsVirtualTextError guifg='#EEEEEE'")

  require 'lsp_signature'.on_attach({ bind = true, floating_window = false, hint_prefix = '  ' })
  require 'illuminate'.on_attach(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- C++
nvim_lsp['clangd'].setup {
  capabilities = capabilities,
  cmd = {
    "clangd", "--background-index", "--completion-style=detailed", "--suggest-missing-includes",
    "--header-insertion=never", "-j=8"
  },
  on_attach = default_on_attach
}

-- Rust
nvim_lsp['rust_analyzer'].setup {
  capabilities = capabilities,
  on_attach = default_on_attach
}

-- BUCK
local found_buckls_config, _ = pcall(require, 'lspconfig.server_configurations.buckls')
if found_buckls_config then
  nvim_lsp['buckls'].setup {
    capabilities = capabilities,
    on_attach = default_on_attach
  }
end

-- Python
if not string.find(vim.fn.expand(vim.loop.cwd()), "fbsource") then
  nvim_lsp['pyright'].setup {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_range_formatting = false
      default_on_attach(client, bufnr)
    end
  }
else
  vim.g.python3_host_prog = '/usr/local/bin/python3'
  vim.g.python_host_prog = '/usr/local/bin/python2'

  if (vim.env.PYLS_PATH == nil or vim.env.PYLS_PATH == '') then
    vim.notify("$PYLS_PATH not defined in environment. Cannot start python LSP.", "error")
  else
    nvim_lsp['pylsp'].setup {
      cmd = {
        vim.env.PYLS_PATH,
        "--verbose",
        "--log-file",
        "/tmp/flanggut-logs/pyls.log"
      },
      on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
        default_on_attach(client, bufnr)
      end,
      capabilities = capabilities,
      filetypes = { "python" },
      root_dir = util.root_pattern(".buckconfig"),
      single_file_support = false,
      settings = {
        pyls = {
          formatAlreadyFormattedFilesOnSave = false,
          BuckFormatOnSave = false,
          extraPaths = {},
          ThriftGoToDef = true,
          plugins = {
            jedi_completion = { enabled = true },
            jedi_definition = {
              enabled = true,
              follow_imports = true,
              follow_builtin_imports = true
            },
            jedi_hover = { enabled = true },
            jedi_references = { enabled = true },
            jedi_signature_help = { enabled = true },
            jedi_symbols = { enabled = true },
            fb_pyfmt_format = { enabled = true }
          }
        },
        completionDetailLimit = 50,
      },
      handlers = {
        ['window/showStatus'] = vim.lsp.handlers["window/showMessage"]
      },
    }
  end
end

-- setup lua
nvim_lsp['sumneko_lua'].setup(require('lua-dev').setup {
  lspconfig = {
    capabilities = capabilities,
    on_attach = default_on_attach
  }
}
)

-- Setup null-ls
local nls = require("null-ls")
nls.setup({
  debounce = 150,
  save_after_format = false,
  sources = {
    nls.builtins.diagnostics.flake8,
    nls.builtins.diagnostics.jsonlint,
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.formatting.black,
    nls.builtins.formatting.fish_indent,
    nls.builtins.formatting.json_tool,
  },
  on_attach = default_on_attach,
})
