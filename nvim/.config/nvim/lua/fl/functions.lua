local M = {}

local lazy_util = require("lazy.core.util")

local function is_tmux()
  return os.getenv("TMUX") ~= nil
end

function M.is_fb()
  if vim.fn.isdirectory(os.getenv("HOME") .. "/fbsource") ~= 0 then
    return true
  end
  return false
end

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

local function get_tmux_socket()
  -- The socket path is the first value in the comma-separated list of $TMUX.
  return vim.split(os.getenv("TMUX") or "", ",")[1]
end

local function tmux_execute(arg)
  vim.notify("tmux: " .. arg, vim.log.levels.INFO)
  local t_cmd = string.format("tmux -S %s %s", get_tmux_socket(), arg)
  local handle = assert(io.popen(t_cmd), string.format("Tmux: Unable to execute > [%s]", t_cmd))
  local result = handle:read()
  handle:close()
  return result
end

--- Runs the command and shows it in a floating window
---@param cmd string[]
---@param opts? LazyCmdOptions|{filetype?:string}
function M.float_cmd(cmd, opts)
  opts = opts or {}
  local Process = require("lazy.manage.process")
  local lines, code = Process.exec(cmd, { args = {}, cwd = opts.cwd })
  if code ~= 0 then
    lazy_util.error({
      "`" .. table.concat(cmd, " ") .. "`",
      "",
      "## Error",
      table.concat(lines, "\n"),
    })
  end
  local float = require("lazy.view.float")(opts)
  if opts.filetype then
    vim.bo[float.buf].filetype = opts.filetype
  end
  vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, lines)
  vim.bo[float.buf].modifiable = false
  return float
end

function M.fzfiles()
  local cwd = vim.fn.expand(vim.fn.getcwd()) or "~"
  if string.find(cwd, "fbsource") then
    vim.notify("FzFiles: fbsource")
    local fzf_lua = require("fzf-lua")
    local opts = {}
    opts.file_icons = true
    opts.color_icons = true
    opts.formatter = "path.filename_first"
    opts.actions = fzf_lua.defaults.actions.files
    opts.previewer = false
    opts.fn_transform = function(x)
      return fzf_lua.make_entry.file(x, opts)
    end
    opts.exec_empty_query = true
    opts = require("fzf-lua.config").normalize_opts(opts, "files") or {}

    require("fzf-lua").fzf_live(function(query)
      if not query or query == "" or string.len(query) < 7 then
        return "find . -not -path '*/.*' -type f -maxdepth 1"
      end
      return 'arc myles --list -n 25 "' .. query .. '"'
    end, opts)
    return
  end
  require("fzf-lua").files()
end

function M.restart_all_lsp_servers()
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
function M.generate_compile_commands(all_files)
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
        end, 2000)
      else
        vim.notify("Compile commands error. \n" .. table.concat(j:stderr_result(), "\n"), vim.log.levels.ERROR)
      end
    end,
    enable_recording = true,
  }):start()
end

function M.open_in_browser()
  local filename = vim.fn.expand("%:p")
  local tail = filename:gsub("^.*fbsource", "")
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local url = "https://www.internalfb.com/code/fbsource/[master]" .. tail .. "?lines=" .. tostring(line)
  vim.notify("Opening in browser: " .. tail, vim.log.levels.INFO)
  vim.notify(url, vim.log.levels.INFO)
  assert(io.popen("open " .. url), string.format("Cannot execute open_in_browser."))
end

function M.tmux_prev2()
  if is_tmux() then
    local command = "send -t -1 C-c"
    tmux_execute(command)
    command = "send -t -1 C-p C-p Enter"
    tmux_execute(command)
    return
  end
end

function M.file_runner()
  -- Default tmux handler.
  if is_tmux() then
    local command = "send -t -1 C-c"
    tmux_execute(command)
    command = "send -t -1 C-p Enter"
    tmux_execute(command)
    return
  end

  if vim.bo.filetype == "python" then
    local file = vim.api.nvim_buf_get_name(0)
    local command = { "python3", file }
    local is_running = true
    vim.notify("Running " .. table.concat(command), vim.log.levels.INFO, {
      keep = function()
        return is_running
      end,
    })
    local float = M.float_cmd(command)
    is_running = false
    local lines = vim.api.nvim_buf_get_lines(float.buf, 0, -1, true)
    vim.fn.writefile(lines, "/tmp/nvim_logger.log")
  else
    vim.notify("No runner available.", vim.log.levels.WARN)
  end
end

return M
