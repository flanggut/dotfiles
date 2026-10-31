-- Link hints: label every URL on the focused pane's screen and open the one
-- whose label you type. The labels are drawn in a floating pane over the
-- original, which closes again once a link is picked or Escape is pressed.
--
-- Swap this for Rex's own hints once it has them.

local TERMINAL = "com.superlogical.terminal"
local SHELL = "com.superlogical.terminal.shell"
local HERE = debug.getinfo(1, "S").source:match("^@(.*/)")
  or (os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/rex/"
local HELPER = HERE .. "link_hints.py"

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

rex.action{
  name        = "link_hints",
  title       = "Open Link from Screen",
  description = "Label each URL on the focused pane and open the one whose label you type",
  keywords    = "hints url hyperlink open browser vimium",
  run         = function(ctx, args)
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
        label  = "link hints",
        options = {
          shell   = "none",
          command = { "/usr/bin/python3", "-I", HELPER, path,
                      tostring(size.rows), tostring(size.columns) },
        },
      },
    }
    if err ~= nil then
      os.remove(path)
      error(err, 0)
    end
  end,
}

rex.bind("cmd+e", "link_hints")
