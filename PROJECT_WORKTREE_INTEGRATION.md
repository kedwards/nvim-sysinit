# Git Worktree Integration for Neovim Project

these requirements are required when installing languages like php, julia, java 
```bash
apt install autoconf bison re2c pkg-config libxml2-dev libssl-dev sqlite3 libsqlite3-dev zlib1g-dev libcurl4-gnutls-dev libgd-dev libicu-dev build-essential libonig-dev libpq-dev libreadline-dev libzip-dev
```

This configuration provides seamless integration between the `neovim-project` and `git-worktree` plugins without requiring a fork of either plugin.

## How It Works

When you select a project through the neovim-project picker, the integration automatically:

1. **Checks if the project is a git worktree**: Uses `git rev-parse --is-inside-work-tree` to detect git repositories
2. **Shows worktree picker**: If the project has git worktrees, opens the git-worktree telescope picker
3. **Handles worktree switching**: When you select a worktree, automatically switches the project session
4. **Falls back to normal behavior**: If no worktrees are found, uses standard project switching

## Features

- ✅ **Zero fork maintenance**: Uses plugin configuration and hooks only
- ✅ **Automatic detection**: Automatically detects git worktrees
- ✅ **Seamless integration**: Works with existing neovim-project workflows
- ✅ **Graceful fallbacks**: Works even if git-worktree plugin isn't installed
- ✅ **Custom commands**: Additional commands for manual worktree operations

## Components

### 1. Core Integration (`lua/config/project-worktree.lua`)

A modular integration layer that provides:
- Git worktree detection
- Telescope action wrappers
- Worktree picker with session switching
- User commands

### 2. Plugin Configuration (`lua/plugins/neovim-project.lua`)

Enhanced neovim-project configuration that:
- Loads the integration module
- Sets up dependencies
- Configures keybindings

### 3. Telescope Configuration (`lua/plugins/telescope.lua`)

Telescope configuration that:
- Maps custom actions for neovim-project extension
- Provides fallbacks for standard behavior

## Usage

### Automatic Usage

1. **Open project picker**: `<leader>pd` or `:NeovimProjectDiscover`
2. **Select a project**: Press `<CR>` on any project
3. **Choose worktree** (if available): If the project has worktrees, a second picker appears
4. **Switch to worktree**: Select the desired worktree and the session switches

### Manual Commands

| Command | Description |
|---------|-------------|
| `:ProjectWorktrees` | Show worktrees for the current project |
| `:ProjectSwitchWithWorktree <dir>` | Switch to project with worktree support |
| `:ProjectWorktreeStatus` | Check if current directory is in a git worktree |

### Keybindings

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>pd` | `:NeovimProjectDiscover` | Find a project (with worktree integration) |
| `<leader>pa` | `:NeovimProjectDiscover alphabetical_name` | Find a project by name |
| `<leader>ph` | `:NeovimProjectHistory` | Select from project history |
| `<leader>pr` | `:NeovimProjectLoadRecent` | Open previous project session |
| `<leader>pw` | `:ProjectWorktrees` | Show worktrees for current project |

## Implementation Details

### Git Worktree Detection

```lua
local function is_inside_git_worktree(dir)
  -- Change to target directory temporarily
  -- Run git rev-parse --is-inside-work-tree
  -- Return true if exit code is 0
end
```

### Worktree Selection Flow

```
Project Selection → Git Check → Worktree Picker → Session Switch
                              ↓
                         Normal Project Switch (if no worktrees)
```

### Telescope Action Override

The integration creates custom telescope actions that:
1. Get the selected project directory
2. Check for git worktrees
3. Show worktree picker or switch directly
4. Handle the session management

## Configuration Options

### Customizing Project Patterns

```lua
opts = {
  projects = {
    "~/projects/*",
    "~/.config/*",
    "~/work/*",  -- Add your project directories
  },
}
```

### Customizing Keybindings

```lua
keys = {
  { "<leader>fp", "<cmd>NeovimProjectDiscover<cr>", desc = "Find Project" },
  { "<leader>fw", "<cmd>ProjectWorktrees<cr>", desc = "Project Worktrees" },
  -- Add your custom bindings
}
```

## Troubleshooting

### Git Branch Not Updating in Lualine

If lualine shows stale git branch information after switching projects:

1. The integration includes automatic UI refresh mechanisms
2. Lualine branch component is configured to check git status on each refresh
3. Multiple refresh attempts are made with delays to ensure updates
4. If still not working, restart Neovim or run `:lua require('lualine').refresh()`

### Git Worktree Not Detected

1. Ensure `git-worktree` plugin is installed
2. Check that the project directory is a git repository
3. Verify worktrees exist: `git worktree list`

### Telescope Actions Not Working

1. Ensure telescope is loaded before the integration
2. Check that `_G._project_worktree_actions` is defined
3. Restart Neovim to reload configurations

### Session Switching Issues

1. Ensure `neovim-session-manager` is properly configured
2. Check session directory permissions
3. Verify project paths are accessible

## Dependencies

Required plugins:
- `coffebar/neovim-project`
- `ThePrimeagen/git-worktree.nvim`
- `nvim-telescope/telescope.nvim`
- `Shatur/neovim-session-manager`

Optional:
- `nvim-lua/plenary.nvim` (usually auto-installed)

## Contributing

To modify or extend this integration:

1. **Core logic**: Edit `lua/config/project-worktree.lua`
2. **Plugin config**: Modify `lua/plugins/neovim-project.lua`  
3. **Telescope actions**: Update `lua/plugins/telescope.lua`
4. **Test changes**: Use the provided commands to test functionality

The modular design makes it easy to adjust behavior without affecting the base plugins.
