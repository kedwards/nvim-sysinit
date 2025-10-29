# 🚀 Sysinit - Personal Neovim Configuration

A performance-focused [Neovim](https://neovim.io/) configuration showcasing modern Lua patterns, modular LSP architecture, and careful plugin selection. This is my personal setup shared as a reference implementation—not a distribution for direct use.

> **Note**: This configuration is tailored to my workflow and preferences. Feel free to explore and borrow ideas, but I recommend understanding each component rather than copying wholesale.

## 📊 Performance

- **Startup Time**: ~75ms with 30+ plugins
- **Plugin Count**: 30 carefully selected plugins
- **Loading Strategy**: Event-driven lazy loading
- **Optimization**: vim.loader caching, disabled unused providers

## 🏗️ Architecture

```
├── init.lua                   # Main entry point with error handling
├── lua/
│   ├── config/                # Core configuration
│   │   ├── init.lua           # Config loader
│   │   ├── options.lua        # Neovim settings
│   │   ├── keymaps.lua        # Key mappings
│   │   ├── autocmds.lua       # Auto commands
│   │   └── utils.lua          # Path management and Mason setup
│   ├── lsp/                   # LSP system
│   │   ├── loader.lua         # Modern LSP loader
│   │   ├── config.lua         # Global LSP configuration
│   │   ├── capabilities.lua   # Enhanced LSP capabilities
│   │   ├── diagnostics.lua    # Diagnostic configuration
│   │   ├── keymaps.lua        # LSP keybindings
│   │   ├── commands.lua       # LSP management commands
│   │   ├── utils.lua          # LSP utility functions
│   │   ├── configs/           # Language-specific configs
│   │   └── README.md          # LSP documentation
│   └── plugins/               # Plugin specifications
└── selene.toml                # Lua linting configuration
```

## 🎯 Key Features

### ⚡ Performance Optimized
- **vim.loader.enable()** for faster module loading
- **Lazy loading** for all non-essential plugins
- **Disabled unused providers** (Perl, Ruby, Node, Python)
- **Large file detection** with automatic optimization
- **Smart plugin loading** based on events

### 🧠 Intelligent LSP System
- **Automatic tool installation** via Mason
- **Custom linter configurations** (e.g., selene with config file)
- **Modern API usage** (Neovim 0.11+ compatible)
- **Error handling** with graceful degradation
- **Modular language configs** - Easy to add new languages

### 🎨 Modern UI/UX
- **OneDark theme** with vivid variant
- **Blink.cmp** - Fast completion with Copilot + LuaSnip integration
- **Noice** - Enhanced command line and notification UI
- **Trouble** - Pretty diagnostics with floating preview
- **Lualine** - Statusline with LSP status and git integration
- **Telescope** - Fuzzy finding for files, buffers, and more

## 🔧 Management Commands

### LSP Management
- `:LspShowConfigs` - Show all loaded language configurations
- `:LspShowTools` - Display available tools by type
- `:LspInstallMissing` - Install missing tools automatically
- `:LspShowCustomLinters` - View custom linter configurations
- `:LspShowFiletypeConfig` - Show configuration for specific filetype
- `:LspClearCache` - Clear loader cache

### Plugin Management
- `:Lazy` - Open plugin manager
- `:Lazy sync` - Update all plugins
- `:Lazy profile` - Profile plugin loading times

## 🛠️ Customization Guide

### Adding New Language Support
1. **Create config**: `:LspNewConfig <language>`
2. **Edit template**: Add LSP, formatters, linters
3. **Custom linter config** (if needed):
```lua
lint_config = {
  tool_name = {
    cmd = "command",
    args = { "--config", "path/to/config" },
    stdin = false,
  }
}
```

### Plugin Configuration
Plugins are in `lua/plugins/` with lazy loading:
```lua
return {
  "plugin/name",
  event = "VeryLazy",  -- or cmd, keys, ft
  opts = { },          -- or config = function() end
}
```

### Keymap Customization
Keymaps use a helper function in `lua/config/keymaps.lua`:
```lua
map("n", "<leader>x", ":command", "Description")
```

## ⚠️ Before Using

This is a **personal configuration** shared for educational purposes:

1. **Review before use** - Understand what each plugin and setting does
2. **Copilot required** - AI completion features need a GitHub Copilot subscription
3. **Dependencies** - Requires `git`, `rg` (ripgrep), `fd`, and a Nerd Font
4. **Neovim 0.11+** - Built for the latest Neovim APIs
5. **Adapt to your needs** - This reflects my workflow; yours will differ

## 🚀 Quick Start

If you still want to try it:

```bash
# Backup your existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this config
git clone <your-repo-url> ~/.config/nvim

# Start Neovim (plugins will auto-install)
nvim

# Check health
:checkhealth
```

## 🔧 Key Technologies

- **Neovim 0.11+** - Latest APIs and performance improvements
- **lazy.nvim** - Modern plugin manager with lazy loading
- **Blink.cmp** - Fast completion engine written in Lua
- **Mason** - Automatic LSP/formatter/linter installation
- **Conform.nvim** - Async formatting
- **nvim-lint** - Async linting with custom configurations
- **Treesitter** - Advanced syntax highlighting
- **Telescope** - Fuzzy finder interface

## 📝 License

This configuration is provided as-is for educational purposes. Feel free to learn from it, don't blindly copy. Build your own config that works for you!
