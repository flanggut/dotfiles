local M = {}

function M.load()
  local ls  = require("luasnip")
  local fmt = require("luasnip.extras.fmt").fmt
  local s = ls.snippet
  local i = ls.insert_node
  local rep = require("luasnip.extras").rep

  ls.add_snippets("cpp", {
    s("co", fmt('std::cout << "\\U0001F98A " << {} << std::endl;', { i(1) })),
    s("la", fmt('[&]({}){{ {} }}', { i(0), i(1) })),
    s("imfor", fmt('for (int y = 0; y < {}.height(); ++y) {{\n  for (int x = 0; x < {}.width(); ++x) {{\n    {}\n  }}\n}}', { i(1), rep(1), i(0) })),
    s("may", fmt('[[maybe_unused]]', {})),
  })

  ls.add_snippets("python", {
    s("print", fmt('print(f"{{ {} }}")', { i(0) })),
  })
end

return M

