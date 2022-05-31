local windline = require('windline')
local helper = require('windline.helpers')
local state = _G.WindLine.state

local basic_components = require('windline.components.basic')
local lsp_comps = require('windline.components.lsp')

local hl_list = {
  Black = { 'white', 'black' },
  White = { 'black', 'white' },
  Inactive = { 'InactiveFg', 'InactiveBg' },
  Active = { 'ActiveFg', 'ActiveBg' },
}

local breakpoint_width = 90

local colors_mode = {
  Normal = { 'NormalBg', 'NormalFg' },
  Insert = { 'NormalBg', 'green' },
  Visual = { 'NormalBg', 'red' },
  Replace = { 'NormalBg', 'blue_light' },
  Command = { 'NormalBg', 'yellow' },
}

local M = {}

M.vi_mode = {
  name = 'vi_mode',
  hl_colors = colors_mode,
  text = function()
    if vim.fn.has('macunix') then
      return {
        { '  ', state.mode[2] },
        { helper.separators.slant_left_2, state.mode[2] },
      }
    else
      return {
        { '  ', state.mode[2] },
        { helper.separators.slant_left_2, state.mode[2] },
      }
    end
  end,
}

M.square_mode = {
  hl_colors = colors_mode,
  text = function()
    return {
      { helper.separators.slant_right_2, state.mode[2] },
      { '  ', state.mode[2] },
    }
  end,
}

M.file_right = {
  hl_colors = {
    default = hl_list.Black,
    white = { 'white', 'NormalBg' },
    magenta = { 'magenta', 'NormalBg' },
  },
  text = function(_, _, width)
    if width < breakpoint_width then
      return {
        { basic_components.line_col_lua, 'white' },
      }
    end
  end,
}

M.lsp_diag = {
  name = 'diagnostic',
  hl_colors = {
    red = { 'red', 'NormalBg' },
    yellow = { 'yellow', 'NormalBg' },
    blue = { 'blue', 'NormalBg' },
  },
  width = breakpoint_width,
  text = function(bufnr)
    if lsp_comps.check_lsp(bufnr) then
      return {
        { ' ', 'red' },
        { lsp_comps.lsp_error({ format = ' %s', show_zero = true }), 'red' },
        { lsp_comps.lsp_warning({ format = '  %s', show_zero = true }), 'yellow' },
        { lsp_comps.lsp_hint({ format = '  %s', show_zero = true }), 'blue' },
      }
    end
    return ''
  end,
}

M.signify = {
  name = 'signify',
  hl_colors = {
    green = { 'green', 'NormalBg' },
    red = { 'red', 'NormalBg' },
    blue = { 'blue', 'NormalBg' },
  },
  width = breakpoint_width,
  text = function(bufnr)
    if vim.g.loaded_signify then
      local repostats = vim.api.nvim_call_function('sy#repo#get_stats', {bufnr})
      if repostats[1] > -1 then
        return {
          { ' ', '' },
          { string.format(' %s', repostats[1]), 'green' },
          { string.format('  %s', repostats[3]), 'red' },
          { string.format(' 柳%s', repostats[2]), 'blue' },
        }
      end
    end
    return ''
  end,
}

local quickfix = {
  filetypes = { 'qf', 'Trouble' },
  active = {
    { '🚦 Quickfix ', { 'white', 'NormalBg' } },
    { helper.separators.slant_right, { 'NormalBg', 'black_light' } },
    {
      function()
        return vim.fn.getqflist({ title = 0 }).title
      end,
      { 'cyan', 'black_light' },
    },
    { ' Total : %L ', { 'cyan', 'black_light' } },
    { helper.separators.slant_right, { 'black_light', 'InactiveBg' } },
    { ' ', { 'InactiveFg', 'InactiveBg' } },
    { basic_components.divider, '' },
    { helper.separators.slant_right, { 'InactiveBg', 'black' } },
    { '🧛 ', { 'white', 'black' } },
  },

  always_active = true,
  show_last_status = true,
}

local explorer = {
  filetypes = { 'fern', 'NvimTree', 'lir' },
  active = {
    { '  ', { 'black', 'red' } },
    { helper.separators.slant_right, { 'red', 'NormalBg' } },
    { basic_components.divider, '' },
    { basic_components.file_name(''), { 'white', 'NormalBg' } },
  },
  always_active = true,
  show_last_status = true,
}

local default = {
  filetypes = { 'default' },
  active = {
    M.vi_mode,
    { ' ', {'white', 'NormalBg'} },
    { lsp_comps.lsp_name(), { 'white', 'NormalBg' }, breakpoint_width },
    { ' ', {'white', 'NormalBg'} },
    M.lsp_diag,
    { ' ', {'white', 'NormalBg'} },
    M.file,
    { basic_components.divider, '' },
    M.file_right,
    { ' ', {'white', 'NormalBg'} },
    { basic_components.file_modified(' '), { 'magenta', 'NormalBg' }},
    { ' ', {'white', 'NormalBg'} },
    { basic_components.cache_file_type({ icon = true }), '' },
    { ' ', '' },
    { basic_components.cache_file_size(), '' },
    { ' ', {'white', 'NormalBg'} },
    M.signify,
    { ' ', {'white', 'NormalBg'} },
    M.square_mode
  },
  inactive = {
    { basic_components.full_file_name, hl_list.Inactive },
    M.file_name_inactive,
    M.divider,
    M.divider,
    { basic_components.line_col, hl_list.Inactive },
    { basic_components.progress, hl_list.Inactive },
  },
}

windline.setup({
  colors_name = function(colors)
    -- print(vim.inspect(colors))
    -- ADD MORE COLOR HERE ----
    return colors
  end,
  statuslines = {
    default,
    quickfix,
    explorer,
  },
})

