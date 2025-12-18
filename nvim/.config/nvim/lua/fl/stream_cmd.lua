local M = {}

-- Define highlight group for marked lines
vim.api.nvim_set_hl(0, "StreamCmdMark", { bg = "#F2E9E1" })

-- Constants
local MAX_LINES = 300000 -- Maximum number of lines to keep in buffer

-- History storage module
local History = {}
local HISTORY_FILE = vim.fn.stdpath("data") .. "/stream_cmd_filter_history.json"
local MAX_HISTORY = 100

-- Load history from disk
function History.load()
  local file = io.open(HISTORY_FILE, "r")
  if not file then
    return {}
  end

  local content = file:read("*a")
  file:close()

  if content == "" then
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, content)
  if ok and type(decoded) == "table" then
    return decoded
  end

  return {}
end

-- Save history to disk
function History.save(history)
  local ok, encoded = pcall(vim.json.encode, history)
  if not ok then
    vim.notify("Failed to encode history", vim.log.levels.ERROR)
    return
  end

  local file = io.open(HISTORY_FILE, "w")
  if not file then
    vim.notify("Failed to open history file for writing", vim.log.levels.ERROR)
    return
  end

  file:write(encoded)
  file:close()
end

-- Check if filter state already exists in history
function History.is_duplicate(filters, history)
  local filters_str = table.concat(filters, "\n")
  for _, item in ipairs(history) do
    if table.concat(item.filters, "\n") == filters_str then
      return true
    end
  end
  return false
end

-- Add filter state to history with deduplication and limits
function History.add(filters)
  -- Don't save empty states
  if #filters == 0 then
    return
  end

  local history = History.load()

  -- Check for duplicates
  if History.is_duplicate(filters, history) then
    return
  end

  -- Add new state
  table.insert(history, 1, {
    filters = filters,
    timestamp = os.time(),
  })

  -- Limit to MAX_HISTORY
  if #history > MAX_HISTORY then
    for i = MAX_HISTORY + 1, #history do
      table.remove(history, i)
    end
  end

  History.save(history)
end

-- Get all history items
function History.get_all()
  return History.load()
end

-- State object for managing stream command instance
local StreamState = {}
StreamState.__index = StreamState

function StreamState:new(opts)
  local state = {
    opts = opts,
    all_lines = { "" },
    job_running = true,
    bufnr = nil,
    winnr = nil,
    filter_bufnr = nil,
    filter_winnr = nil,
    job_id = nil,
    marked_lines = {}, -- Set of marked line contents
    marks_bufnr = nil,
    marks_winnr = nil,
    marks_ns = vim.api.nvim_create_namespace("stream_cmd_marks"),
    filter_running = false, -- Lock to prevent parallel filter execution
    filter_pending = false, -- Flag to track if a filter run is needed
    output_buffer = "",     -- Buffer to accumulate output data
    flush_timer = nil,      -- Timer for flushing buffered output
  }
  setmetatable(state, StreamState)
  return state
end

-- Buffer creation functions

function StreamState:create_filter_buffer()
  if not self.opts.enable_filter then
    return
  end

  self.filter_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(self.filter_bufnr, "[Filter]")
  vim.bo[self.filter_bufnr].buftype = "acwrite"
  vim.bo[self.filter_bufnr].swapfile = false
  vim.bo[self.filter_bufnr].bufhidden = "hide"
  vim.api.nvim_buf_set_lines(self.filter_bufnr, 0, -1, false, { "" })
end

function StreamState:create_output_buffer()
  self.bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(self.bufnr, self.opts.bufname)
  vim.bo[self.bufnr].buftype = "nofile"
  vim.bo[self.bufnr].swapfile = false
  vim.bo[self.bufnr].bufhidden = "hide"

  if self.opts.filetype ~= "" then
    vim.bo[self.bufnr].filetype = self.opts.filetype
  end
end

-- Window management functions

function StreamState:open_output_window()
  local split_type = self.opts.split
  local size = self.opts.size

  if split_type == "horizontal" then
    vim.cmd("botright " .. size .. "split")
    vim.api.nvim_win_set_buf(0, self.bufnr)
  elseif split_type == "vertical" then
    vim.cmd("botright " .. size .. "vsplit")
    vim.api.nvim_win_set_buf(0, self.bufnr)
  elseif split_type == "tab" then
    vim.cmd("tabnew")
    vim.api.nvim_win_set_buf(0, self.bufnr)
  else -- fullscreen (default)
    vim.api.nvim_win_set_buf(0, self.bufnr)
  end

  self.winnr = vim.api.nvim_get_current_win()
end

function StreamState:open_filter_window()
  if not self.opts.enable_filter or not self.filter_bufnr then
    return
  end

  vim.cmd("topleft 30vsplit")
  vim.api.nvim_win_set_buf(0, self.filter_bufnr)
  self.filter_winnr = vim.api.nvim_get_current_win()

  -- Disable line numbers and set minimal gutter (2 columns)
  vim.wo[self.filter_winnr].number = false
  vim.wo[self.filter_winnr].relativenumber = false
  vim.wo[self.filter_winnr].signcolumn = "yes:2"
  vim.wo[self.filter_winnr].foldcolumn = "0"

  vim.cmd("startinsert")
end

-- Marks window management functions

function StreamState:create_marks_window()
  -- Create marks buffer
  self.marks_bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(self.marks_bufnr, "[Marked Lines]")
  vim.bo[self.marks_bufnr].buftype = "nofile"
  vim.bo[self.marks_bufnr].swapfile = false
  vim.bo[self.marks_bufnr].bufhidden = "hide"

  if self.opts.filetype ~= "" then
    vim.bo[self.marks_bufnr].filetype = self.opts.filetype
  end

  -- Focus the output window first
  if vim.api.nvim_win_is_valid(self.winnr) then
    vim.api.nvim_set_current_win(self.winnr)
  end

  -- Create horizontal split below only the output window (not botright)
  vim.cmd("belowright 8split")
  vim.api.nvim_win_set_buf(0, self.marks_bufnr)
  self.marks_winnr = vim.api.nvim_get_current_win()

  -- Setup auto-resize for marks window
  self:setup_marks_autoresize()

  -- Return focus to filter window if enabled, otherwise output window
  if self.opts.enable_filter and self.filter_winnr and vim.api.nvim_win_is_valid(self.filter_winnr) then
    vim.api.nvim_set_current_win(self.filter_winnr)
    vim.cmd("startinsert")
  elseif vim.api.nvim_win_is_valid(self.winnr) then
    vim.api.nvim_set_current_win(self.winnr)
  end
end

function StreamState:setup_marks_autoresize()
  if not self.marks_winnr or not vim.api.nvim_win_is_valid(self.marks_winnr) then
    return
  end

  local original_height = 8
  local expanded_height = 42

  -- Autocmd to expand when entering marks window
  vim.api.nvim_create_autocmd("WinEnter", {
    buffer = self.marks_bufnr,
    callback = function()
      if vim.api.nvim_win_is_valid(self.marks_winnr) then
        vim.api.nvim_win_set_height(self.marks_winnr, expanded_height)
      end
    end,
  })

  -- Autocmd to shrink when leaving marks window
  vim.api.nvim_create_autocmd("WinLeave", {
    buffer = self.marks_bufnr,
    callback = function()
      if vim.api.nvim_win_is_valid(self.marks_winnr) then
        vim.api.nvim_win_set_height(self.marks_winnr, original_height)
      end
    end,
  })
end

function StreamState:update_marks_window()
  if not self.marks_bufnr or not vim.api.nvim_buf_is_valid(self.marks_bufnr) then
    return
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(self.bufnr) or not vim.api.nvim_buf_is_valid(self.marks_bufnr) then
      return
    end

    -- Get all displayed lines from output buffer
    local displayed_lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
    local marked_display = {}

    -- Collect marked lines in display order
    for _, line in ipairs(displayed_lines) do
      if self.marked_lines[line] then
        table.insert(marked_display, line)
      end
    end

    -- Update marks buffer
    vim.bo[self.marks_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(self.marks_bufnr, 0, -1, false, marked_display)
    vim.bo[self.marks_bufnr].modifiable = false
  end)
end

function StreamState:update_marks_highlights()
  if not vim.api.nvim_buf_is_valid(self.bufnr) then
    return
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(self.bufnr) then
      return
    end

    -- Clear existing highlights
    vim.api.nvim_buf_clear_namespace(self.bufnr, self.marks_ns, 0, -1)

    -- Get all displayed lines
    local displayed_lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)

    -- Apply highlights to marked lines
    for line_num, line_content in ipairs(displayed_lines) do
      if self.marked_lines[line_content] then
        vim.api.nvim_buf_set_extmark(self.bufnr, self.marks_ns, line_num - 1, 0, {
          end_line = line_num - 1,
          end_col = 0,
          hl_group = "StreamCmdMark",
          line_hl_group = "StreamCmdMark",
        })
      end
    end
  end)
end

function StreamState:toggle_mark()
  local line_num = vim.api.nvim_win_get_cursor(self.winnr)[1]
  local line_content = vim.api.nvim_buf_get_lines(self.bufnr, line_num - 1, line_num, false)[1]

  if not line_content then
    return
  end

  -- Toggle mark
  if self.marked_lines[line_content] then
    self.marked_lines[line_content] = nil
  else
    self.marked_lines[line_content] = true
  end

  -- Update highlights and marks window
  self:update_marks_highlights()
  self:update_marks_window()
end

-- Filter application functions

function StreamState:get_filters()
  if not self.filter_bufnr or not vim.api.nvim_buf_is_valid(self.filter_bufnr) then
    return {}
  end

  local filter_lines = vim.api.nvim_buf_get_lines(self.filter_bufnr, 0, -1, false)
  local filters = {}

  for _, line in ipairs(filter_lines) do
    if line ~= "" then
      table.insert(filters, line)
    end
  end

  return filters
end

-- Helper function to check if a string contains uppercase letters
local function has_uppercase(str)
  return str:match("%u") ~= nil
end

function StreamState:apply_filters()
  if not self.opts.enable_filter or not vim.api.nvim_buf_is_valid(self.filter_bufnr) then
    return
  end

  -- If filter is already running, mark that we need to run again after it completes
  if self.filter_running then
    self.filter_pending = true
    return
  end

  -- Set lock
  self.filter_running = true
  self.filter_pending = false

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(self.bufnr) then
      self.filter_running = false
      return
    end

    local filters = self:get_filters()
    local filtered_lines = {}

    -- Separate filters into include and exclude
    local include_filters = {}
    local exclude_filters = {}

    for _, filter in ipairs(filters) do
      if filter:sub(1, 1) == "!" then
        -- Exclude filter (starts with !)
        table.insert(exclude_filters, filter:sub(2))
      else
        -- Include filter
        table.insert(include_filters, filter)
      end
    end

    if #filters == 0 then
      -- No filters, show all lines
      filtered_lines = self.all_lines
    else
      -- Apply filters with smart case
      for _, line in ipairs(self.all_lines) do
        local should_include = false
        local should_exclude = false

        -- Check include filters (if any)
        if #include_filters == 0 then
          -- No include filters means include all by default
          should_include = true
        else
          for _, filter in ipairs(include_filters) do
            local matched = false

            if has_uppercase(filter) then
              -- Case-sensitive search if filter has uppercase
              matched = line:find(filter, 1, true) ~= nil
            else
              -- Case-insensitive search if filter is all lowercase
              matched = line:lower():find(filter:lower(), 1, true) ~= nil
            end

            if matched then
              should_include = true
              break
            end
          end
        end

        -- Check exclude filters (if any)
        for _, filter in ipairs(exclude_filters) do
          local matched = false

          if has_uppercase(filter) then
            -- Case-sensitive search if filter has uppercase
            matched = line:find(filter, 1, true) ~= nil
          else
            -- Case-insensitive search if filter is all lowercase
            matched = line:lower():find(filter:lower(), 1, true) ~= nil
          end

          if matched then
            should_exclude = true
            break
          end
        end

        -- Include line only if it matches include filters and doesn't match exclude filters
        if should_include and not should_exclude then
          table.insert(filtered_lines, line)
        end
      end
    end

    vim.bo[self.bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, filtered_lines)
    vim.bo[self.bufnr].modifiable = false

    -- Scroll so the last filtered line appears at the bottom of the window
    if vim.api.nvim_win_is_valid(self.winnr) then
      local line_count = #filtered_lines
      if line_count > 0 then
        local win_height = vim.api.nvim_win_get_height(self.winnr)
        local target_line = math.max(1, line_count - (win_height / 2) + 1)
        vim.api.nvim_win_set_cursor(self.winnr, { target_line, 0 })
      end
    end

    self:update_marks_highlights()
    self:update_marks_window()

    -- Release lock
    self.filter_running = false

    -- If another filter was requested while we were running, run it now
    if self.filter_pending then
      self:apply_filters()
    end
  end)
end

-- Output handling functions

function StreamState:auto_scroll()
  if vim.api.nvim_win_is_valid(self.winnr) then
    local line_count = vim.api.nvim_buf_line_count(self.bufnr)
    vim.api.nvim_win_set_cursor(self.winnr, { line_count, 0 })
  end
end

function StreamState:append_to_all_lines(lines)
  local last_line_idx = #self.all_lines

  if #lines > 0 then
    self.all_lines[last_line_idx] = self.all_lines[last_line_idx] .. lines[1]

    if #lines > 1 then
      for i = 2, #lines do
        table.insert(self.all_lines, lines[i])
      end
    end
  end

  -- Cap the number of lines at MAX_LINES
  if #self.all_lines > MAX_LINES then
    local excess = #self.all_lines - MAX_LINES
    -- Remove old lines from the beginning (more efficient for large excess)
    local new_lines = {}
    for i = excess + 1, #self.all_lines do
      table.insert(new_lines, self.all_lines[i])
    end
    self.all_lines = new_lines
  end
end

function StreamState:append_to_output_buffer(lines)
  vim.bo[self.bufnr].modifiable = true
  local current_lines = vim.api.nvim_buf_get_lines(self.bufnr, 0, -1, false)
  local current_last_idx = #current_lines - 1

  if #lines > 0 then
    current_lines[#current_lines] = current_lines[#current_lines] .. lines[1]
    vim.api.nvim_buf_set_lines(self.bufnr, current_last_idx, -1, false, { current_lines[#current_lines] })

    if #lines > 1 then
      vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, vim.list_slice(lines, 2))
    end
  end

  vim.bo[self.bufnr].modifiable = false
  self:auto_scroll()
  self:update_marks_highlights()
  self:update_marks_window()
end

function StreamState:flush_output_buffer()
  if self.output_buffer == "" then
    return
  end

  local data = self.output_buffer
  self.output_buffer = ""

  if not vim.api.nvim_buf_is_valid(self.bufnr) then
    return
  end

  local lines = vim.split(data, "\n", { plain = true })
  self:append_to_all_lines(lines)

  if self.opts.enable_filter then
    self:apply_filters()
  else
    self:append_to_output_buffer(lines)
  end
end

function StreamState:handle_output(data)
  if not data then
    return
  end

  -- Accumulate data in buffer
  self.output_buffer = self.output_buffer .. data

  -- Schedule flushing
  if not self.flush_timer then
    -- Create new timer to flush after 1 second
    self.flush_timer = vim.defer_fn(function()
      vim.schedule(function()
        self:flush_output_buffer()
        self.flush_timer = nil
      end)
    end, 1000) -- 1000ms = 1 second
  end
end

-- Keybinding setup functions

function StreamState:show_history_picker()
  if not self.opts.enable_filter or not vim.api.nvim_buf_is_valid(self.filter_bufnr) then
    return
  end

  local history = History.get_all()
  if #history == 0 then
    vim.notify("No filter history available", vim.log.levels.INFO)
    return
  end

  -- Prepare items for picker
  local items = {}
  for _, item in ipairs(history) do
    local display = table.concat(item.filters, ", ")
    table.insert(items, {
      text = display,
      filters = item.filters,
    })
  end

  -- Use Snacks picker to select from history
  Snacks.picker.pick({
    items = items,
    format = "text",
    title = "Filter History",
    ---@diagnostic disable-next-line: assign-type-mismatch
    layout = { preview = false },
    ---@param item {text: string, filters: string[]}
    confirm = function(picker, item)
      picker:close()
      if item and item.filters then
        -- Populate filter buffer with selected filters
        vim.api.nvim_buf_set_lines(self.filter_bufnr, 0, -1, false, item.filters)
        -- Apply filters immediately
        self:apply_filters()
        -- Focus filter window and enter insert mode
        if vim.api.nvim_win_is_valid(self.filter_winnr) then
          vim.api.nvim_set_current_win(self.filter_winnr)
          vim.cmd("startinsert")
        end
      end
    end,
  })
end

function StreamState:setup_window_navigation()
  if not self.opts.enable_filter or not self.filter_bufnr then
    return
  end

  -- From filter window to output window
  vim.keymap.set({ "n", "i" }, "<C-j>", function()
    -- Exit insert mode if in it
    if vim.api.nvim_get_mode().mode == "i" then
      vim.cmd("stopinsert")
    end
    if vim.api.nvim_win_is_valid(self.winnr) then
      vim.api.nvim_set_current_win(self.winnr)
    end
  end, { buffer = self.filter_bufnr, nowait = true })

  -- From output window to filter window
  vim.keymap.set("n", "<C-j>", function()
    if vim.api.nvim_win_is_valid(self.filter_winnr) then
      vim.api.nvim_set_current_win(self.filter_winnr)
      vim.cmd("startinsert")
    end
  end, { buffer = self.bufnr, nowait = true })
end

function StreamState:setup_cleanup_keybinding()
  local cleanup = function()
    self:cleanup()
  end

  local kill_job = function()
    self:kill_job()
  end

  vim.keymap.set("n", "q", cleanup, { buffer = self.bufnr, nowait = true })
  vim.keymap.set({ "n", "i" }, "<C-c>", kill_job, { buffer = self.bufnr, nowait = true, desc = "Kill job" })

  if self.opts.enable_filter and self.filter_bufnr then
    vim.keymap.set({ "n", "i" }, "<C-d>", cleanup, { buffer = self.filter_bufnr, nowait = true })
    vim.keymap.set("n", "q", cleanup, { buffer = self.filter_bufnr, nowait = true })
    vim.keymap.set({ "n", "i" }, "<C-c>", kill_job, { buffer = self.filter_bufnr, nowait = true, desc = "Kill job" })
  end

  if self.marks_bufnr then
    vim.keymap.set("n", "q", cleanup, { buffer = self.marks_bufnr, nowait = true })
    vim.keymap.set({ "n", "i" }, "<C-c>", kill_job, { buffer = self.marks_bufnr, nowait = true, desc = "Kill job" })
  end
end

function StreamState:setup_marks_keybinding()
  -- Add 'm' key to toggle marks in output buffer
  vim.keymap.set("n", "m", function()
    self:toggle_mark()
  end, { buffer = self.bufnr, nowait = true, desc = "Toggle line mark" })
end

function StreamState:kill_job()
  if self.job_id and self.job_running then
    vim.fn.jobstop(self.job_id)
    self.job_running = false
    vim.notify("Job killed", vim.log.levels.WARN)

    -- Append kill message to output buffer
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.bo[self.bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, { "", "--- Job killed by user ---" })
        vim.bo[self.bufnr].modifiable = false
      end
    end)
  else
    vim.notify("No running job to kill", vim.log.levels.INFO)
  end
end

function StreamState:cleanup()
  -- Save filter state to history before cleanup
  if self.opts.enable_filter and self.filter_bufnr and vim.api.nvim_buf_is_valid(self.filter_bufnr) then
    local filter_lines = vim.api.nvim_buf_get_lines(self.filter_bufnr, 0, -1, false)
    local filters = {}
    for _, line in ipairs(filter_lines) do
      if line ~= "" then
        table.insert(filters, line)
      end
    end
    History.add(filters)
  end

  -- Stop the running job
  if self.job_id then
    vim.fn.jobstop(self.job_id)
  end

  -- Check if there are any other buffers besides stream_cmd buffers
  local other_buffers_exist = false
  local all_buffers = vim.api.nvim_list_bufs()
  for _, buf in ipairs(all_buffers) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      -- Check if this buffer is not one of our stream_cmd buffers
      if buf ~= self.bufnr and buf ~= self.filter_bufnr and buf ~= self.marks_bufnr then
        other_buffers_exist = true
        break
      end
    end
  end

  -- Close all windows explicitly before deleting buffers
  if self.marks_winnr and vim.api.nvim_win_is_valid(self.marks_winnr) then
    vim.api.nvim_win_close(self.marks_winnr, true)
  end

  if self.filter_winnr and vim.api.nvim_win_is_valid(self.filter_winnr) then
    vim.api.nvim_win_close(self.filter_winnr, true)
  end

  if self.winnr and vim.api.nvim_win_is_valid(self.winnr) then
    vim.api.nvim_set_current_win(self.winnr)

    if other_buffers_exist then
      -- Try to switch to previous buffer, or create a new empty one
      vim.cmd("silent! buffer #")
      if vim.api.nvim_win_get_buf(self.winnr) == self.bufnr then
        -- If we're still in the stream buffer, quit
        vim.cmd("qa!")
      end
    else
      -- No other buffers exist, quit vim without prompting to save
      vim.cmd("qa!")
    end
  end

  -- Delete buffers after windows are closed (only if we didn't quit)
  if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
    -- Clear marks namespace before deleting buffer
    vim.api.nvim_buf_clear_namespace(self.bufnr, self.marks_ns, 0, -1)
    vim.api.nvim_buf_delete(self.bufnr, { force = true })
  end

  if self.opts.enable_filter and self.filter_bufnr and vim.api.nvim_buf_is_valid(self.filter_bufnr) then
    vim.api.nvim_buf_delete(self.filter_bufnr, { force = true })
  end

  if self.marks_bufnr and vim.api.nvim_buf_is_valid(self.marks_bufnr) then
    vim.api.nvim_buf_delete(self.marks_bufnr, { force = true })
  end

  if vim.api.nvim_get_mode().mode == "i" then
    vim.cmd("stopinsert")
  end
end

-- Filter autocmd setup

function StreamState:setup_filter_autocmds()
  if not self.opts.enable_filter or not self.filter_bufnr then
    return
  end

  -- Auto-apply filters on text change
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = self.filter_bufnr,
    callback = function()
      self:apply_filters()
    end,
  })

  -- Prevent actual writing
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = self.filter_bufnr,
    callback = function()
      vim.bo[self.filter_bufnr].modified = false
    end,
  })

  -- Add keybinding to open history picker
  vim.keymap.set({ "n", "i" }, "<C-k>", function()
    -- Exit insert mode if in it
    if vim.api.nvim_get_mode().mode == "i" then
      vim.cmd("stopinsert")
    end
    self:show_history_picker()
  end, { buffer = self.filter_bufnr, nowait = true, desc = "Open filter history" })
end

-- Job management functions

function StreamState:start_job(cmd)
  local cmd_string = type(cmd) == "table" and table.concat(cmd, " ") or cmd

  vim.notify("Running: " .. cmd_string, vim.log.levels.INFO, {
    keep = function()
      return self.job_running
    end,
  })

  self.job_id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            self:handle_output(line .. "\n")
          end
        end
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        for _, line in ipairs(data) do
          if line ~= "" then
            self:handle_output(line .. "\n")
          end
        end
      end
    end,
    on_exit = function(_, exit_code, _)
      self.job_running = false

      -- Flush any remaining buffered output
      if self.flush_timer then
        self.flush_timer:stop()
        self.flush_timer = nil
      end
      self:flush_output_buffer()

      vim.schedule(function()
        local status_msg = exit_code == 0 and "completed successfully" or "failed with code " .. exit_code
        vim.notify("Command " .. status_msg, exit_code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)

        if vim.api.nvim_buf_is_valid(self.bufnr) then
          vim.bo[self.bufnr].modifiable = true
          vim.api.nvim_buf_set_lines(self.bufnr, -1, -1, false, { "", "--- Exit code: " .. exit_code .. " ---" })
          vim.bo[self.bufnr].modifiable = false
        end
      end)
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })

  if self.job_id <= 0 then
    vim.notify("Failed to start job", vim.log.levels.ERROR)
  end
end

-- Main public API

---@param cmd string|string[] Command to run (string for shell command, table for direct execution)
---@param opts? {split?: "horizontal"|"vertical"|"tab"|"fullscreen", size?: number, filetype?: string, bufname?: string, enable_filter?: boolean}
---@return number bufnr, number job_id
function M.run(cmd, opts)
  -- Parse options with defaults
  opts = opts or {}
  opts.split = opts.split or "fullscreen"
  opts.size = opts.size or 15
  opts.filetype = opts.filetype or ""
  opts.bufname = opts.bufname or "[Stream Command]"
  opts.enable_filter = opts.enable_filter ~= false

  -- Capture original buffer before we create any windows
  local original_bufnr = vim.api.nvim_get_current_buf()

  -- Create state object
  local state = StreamState:new(opts)

  -- Setup buffers
  state:create_filter_buffer()
  state:create_output_buffer()

  -- Setup windows
  state:open_output_window()
  state:open_filter_window()
  state:create_marks_window()

  -- Setup keybindings
  state:setup_window_navigation()
  state:setup_cleanup_keybinding()
  state:setup_marks_keybinding()

  -- Setup filter autocmds
  state:setup_filter_autocmds()

  -- If command is empty, populate with current buffer content instead of running a job
  if not cmd or cmd == "" or (type(cmd) == "table" and #cmd == 0) then
    local lines = vim.api.nvim_buf_get_lines(original_bufnr, 0, -1, false)
    state.all_lines = lines
    state.job_running = false

    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(state.bufnr) then
        return
      end

      if opts.enable_filter then
        -- Apply filters to show content (will also update marks)
        state:apply_filters()
      else
        -- No filters, set content directly and update marks
        vim.bo[state.bufnr].modifiable = true
        vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
        vim.bo[state.bufnr].modifiable = false
        state:update_marks_highlights()
        state:update_marks_window()
      end

      vim.notify("Buffer content loaded into stream window", vim.log.levels.INFO)
    end)

    return state.bufnr, 0
  end

  -- Start the job
  state:start_job(cmd)

  return state.bufnr, state.job_id
end

return M
