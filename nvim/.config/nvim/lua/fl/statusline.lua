local strings = require('plenary.strings')
local windline = require('windline')
local helper = require('windline.helpers')
local state = _G.WindLine.state

local b_components = require('windline.components.basic')
local lsp_comps = require('windline.components.lsp')
local git_comps = require('windline.components.git')
-- local vim_components = require('windline.components.vim')

local hl_list = {
    Black = { 'white', 'black' },
    White = { 'black', 'white' },
    Inactive = { 'InactiveFg', 'InactiveBg' },
    Active = { 'ActiveFg', 'ActiveBg' },
}
local basic = {}

local breakpoint_width = 90
basic.divider = { b_components.divider, '' }
basic.bg = { ' ', 'StatusLine' }

local colors_mode = {
    Normal = { 'NormalBg', 'NormalFg' },
    Insert = { 'NormalBg', 'green' },
    Visual = { 'NormalBg', 'red' },
    Replace = { 'NormalBg', 'blue_light' },
    Command = { 'NormalBg', 'yellow' },
}

basic.vi_mode = {
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
basic.square_mode = {
    hl_colors = colors_mode,
    text = function()
      return {
        { helper.separators.slant_right_2, state.mode[2] },
        { '  ', state.mode[2] },
      }
    end,
}

basic.lsp_diagnos = {
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
basic.file = {
    name = 'file',
    hl_colors = {
        default = hl_list.Black,
        white = { 'white', 'NormalBg' },
        magenta = { 'magenta', 'NormalBg' },
    },
    text = function(_, _, width)
        if width > breakpoint_width then
            return {
                { b_components.file_modified(' '), 'magenta' },
                { ' ', '' },
                { b_components.cache_file_name('[No Name]', 'unique'), '' },
                { b_components.line_col_lua, 'white' },
                { b_components.progress_lua, '' },
                { ' ', '' },
            }
        else
            return {
                { b_components.file_modified(' '), 'magenta' },
                { ' ', '' },
                { b_components.cache_file_name('[No Name]', 'unique'), '' },
                { ' ', '' },
            }
        end
    end,
}

basic.file_right = {
    hl_colors = {
        default = hl_list.Black,
        white = { 'white', 'NormalBg' },
        magenta = { 'magenta', 'NormalBg' },
    },
    text = function(_, _, width)
        if width < breakpoint_width then
            return {
                { b_components.line_col_lua, 'white' },
                { b_components.progress_lua, '' },
            }
        end
    end,
}

basic.git = {
    name = 'git',
    hl_colors = {
        green = { 'green', 'NormalBg' },
        red = { 'red', 'NormalBg' },
        blue = { 'blue', 'NormalBg' },
    },
    width = breakpoint_width,
    text = function(bufnr)
        if git_comps.is_git(bufnr) then
            return {
                { ' ', '' },
                { git_comps.diff_added({ format = ' %s', show_zero = true }), 'green' },
                { git_comps.diff_removed({ format = '  %s', show_zero = true }), 'red' },
                { git_comps.diff_changed({ format = ' 柳%s', show_zero = true }), 'blue' },
            }
        end
        return ''
    end,
}

basic.lsp_status = {
    name = 'lsp_status',
    hl_colors = {
        white = { 'white', 'NormalBg' },
    },
    width = breakpoint_width,
    text = function(_)
      local messages = vim.lsp.util.get_progress_messages()
      if #messages == 0 then
        return ''
      end
      local status = {}
      for _, msg in pairs(messages) do
        table.insert(status, (msg.percentage or 0) .. "%% " .. strings.truncate(msg.title or "", 25))
      end
      local spinners = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
      local ms = vim.loop.hrtime() / 1000000
      local frame = math.floor(ms / 120) % #spinners
      return {
        { ' ', 'white' },
        { spinners[frame + 1] .. " " .. table.concat(status, " | "), 'white'},
      }
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
        basic.divider,
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
        { b_components.divider, '' },
        { b_components.file_name(''), { 'white', 'NormalBg' } },
    },
    always_active = true,
    show_last_status = true,
}
local default = {
    filetypes = { 'default' },
    active = {
        basic.vi_mode,
        { ' ', {'white', 'NormalBg'} },
        basic.file,
        basic.lsp_diagnos,
        basic.divider,
        basic.file_right,
        { ' ', {'white', 'NormalBg'} },
        { lsp_comps.lsp_name(), { 'magenta', 'NormalBg' }, breakpoint_width },
        basic.lsp_status,
        basic.git,
        { git_comps.git_branch(), { 'magenta', 'NormalBg' }, breakpoint_width },
        { ' ', {'white', 'NormalBg'} },
        { b_components.cache_file_type({ icon = true }), '' },
        { ' ', '' },
        { b_components.cache_file_size(), '' },
        { ' ', '' },
        basic.square_mode
    },
    inactive = {
        { b_components.full_file_name, hl_list.Inactive },
        basic.file_name_inactive,
        basic.divider,
        basic.divider,
        { b_components.line_col, hl_list.Inactive },
        { b_components.progress, hl_list.Inactive },
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

