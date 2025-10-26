# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Configuration Overview

This is a LazyVim-based Neovim configuration optimized for C++, Python, and general development. The setup includes context-aware tooling that adapts to Meta's fbsource environment while maintaining compatibility with standard projects.

## Plugin Management

Uses **lazy.nvim** as the plugin manager. All plugins are defined in modular specification files under `lua/plugins/`.

### Key Commands
- **Sync plugins**: `:Lazy sync`
- **Update plugins**: `:Lazy update`
- **Check plugin status**: `:Lazy`
- **Reload module**: `R('module.name')` (global helper function)
- **Debug/inspect value**: `P(value)` (global helper function)

### Adding New Plugins
1. Create or edit a file in `lua/plugins/` (e.g., `editor.lua`, `lsp.lua`)
2. Return a table containing plugin specifications:
```lua
return {
  {
    "author/plugin-name",
    keys = { { "<leader>x", "<cmd>Command<cr>", desc = "Description" } },
    opts = { setting = value },
  }
}
```
3. Restart Neovim or run `:Lazy sync`

## Architecture

### File Organization
- `init.lua` - Single entry point: `require("config.lazy")`
- `lua/config/` - Core configuration (lazy, options, keymaps, autocmds)
- `lua/plugins/` - 14 modular plugin specification files
- `lua/fl/` - Custom utilities (functions.lua, snippets.lua)
- `lazy-lock.json` - Locked plugin versions for reproducibility

### Plugin Specification Files
| File | Purpose |
|------|---------|
| `lsp.lua` | Language server configurations and keybindings |
| `completion.lua` | Blink.cmp completion engine |
| `treesitter.lua` | Syntax highlighting and refactoring |
| `linter.lua` | Conform (formatter) and nvim-lint setup |
| `fzf.lua` | Snacks picker integration for fuzzy finding |
| `editor.lua` | Editing utilities (which-key, flash, comment, etc.) |
| `ui.lua` | Dashboard, statusline, bufferline, notifications |
| `ai.lua` | CodeCompanion and Avante AI integrations |
| `shell.lua` | Kitty scrollback integration |
| `fb.lua` | Meta/fbsource-specific tooling |

## Custom Utilities (lua/fl/functions.lua)

Context-aware functions that detect Meta's fbsource environment:

| Function | Purpose |
|----------|---------|
| `fzfiles()` | Smart file finder (arc myles in fbsource, find elsewhere) |
| `grep_in_directory(path)` | Smart grep (xbgs in fbsource, ripgrep elsewhere) |
| `generate_compile_commands(all_files)` | Generate clangd compile_commands.json for C++ |
| `file_runner()` | Execute current file (Python) or send to tmux |
| `float_cmd()` | Run shell command and display in floating window |
| `stream_cmd(cmd, opts)` | Stream command output with real-time filtering and line marking |
| `restart_all_lsp_servers()` | Restart all active LSP clients |

### Modifying Custom Functions
1. Edit `lua/fl/functions.lua`
2. Reload with `:lua R('fl.functions')` (no restart required)
3. Test the function immediately

## Language Server Configuration

### Active LSP Servers
- **Clangd** (C/C++): Uses local LLVM 19 if available at `~/homebrew/opt/llvm@19`, background indexing enabled
- **Pylsp** (Python): Standard projects only
- **fb-pyright-ls** / **pyre**: Meta fbsource Python (when `EDITOR_SUPPORT` env var set)

### LSP Keybindings
| Key | Action |
|-----|--------|
| `<C-j>` | Jump to definition |
| `K` | Hover documentation |
| `<leader>e` | Next diagnostic |
| `<leader>E` | Float diagnostic window |
| `<leader>sa` | Code actions |
| `<leader>sr` | Find references |
| `<leader>rn` | Rename symbol |
| `<leader><leader>l` | Restart LSP servers |

### Adding New LSP Servers
Edit `lua/plugins/lsp.lua` and add to the `servers` table:
```lua
servers = {
  your_server_name = {
    -- configuration options
  },
}
```

## Key Workflows

### C++ Development
1. **Generate compile commands**: `<leader>cd` (current file) or `<leader>cD` (with dependencies)
2. **Navigate code**: `<C-j>` for definition, `<leader>sr` for references
3. **Refactor**: Visual select + `<leader>re` for extract to function/variable

### Python Development
1. **Run current file**: `<leader>p` (outputs in floating window)
2. **Interactive cells**: Visual select + `<space>l` (molten-nvim)
3. **Format**: Automatically with Black on save (or `<leader>F` to toggle)
4. **Lint**: Ruff (standard) or fbflake8 (fbsource)

### Stream Command Output (`stream_cmd`)

A powerful utility for running commands and filtering their output in real-time. Implemented in `lua/fl/stream_cmd.lua`.

#### Features
- **Real-time streaming**: Command output appears as it's generated
- **Live filtering**: Filter output with multiple include/exclude patterns
- **Smart case matching**: Case-insensitive by default, case-sensitive when filter contains uppercase
- **Line marking**: Mark important lines with highlights and collect in separate window
- **Filter history**: Save and recall filter configurations with `<C-k>`
- **Three-pane layout**: Filter editor (left), output (right), marked lines (bottom)

#### Usage
```lua
-- Run a command with streaming output
R('fl.functions').stream_cmd('adb logcat')

-- Filter current buffer content (empty command)
R('fl.functions').stream_cmd('')

-- Options: split type, size, filetype, enable_filter
R('fl.functions').stream_cmd('tail -f log.txt', {
  split = 'horizontal',  -- 'horizontal'|'vertical'|'tab'|'fullscreen'
  size = 20,
  filetype = 'log',
  enable_filter = true
})
```

#### Keybindings (within stream_cmd windows)
| Key | Action |
|-----|--------|
| `<C-j>` | Toggle between filter and output windows |
| `<C-k>` | Open filter history picker (in filter window) |
| `<C-d>` | Close all stream_cmd windows and stop job |
| `m` | Toggle mark on current line (in output window) |

#### Filter Syntax
- **Include filter**: Type text to show only matching lines (e.g., `ERROR`)
- **Exclude filter**: Prefix with `!` to hide matching lines (e.g., `!DEBUG`)
- **Multiple filters**: Each line in filter buffer is a separate filter
- **Smart case**: `error` matches `ERROR` and `Error`, but `Error` only matches `Error`

#### Filter History
- Filters are automatically saved when closing with `<C-d>`
- Use `<C-k>` in filter window to select from history
- History limited to 100 most recent unique filter combinations
- Stored in: `~/.local/share/nvim/stream_cmd_filter_history.json`

#### Marked Lines
- Press `m` in output window to mark/unmark current line
- Marked lines highlighted with `StreamCmdMark` highlight group
- Collected in bottom window, maintaining display order
- Useful for extracting specific log entries or errors

### Multi-file Search/Replace
1. **Open grug-far**: `<leader>gu` (prefills current word)
2. **From visual mode**: `gl` (prefills file path)
3. Interactive ripgrep-based find/replace UI

### AI Assistance
1. **Chat mode**: `<C-p>`
2. **Inline completion**: `gi`
3. **Add to chat**: `ga` (visual mode)
4. Uses CodeCompanion with ollama or Meta internal LLM

## Keybinding Philosophy

- `<space>` is both leader and localleader
- `<leader>` prefix for general commands (discoverable via which-key menu)
- `<C-key>` for LSP and navigation (quick access, no menu)
- `<M-hjkl>` for tmux pane navigation (seamless integration)

### Important Keybindings
| Key | Action |
|-----|--------|
| `<leader>y` | Yank to system clipboard |
| `<leader>r` | Replace visual selection |
| `<leader>oo` | Fold matching search results |
| `<leader>sd` | Buffer diagnostics (picker) |
| `<leader>sf` | Search current buffer lines |
| `<leader>si` | Treesitter symbols |
| `<leader>sl` | Recent files (cwd-filtered) |
| `<C-k>` | LSP document symbols |
| `<C-l>` | Buffer picker |

## Snippets

Custom snippets defined in `lua/fl/snippets.lua` using LuaSnip:

### C++ Snippets
- `co` → `std::cout << ... << std::endl;`
- `la` → Lambda template
- `imfor` → Image processing loop
- `may` → `[[maybe_unused]]`

### Python Snippets
- `print` → f-string print statement

### Modifying Snippets
1. Edit `lua/fl/snippets.lua`
2. Save (auto-reloads via autocmd)
3. Snippets immediately available

## Context Detection

The configuration detects Meta's fbsource environment with `is_fb()` function:
- Checks for `.fbsource.toml` and `.hg` directory
- Enables specialized tooling when in fbsource (xbgs, arc myles, Buck syntax)
- Falls back to standard tools (ripgrep, find) in normal projects

## Performance Optimization

- **Lazy loading**: Plugins load on-demand via events, commands, or keybindings
- **Disabled built-ins**: 17 built-in Neovim plugins disabled (2html, netrw, etc.)
- **Minimal init**: Single-line init.lua defers all loading to lazy.nvim
- **Treesitter folding**: Uses indent-based folding for speed

## Debugging Configuration

1. **Check loaded plugins**: `:Lazy`
2. **LSP status**: `:LspInfo`
3. **Inspect value**: `P(vim.inspect(value))` in command mode
4. **Reload module**: `:lua R('fl.functions')` or `:lua R('plugins.lsp')`
5. **Check keybindings**: `<leader>` (opens which-key menu)
6. **View lazy.nvim logs**: `:Lazy log`

## Integration with External Tools

- **Tmux**: Seamless pane navigation with `<M-hjkl>`, command execution to previous pane
- **Kitty**: Scrollback integration for terminal output review
- **Oil.nvim**: File manager (replaces neo-tree)
- **Vim-signify**: Git gutter signs (replaces gitsigns)
- **FZF**: Used in picker integration for fuzzy finding

## Special File Types

- **Buck files**: Custom syntax highlighting in `syntax/buck.vim`
- **CSV files**: Interactive viewer with column highlighting
- **Markdown**: Render-markdown for formatted preview
- **Jupyter notebooks**: Molten-nvim for interactive cell execution
