return {
  {
    "yetone/avante.nvim",
    build = "make",
    event = "VeryLazy",
    opts = {
      provider = "ollama",
      -- auto_suggestions_provider = "ollama",
      behaviour = {
        auto_suggestions = false, -- Experimental stage
      },
      vendors = {
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
          parse_response_data = function(data_stream, event_state, opts)
            require("avante.providers").openai.parse_response(data_stream, event_state, opts)
          end,
        },
      },
    }
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
