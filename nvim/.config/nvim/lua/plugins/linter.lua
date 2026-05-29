return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cpp = { "clang-format" },
        json = { "prettier" },
      },
      formatters = {
        shfmt = {
          append_args = { "-i", "2" },
        },
      },
    },
  },
}
