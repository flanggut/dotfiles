return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = "BufReadPre",
    dependencies = {
      -- "mason.nvim",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {},
      },
      "hrsh7th/cmp-nvim-lsp",
      -- "ray-x/lsp_signature.nvim",
      { "zeioth/garbage-day.nvim", event = "BufRead", opts = {} },
    },
    version = false,
    ---@class PluginLspOpts
    opts = {
      autoformat = true,
      -- -@type lspconfig.options
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
        pyright = {
          enabled = false,
        },
        -- basedpyright = {},
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      -- -@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    },
    config = function(_, opts)
      -- general setup
      vim.cmd("highlight LspDiagnosticsVirtualTextError guifg='#EEEEEE'")
      vim.lsp.set_log_level("off") -- use "debug" for detailed logs

      local on_show_message = vim.lsp.handlers["window/showMessage"]
      vim.lsp.handlers["window/showStatus"] = vim.lsp.with(on_show_message, {})

      -- setup autoformat
      require("fl.lazy.util.format").register(require("fl.lazy.util.lsp").formatter())

      -- setup on_attach
      require("fl.lazy.util").on_attach(function(client, buffer)
        require("fl.lazy.plugins.lsp.keymaps").on_attach(client, buffer)
        -- require("lsp_signature").on_attach({ bind = true, floating_window = false, hint_prefix = "  " }, buffer)
      end)

      -- setup default servers
      local lspconfig = require("lspconfig")
      local lsputil = require("lspconfig.util")
      local servers = opts.servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})
        lspconfig[server].setup(server_opts)
      end

      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          setup(server)
        end
      end

      -- C++
      local clangd_binary = "clangd"
      if vim.fn.isdirectory("/Users/flanggut/homebrew/opt/llvm") ~= 0 then
        clangd_binary = "/Users/flanggut/homebrew/opt/llvm/bin/clangd"
      end
      lspconfig["clangd"].setup({
        capabilities = capabilities,
        cmd = {
          clangd_binary,
          "--background-index",
          "--completion-style=detailed",
          "--header-insertion=never",
          "--offset-encoding=utf-16",
        },
      })

      -- Python
      ---@diagnostic disable-next-line: param-type-mismatch
      if not string.find(vim.fn.expand(vim.loop.cwd()), "ffbsource") then
        -- lspconfig.pylsp.setup({
        --   filetypes = { "python" },
        --   settings = {
        --     pylsp = {
        --       plugins = {
        --         -- formatter
        --         black = { enabled = false },
        --         autopep8 = { enabled = false },
        --         yapf = { enabled = false },
        --         -- linter
        --         flake8 = { enabled = false },
        --         pylint = { enabled = false, executable = "pylint" },
        --         pylsp_mypy = { enabled = false },
        --         mccabe = { enabled = false },
        --         pycodestyle = { enabled = false },
        --         pyflakes = { enabled = false },
        --         -- auto-completion options
        --         jedi_completion = { fuzzy = true },
        --         -- import sorting
        --         pyls_isort = { enabled = true },
        --       },
        --     },
        --   },
        -- })

        -- lspconfig.pyright.setup({
        --   capabilities = capabilities,
        --   on_attach = function(client, _)
        --     client.server_capabilities.document_formatting = false
        --     client.server_capabilities.document_range_formatting = false
        --   end,
        -- })
      else
        if vim.env.PYLS_PATH == nil or vim.env.PYLS_PATH == "" then
          ---@diagnostic disable-next-line: param-type-mismatch
          vim.notify("$PYLS_PATH not defined in environment. Cannot start python LSP.", "error")
        else
          vim.g.python3_host_prog = "/usr/local/bin/python3"
          vim.g.python_host_prog = "/usr/local/bin/python2"
          lspconfig["pylsp"].setup({
            cmd = {
              vim.env.PYLS_PATH,
              "--verbose",
              "--log-file",
              "/tmp/flanggut-logs/pyls.log",
            },
            on_attach = function(client, _)
              client.server_capabilities.document_formatting = false
              client.server_capabilities.document_range_formatting = false
            end,
            capabilities = capabilities,
            filetypes = { "python" },
            root_dir = lsputil.root_pattern(".buckconfig"),
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
                    follow_builtin_imports = true,
                  },
                  jedi_hover = { enabled = true },
                  jedi_references = { enabled = true },
                  jedi_signature_help = { enabled = true },
                  jedi_symbols = { enabled = true },
                  fb_pyfmt_format = { enabled = true },
                },
              },
              completionDetailLimit = 50,
            },
            handlers = {
              ["window/showStatus"] = vim.lsp.handlers["window/showMessage"],
            },
          })
        end
      end
    end,
  },
}
