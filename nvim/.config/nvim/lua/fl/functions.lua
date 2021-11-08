local M = {}

M.restart_all_lsp_servers = function()
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client then
      client.stop()
      vim.defer_fn(function()
        require('lspconfig')[client.name].autostart()
      end, 500)
    end
  end
end

M.compile_commands_running = {}
M.generate_compile_commands = function()
  local Job = require'plenary.job'
  local Path = require 'plenary.path'
  local notify = require'notify'
  local filename = vim.fn.expand('%:p')
  local tail = string.match(filename, "[^" .. Path.path.sep .. "]*$")
  Job:new({
    command = 'commands_for_file.py',
    args = { filename },
    cwd = '~/fbsource',
    on_start = function()
      M.compile_commands_running[filename] = true
      notify("Generating compile commands for " .. tail, "info", {
        keep = function()
          return M.compile_commands_running[filename]
        end
      })
    end,
    on_exit = function(j, return_val)
      M.compile_commands_running[filename] = false
      if return_val == 0 then
        require'notify'("Compile commands done for " .. tail, "info", {
          timeout = 1000
        })
      else
       notify("Compile commands error. \n" .. table.concat(j:stderr_result(), "\n"), "error")
      end
    end,
    enable_recording = true,
  }):start()
end

M.myfiles = function(opts)
  if not string.find(vim.fn.expand(vim.loop.cwd()), "fbsource") then
    require('telescope.builtin').find_files({hidden=true})
  else
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

    local myles_search = require 'telescope.finders'.new_job(
      function(prompt)
        if not prompt or prompt == "" or string.len(prompt) < 10 then
          return vim.tbl_flatten { 'find', '.', '-type', 'f', '-maxdepth', '1' }
        end
        return vim.tbl_flatten { 'arc', 'myles', '--list', '-n', '25', prompt }
      end,
      opts.entry_maker or require 'telescope.make_entry'.gen_from_file(opts), 25, opts.cwd
    )
    require 'telescope.pickers'.new(opts, {
      prompt_title = "Myles",
      finder = myles_search,
      previewer = false,
      sorter = false,
    }):find()
  end
end

M.mygrep = function(opts)
  local make_entry = require "telescope.make_entry"
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local escape_chars = function(string)
    return string.gsub(string, "[%(|%)|\\|%[|%]|%-|%{%}|%?|%+|%*|%^|%$]", {
      ["\\"] = "\\\\",
      ["-"] = "\\-",
      ["("] = "\\(",
      [")"] = "\\)",
      ["["] = "\\[",
      ["]"] = "\\]",
      ["{"] = "\\{",
      ["}"] = "\\}",
      ["?"] = "\\?",
      ["+"] = "\\+",
      ["*"] = "\\*",
      ["^"] = "\\^",
      ["$"] = "\\$",
    })
  end

  if string.find(vim.fn.expand(vim.loop.cwd()), "fbsource") then
    local word = escape_chars(vim.fn.expand "<cword>")
    local args = {"xbgs", "-is", word }
    local sorter = conf.generic_sorter(opts)
    opts.entry_maker = make_entry.gen_from_vimgrep(opts)
    if opts.list_files_only then
      opts.entry_maker = make_entry.gen_from_file(opts)
      args = {"xbgs", "-isl", word }
      sorter = conf.file_sorter(opts)
    end
    pickers.new(opts, {
      prompt_title = "Find Word (" .. word .. ")",
      finder = finders.new_oneshot_job(args, opts),
      previewer = false,
      sorter = sorter,
    }):find()
  end
end

return M
