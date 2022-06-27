local M = {}

M.is_tmux = function ()
  return os.getenv('TMUX') ~= nil
end

local function get_tmux_socket()
    -- The socket path is the first value in the comma-separated list of $TMUX.
    return vim.split(os.getenv('TMUX'), ',')[1]
end

function M.tmux_execute(arg)
    local t_cmd = string.format('tmux -S %s %s', get_tmux_socket(), arg)
    local handle = assert(io.popen(t_cmd), string.format('Tmux: Unable to execute > [%s]', t_cmd))
    local result = handle:read()
    handle:close()
    return result
end


M.restart_all_lsp_servers = function()
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client then
      client.stop()
      vim.defer_fn(function()
        require('lspconfig')[client.name].launch()
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
        vim.schedule(function ()
          vim.cmd "LspRestart"
        end)
      else
        notify("Compile commands error. \n" .. table.concat(j:stderr_result(), "\n"), "error")
      end
    end,
    enable_recording = true,
  }):start()
end

M.myfiles = function(opts)
  if not string.find(vim.fn.expand(vim.loop.cwd()), "fbsource") then
    if string.find(vim.fn.expand(vim.loop.cwd()), "dotfiles") then
      require('telescope.builtin').find_files({ hidden = true })
    else
      require('telescope.builtin').find_files()
    end
  else
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()

    local myles_search = require 'telescope.finders'.new_job(
    function(prompt)
      if not prompt or prompt == "" or string.len(prompt) < 7 then
        return vim.tbl_flatten { 'find', '.', '-not', '-path', '*/.*', '-type', 'f', '-maxdepth', '1' }
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

M.open_in_browser = function ()
  local filename = vim.fn.expand('%:p')
  local tail = filename:gsub('^.*fbsource', '')
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local url = 'https://www.internalfb.com/code/fbsource/[master]' .. tail .. '?lines=' .. tostring(line)
  require'notify'("Opening in browser: " .. tail, "info")
  require'notify'(url, "info")
  require'plenary.job':new({
    command = 'open',
    args = { url },
    cwd = '~/fbsource',
  }):start()
end

M.file_runner = function ()
  -- Default tmux handler.
  if M.is_tmux() then
    local command = "send -t -1 C-c"
    M.tmux_execute(command)
    command = "send -t -1 C-p Enter"
    require'notify'("tmux " .. command, "info")
    M.tmux_execute(command)
    return
  end

  local ftermconfig = {
    dimensions  = {
      height = 0.8,
      width = 0.8,
      x = 0.9,
      y = 0.7
    },
    cmd = {'python3', vim.api.nvim_buf_get_name(0)}
  }
  require('FTerm').scratch(ftermconfig)
end

return M
