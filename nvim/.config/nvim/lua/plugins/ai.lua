local ff = require("fl.functions")

local devserver = os.getenv("DEVSERVER") or "127.0.0.1"
local local_model = os.getenv("LLMODEL") or "llama3.3-70b-instruct"

-- Add shortcut in command line
vim.cmd([[cab cc CodeCompanion]])

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
    opts = {
      file_types = { "markdown", "codecompanion" },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "echasnovski/mini.diff",
        version = "*",
        opts = {
          mappings = {
            apply = "",
            textobject = "",
          },
        },
      },
    },
    event = "VeryLazy",
    keys = {
      { "<C-p>", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v", "i" }, desc = "AI Chat Toggle" },
      { "ga", "<cmd>CodeCompanionChat Add<cr>", mode = { "v" }, desc = "AI Chat Add" },
    },
    init = function()
      require("plugins.codecompanion.fidget-spinner"):init()
    end,
    opts = {
      strategies = {
        chat = {
          adapter = "localllm",
        },
        inline = {
          adapter = "localllm",
        },
      },
      adapters = {
        localllm = function()
          if ff.is_fb() then
            return require("codecompanion.adapters").extend("openai_compatible", {
              name = "llama",
              formatted_name = "llama: " .. local_model,
              env = {
                url = "https://" .. devserver .. ":8087",
              },
              schema = {
                model = {
                  default = local_model,
                },
              },
            })
          end
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = {
                -- default = "llama3.1:latest",
                default = "qwen3:8b",
              },
              num_ctx = {
                default = 20000,
              },
            },
          })
        end,
        -- openai = function()
        --   return require("codecompanion.adapters").extend("openai", {
        --     opts = {
        --       stream = true,
        --     },
        --     env = {
        --       api_key = "cmd:op read op://personal/openai_api/credential --no-newline",
        --     },
        --     schema = {
        --       model = {
        --         default = function()
        --           return "gpt-4.1"
        --         end,
        --       },
        --     },
        --   })
        -- end,
      },
      display = {
        action_palette = {
          provider = "snacks",
        },
        diff = {
          provider = "mini.diff",
        },
      },
    },
  },

  -- {
  --   "yetone/avante.nvim",
  --   version = false,
  --   build = "make",
  --   keys = {
  --     { "<C-p>", "<cmd>AvanteToggle<cr>", mode = { "n", "i" }, desc = "Avante Toggle" },
  --   },
  --   opts = {
  --     provider = "mate",
  --     cursor_applying_provider = "mate",
  --     behaviour = {
  --       auto_suggestions = false,
  --       enable_cursor_planning_mode = true,
  --     },
  --     vendors = {
  --       --@type AvanteProvider
  --       mate = {
  --         __inherited_from = "openai",
  --         model = local_model,
  --         endpoint = "https://" .. devserver .. ":8087/v1",
  --         api_key_name = "",
  --         disable_tools = true,
  --       },
  --     },
  --     ollama = {
  --       model = "qwq:32b",
  --     },
  --     windows = {
  --       width = 50,
  --     },
  --   },
  -- },
  -- {
  --   -- Make sure to set this up properly if you have lazy=true
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   ft = { "markdown", "Avante" },
  --   opts = {
  --     file_types = { "markdown", "Avante" },
  --   },
  -- },
}
