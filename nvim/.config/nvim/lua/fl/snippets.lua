local ls  = require("luasnip")

local M = {}

M.snippets = {
	cpp = {
    -- cout
		ls.snippet("co", { -- Trigger is co.
			-- Simple static text.
			ls.text_node('std::cout << "\\U0001F98A " << '),
			-- Insert node.
			ls.insert_node(0),
			ls.text_node(' << std::endl;'),
		}),
    -- lambda
		ls.snippet("la", {
			ls.text_node('[&'),
			ls.insert_node(1),
			ls.text_node(']('),
			ls.insert_node(2),
			ls.text_node('){'),
			ls.insert_node(0),
			ls.text_node('}'),
		}),
  },
}

return M
