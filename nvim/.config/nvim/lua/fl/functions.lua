local M = {}

local format_line_ending = {
  ["unix"] = "\n",
  ["dos"] = "\r\n",
  ["mac"] = "\r",
}

local function buf_get_line_ending(bufnr)
  return format_line_ending[vim.api.nvim_get_option_value("fileformat", { buf = bufnr })] or "\n"
end

local function buf_get_full_text(bufnr)
  local line_ending = buf_get_line_ending(bufnr)
  local text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, true), line_ending)
  if vim.api.nvim_get_option_value("eol", { buf = bufnr }) then
    text = text .. line_ending
  end
  return text
end

M.is_tmux = function()
  return os.getenv("TMUX") ~= nil
end

local function get_tmux_socket()
  -- The socket path is the first value in the comma-separated list of $TMUX.
  return vim.split(os.getenv("TMUX") or "", ",")[1]
end

function M.tmux_execute(arg)
  local t_cmd = string.format("tmux -S %s %s", get_tmux_socket(), arg)
  local handle = assert(io.popen(t_cmd), string.format("Tmux: Unable to execute > [%s]", t_cmd))
  local result = handle:read()
  handle:close()
  return result
end

M.restart_all_lsp_servers = function()
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client then
      client.stop()
      vim.defer_fn(function()
        require("lspconfig")[client.name].launch()
      end, 500)
    end
  end
end

M.compile_commands_running = {}
---@param all_files boolean
M.generate_compile_commands = function(all_files)
  local Job = require("plenary.job")
  local filename = vim.api.nvim_buf_get_name(0)
  local tail = "all files"
  local args = {}
  if not all_files and filename then
    args = { filename }
    tail = vim.fs.basename(filename)
  end
  filename = filename or "all"
  ---@diagnostic disable-next-line: missing-fields
  Job:new({
    command = "commands_for_file.py",
    args = args,
    cwd = "~/fbsource",
    on_start = function()
      M.compile_commands_running[filename] = true
      vim.notify("Generating compile commands for " .. tail, vim.log.levels.INFO, {
        keep = function()
          return M.compile_commands_running[filename]
        end,
      })
    end,
    on_exit = function(j, return_val)
      M.compile_commands_running[filename] = false
      if return_val == 0 then
        vim.defer_fn(function()
          local uri = vim.uri_from_fname(filename)
          local bufnr = vim.uri_to_bufnr(uri)
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client and client.name == "clangd" then
              client.notify("textDocument/didChange", {
                textDocument = {
                  uri = uri,
                  version = vim.lsp.util.buf_versions[bufnr] + 1,
                },
                contentChanges = {
                  { text = buf_get_full_text(bufnr) },
                },
              })
            end
          end
        end, 5000)
      else
        vim.notify("Compile commands error. \n" .. table.concat(j:stderr_result(), "\n"), vim.log.levels.ERROR)
      end
    end,
    enable_recording = true,
  }):start()
end

M.myfiles = function(opts)
  local cwd = vim.fn.expand(vim.fn.getcwd()) or "~"
  if not string.find(cwd, "fbsource") then
    if string.find(cwd, "dotfiles") then
      require("telescope.builtin").find_files({ hidden = true })
    else
      require("telescope.builtin").find_files()
    end
  else
    opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.fn.getcwd()

    local myles_search = require("telescope.finders").new_job(function(prompt)
      if not prompt or prompt == "" or string.len(prompt) < 7 then
        return vim.iter({ "find", ".", "-not", "-path", "*/.*", "-type", "f", "-maxdepth", "1" }):flatten():totable()
      end
      return vim.iter({ "arc", "myles", "--list", "-n", "25", prompt }):flatten():totable()
    end, opts.entry_maker or require("telescope.make_entry").gen_from_file(opts), 25, opts.cwd)
    require("telescope.pickers")
      .new(opts, {
        prompt_title = "Myles",
        finder = myles_search,
        previewer = false,
        sorter = false,
      })
      :find()
  end
end

M.mygrep = function(opts)
  local make_entry = require("telescope.make_entry")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
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

  if string.find(vim.fn.expand(vim.fn.getcwd()), "fbsource") then
    local word = escape_chars(vim.fn.expand("<cword>"))
    local args = { "xbgs", "-is", word }
    local sorter = conf.generic_sorter(opts)
    opts.entry_maker = make_entry.gen_from_vimgrep(opts)
    if opts.list_files_only then
      opts.entry_maker = make_entry.gen_from_file(opts)
      args = { "xbgs", "-isl", word }
      sorter = conf.file_sorter(opts)
    end
    pickers
      .new(opts, {
        prompt_title = "Find Word (" .. word .. ")",
        finder = finders.new_oneshot_job(args, opts),
        previewer = false,
        sorter = sorter,
      })
      :find()
  end
end

M.open_in_browser = function()
  local filename = vim.fn.expand("%:p")
  local tail = filename:gsub("^.*fbsource", "")
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local url = "https://www.internalfb.com/code/fbsource/[master]" .. tail .. "?lines=" .. tostring(line)
  vim.notify("Opening in browser: " .. tail, vim.log.levels.INFO)
  vim.notify(url, vim.log.levels.INFO)
  require("plenary.job")
    :new({
      command = "open",
      args = { url },
      cwd = "~/fbsource",
    })
    :start()
end

M.tmux_prev2 = function()
  if M.is_tmux() then
    local command = "send -t -1 C-c"
    M.tmux_execute(command)
    command = "send -t -1 C-p C-p Enter"
    vim.notify("tmux " .. command, vim.log.levels.INFO)
    M.tmux_execute(command)
    return
  end
end

M.file_runner = function()
  -- Default tmux handler.
  if M.is_tmux() then
    local command = "send -t -1 C-c"
    M.tmux_execute(command)
    command = "send -t -1 C-p Enter"
    vim.notify("tmux " .. command, vim.log.levels.INFO)
    M.tmux_execute(command)
    return
  end

  if vim.bo.filetype == "python" then
    local file = vim.api.nvim_buf_get_name(0)
    require("lazy.util").float_cmd({ "python3", file })
  else
    vim.notify("No runner available.", vim.log.levels.WARN)
  end
end

local parsers = require("nvim-treesitter.parsers")
M.leap_identifiers = function()
  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  -- Collect all treesitter nodes of identifier type.
  local nodes = {}
  local function collect_identifier_nodes(root_node)
    if root_node:type() == "identifier" then
      table.insert(nodes, root_node)
    end
    for node, _ in root_node:iter_children() do
      collect_identifier_nodes(node)
    end
  end

  -- Collect nodes for current buffer.
  local bufnr = vim.api.nvim_get_current_buf()
  local lang_tree = parsers.get_parser(bufnr)
  for _, tree in ipairs(lang_tree:trees()) do
    local root = tree:root()
    collect_identifier_nodes(root)
  end

  -- Sort nodes wrt. distance to cursor.
  local cursor_line, _ = unpack(vim.api.nvim_win_get_cursor(0))
  local function distance(node_a, node_b)
    local startline, _, _, _ = node_a:range()
    local distance_a = math.abs(startline - cursor_line)
    startline, _, _, _ = node_b:range()
    local distance_b = math.abs(startline - cursor_line)
    return distance_a < distance_b
  end

  table.sort(nodes, distance)

  -- Create Leap targets from TS nodes.
  local targets = {}
  for _, node in ipairs(nodes) do
    local startline, startcol, _, _ = node:range()
    if startline + 1 >= wininfo.topline then
      local target = { node = node, pos = { startline + 1, startcol + 1 } }
      table.insert(targets, target)
    end
  end

  -- Leap.
  if #targets >= 1 then
    require("leap").leap({
      targets = targets,
      backward = true,
    })
    return targets
  else
    vim.notify("No treesitter nodes found.")
  end
end

return M
