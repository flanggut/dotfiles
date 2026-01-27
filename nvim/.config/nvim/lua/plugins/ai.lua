-- local toggle_key = "<C-.>"
return {
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
      cli = {
        mux = {
          enabled = true,
          backend = "tmux",
        },
        win = {
          keys = {
            back_to_main = {
              "<c-h>",
              function(_)
                vim.cmd.wincmd("h")
              end,
            },
          },
          split = {
            width = 0.55,
          },
        },
      },
    },
    keys = {
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus({ name = "claude", focus = true })
        end,
        desc = "Sidekick Toggle Claude",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        desc = "Sidekick Promp",
        mode = { "n", "i", "x" },
      },
      {
        "<leader>ad",
        function()
          require("sidekick.cli").close()
        end,
        desc = "Detach a CLI Session",
      },
      {
        "<leader>al",
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>as",
        mode = { "n" },
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end,
        desc = "Send File",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
  -- {
  --   "coder/claudecode.nvim",
  --   dependencies = { "folke/snacks.nvim" },
  --   config = true,
  --   keys = {
  --     { "<leader>d",  nil,                              desc = "AI/Claude Code" },
  --     { "<leader>dc", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
  --     { toggle_key,   "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
  --     { "<leader>dr", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
  --     { "<leader>dC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  --     { "<leader>dm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
  --     { "<leader>ds", "<cmd>ClaudeCodeAdd %<cr>",       mode = "n",                  desc = "Add current buffer" },
  --     { "<leader>ds", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
  --     { "<leader>dl", "V:ClaudeCodeSend<cr>",           mode = "n",                  desc = "Send current line" },
  --     {
  --       "<leader>ds",
  --       "<cmd>ClaudeCodeTreeAdd<cr>",
  --       desc = "Add file",
  --       ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
  --     },
  --     -- Diff management
  --     { "<leader>dy", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
  --     { "<leader>dn", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
  --   },
  --   opts = {
  --     terminal = {
  --       ---@module "snacks"
  --       ---@type snacks.win.Config|{}
  --       snacks_win_opts = {
  --         position = "right",
  --         width = 0.8,
  --         height = 1.0,
  --         keys = {
  --           claude_hide = {
  --             toggle_key,
  --             function(self)
  --               self:hide()
  --             end,
  --             mode = "t",
  --             desc = "Hide",
  --           },
  --         },
  --       },
  --     },
  --   },
  -- },
}
