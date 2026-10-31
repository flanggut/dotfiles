-- Hints: label every link or file path on the focused pane's screen and act
-- on the one whose label you type. The labels are drawn in a floating pane
-- over the original, which closes again once one is picked or Escape is
-- pressed.
--
-- Swap this for Rex's own hints once it has them.

local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"
local HERE = debug.getinfo(1, "S").source:match("^@(.*/)")
  or (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex/"
local HELPER = HERE .. "hints.py"

-- The rect of a block in a layout tree, as [x, y, w, h] window fractions.
local function find_rect(node, block_id)
  if type(node) ~= "table" then return nil end
  if node.block_id == block_id and node.rect then return node.rect end
  for _, child in pairs(node) do
    local rect = find_rect(child, block_id)
    if rect then return rect end
  end
end

-- Where a block sits in its window, for placing the overlay on top of it.
local function block_bounds(block_id)
  local view = rex.session.view{}
  for _, window in ipairs(view and view.windows or {}) do
    for _, layer in ipairs(window.layers or {}) do
      local rect = find_rect(layer.layout, block_id)
      if rect then
        if layer.kind ~= "tiled" then return layer.bounds end
        return rect
      end
    end
  end
  return { 0, 0, 1, 1 }
end

-- The terminal's directory: what its shell reported (OSC 7), or else the
-- foreground process's actual working directory.
local function block_dir(block_id)
  local r = rex.block.call(TERMINAL, "pwd", { block_id = block_id })
  if r ~= nil and r.pwd ~= nil then
    local path = r.pwd:gsub("^file://[^/]*", "")
    return (path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
  end
  local p = rex.block.call(TERMINAL, "process", { block_id = block_id })
  return p and p.foreground and p.foreground.cwd or os.getenv("HOME")
end

local function show_hints(ctx, mode)
  if ctx.block_id == nil then error("no focused pane", 0) end
  local size, err = rex.block.call(TERMINAL, "size", { block_id = ctx.block_id })
  if size == nil then error(err, 0) end
  local screen, err = rex.block.call(TERMINAL, "format", { block_id = ctx.block_id, format = "text" })
  if screen == nil then error(err, 0) end

  local path = os.tmpname()
  local file = assert(io.open(path, "w"))
  file:write(screen.content)
  file:close()

  local _, err = rex.session.new_layer{
    bounds = block_bounds(ctx.block_id),
    focus  = true,
    layout = rex.layout.block{
      flavor = SHELL,
      label  = mode .. " hints",
      options = {
        shell   = "none",
        command = { "/usr/bin/python3", "-I", HELPER, mode, path,
                    tostring(size.rows), tostring(size.columns),
                    block_dir(ctx.block_id), ctx.session_id, ctx.block_id },
      },
    },
  }
  if err ~= nil then
    os.remove(path)
    error(err, 0)
  end
end

rex.action{
  name        = "link_hints",
  title       = "Open Link from Screen",
  description = "Label each URL on the focused pane and open the one whose label you type",
  keywords    = "hints url hyperlink open browser vimium",
  run         = function(ctx, args) show_hints(ctx, "links") end,
}

rex.action{
  name        = "path_hints",
  title       = "Insert File Path from Screen",
  description = "Label each file path on the focused pane and type the one whose label you type at the prompt",
  keywords    = "hints file path paste insert vimium",
  run         = function(ctx, args) show_hints(ctx, "paths") end,
}

rex.bind("cmd+e", "link_hints")
rex.bind("cmd+p", "path_hints")
