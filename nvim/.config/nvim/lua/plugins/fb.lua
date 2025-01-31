if string.find(vim.fn.expand(vim.fn.getcwd() or ""), "fbsource", 0) then
  return {
    {
      dir = "~/fbsource/fbcode/editor_support/nvim/",
      name = "meta.nvim",
      dependencies = { "jose-elias-alvarez/null-ls.nvim" },
      event = "VeryLazy",
      config = function()
        require("meta")
        require("meta.lsp")
        require("meta.metamate").init({
          -- change the languages to target. defaults to php, python, rust
          filetypes = { "cpp", "python" },
          completionKeymap = "<C-f>",
        })
        vim.api.nvim_create_autocmd({ "BufRead" }, {
          pattern = { "*.cpp", "*.h" },
          callback = function()
            require("fl.functions").generate_compile_commands(false)
          end,
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        -- Ensure lspconfig runs after we configure meta.nvim.
        "meta.nvim",
      },
      opts = function(_, opts)
        -- List of custom language server configurations in Neovim@Meta.
        local meta_ls_names = {
          "fb-pyright-ls",
          "pyre",
          "thriftlsp",
        }

        for _, ls_name_no_suffix in ipairs(meta_ls_names) do
          local ls_name = ls_name_no_suffix .. "@meta"
          opts.setup[ls_name] = function()
            -- `true` in `setup` means "don't set this up" to LazyVim
            -- https://github.com/LazyVim/LazyVim/blob/0b020dc37b30fd93a199f1124a95028cb544eac7/lua/lazyvim/plugins/lsp/init.lua#L76-L78
            return false
          end

          opts.servers[ls_name] = {
            -- We manage the language server installation ourselves.
            mason = false,
          }
        end
      end,
    },
  }
else
  return {}
end
