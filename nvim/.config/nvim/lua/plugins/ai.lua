local ff = require("fl.functions")

local provider = "ollama"
if ff.is_fb() then
  provider = "mate"
end
local devserver = os.getenv("DEVSERVER") or "127.0.0.1"

return {
  {
    "yetone/avante.nvim",
    build = "make",
    event = "VeryLazy",
    opts = {
      provider = provider,
      cursor_applying_provider = "mate",
      behaviour = {
        auto_suggestions = false,
        enable_cursor_planning_mode = ff.is_fb(), -- enable cursor planning mode!
      },
      vendors = {
        --@type AvanteProvider
        mate = {
          __inherited_from = "openai",
          model = "llama3.3-70b-instruct",
          endpoint = "https://" .. devserver .. ":8087/v1",
          api_key_name = "",
        },
        --@type AvanteProvider
        ollama = {
          ["local"] = true,
          model = "qwen2.5-coder:7b",
          endpoint = "127.0.0.1:11434/v1",
          parse_curl_args = function(opts, code_opts)
            return {
              url = opts.endpoint .. "/chat/completions",
              headers = {
                ["Accept"] = "application/json",
                ["Content-Type"] = "application/json",
              },
              body = {
                model = opts.model,
                messages = require("avante.providers").copilot.parse_messages(code_opts),
                max_tokens = 2048,
                stream = true,
              },
            }
          end,
        },
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
