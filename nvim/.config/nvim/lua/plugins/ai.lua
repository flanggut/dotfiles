local ff = require("fl.functions")

local provider = "ollama"
if ff.is_fb() then
  provider = "mate"
end
local devserver = os.getenv("DEVSERVER") or "127.0.0.1"
local model = os.getenv("LLMODEL") or "llama3.3-70b-instruct"

return {
  {
    "yetone/avante.nvim",
    version = false,
    build = "make",
    keys = {
      { "<C-p>", "<cmd>AvanteToggle<cr>", mode = { "n", "i" }, desc = "Avante Toggle" },
    },
    opts = {
      provider = provider,
      cursor_applying_provider = provider,
      behaviour = {
        auto_suggestions = false,
        enable_cursor_planning_mode = true,
      },
      vendors = {
        --@type AvanteProvider
        mate = {
          __inherited_from = "openai",
          model = model,
          endpoint = "https://" .. devserver .. ":8087/v1",
          api_key_name = "",
        },
      },
      ollama = {
        model = "qwq:32b",
      },
      windows = {
        width = 50,
      },
    },
  },
  {
    -- Make sure to set this up properly if you have lazy=true
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "Avante" },
    opts = {
      file_types = { "markdown", "Avante" },
    },
  },
}
