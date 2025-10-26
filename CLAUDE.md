# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository containing configuration files and custom scripts for a macOS development environment. The repository is organized into tool-specific directories with accompanying shell functions and utilities.

## Key Components

### Shell Configuration
- **fish/salmon**: Fish shell configuration with custom functions and completions
- **zsh**: Zsh configuration with custom plugins (adb, fzf)
- **bashrc**: Bash configuration

### Development Tools
- **nvim**: Neovim configuration
- **tmux**: Terminal multiplexer configuration  
- **kitty**: Terminal emulator configuration
- **git**: Git configuration
- **yazi**: File manager configuration

### Utilities
- **bashscripts/tm**: Tmux session manager script that allows:
  - Creating/attaching to sessions by name or partial match
  - Interactive session selection with fzf or menu fallback
  - Automatic session creation if no match found
- **raycast**: Raycast script collection for macOS automation

### Custom Fish Functions
Located in `salmon/functions/`, includes utilities for:
- Directory navigation (`cdd`, `cdf`, `fd`)
- Video processing (`mov2gif`, `video_extract_keyframes`, `video_from_frames`, `video_loop`)
- File management (`n`, `nd`, `number_rename`)
- FZF integration (`__fzf_*` functions)

## Common Operations

### Using the tmux manager
```bash
./bashscripts/tm [session-name] [window-name]
```
- Without arguments: Shows interactive session picker
- With session name: Attaches to existing or creates new session
- Supports partial name matching

### Shell Function Development
- Fish functions go in `salmon/functions/`
- Completions go in `salmon/completions/`
- Key bindings in `salmon/conf.d/fish_user_key_bindings.fish`

## Architecture Notes

- The repository follows a modular structure with each tool in its own directory
- Fish shell setup uses "salmon" as the config directory name
- Custom utilities focus on terminal workflow optimization and media processing
- Heavy use of fzf for interactive selection throughout various scripts
- Cross-shell compatibility maintained where possible (bash/zsh/fish)