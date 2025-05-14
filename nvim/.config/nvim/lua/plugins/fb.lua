local ff = require("fl.functions")

if ff.is_fb() then
  local editor_support_dir = os.getenv("EDITOR_SUPPORT")
  if editor_support_dir == nil or editor_support_dir == "" then
    return {}
  end
  return {
    {
      dir = editor_support_dir,
      name = "meta.nvim",
      dependencies = { "jose-elias-alvarez/null-ls.nvim" },
      event = "VeryLazy",
      config = function()
        require("meta.cmds")
        require("meta.lsp")
        require("meta.metamate").init({
          -- change the languages to target. defaults to php, python, rust
          filetypes = { "cpp", "python" },
          completionKeymap = "<C-f>",
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
          "pyre", -- sudo microdnf install fb-pyre on MacOS
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
