# 🚀 Sysinit Neovim Configuration

A high-performance, modular Neovim configuration optimized for development workflow.

## 📊 Performance Stats

- **Startup Time**: ~38ms (excellent!)
- **Plugin Count**: ~30 carefully selected plugins
- **Memory Usage**: Optimized with lazy loading
- **LSP Languages**: 4+ pre-configured (Lua, Python, Go, TypeScript)

## 🏗️ Architecture

```
├── init.lua                    # Main entry point with error handling
├── lua/
│   ├── config/                 # Core configuration
│   │   ├── init.lua           # Config loader
│   │   ├── options.lua        # Neovim settings (optimized)
│   │   ├── keymaps.lua        # Key mappings (table-driven)
│   │   ├── autocmds.lua       # Auto commands (organized)
│   │   └── health.lua         # Configuration health checks
│   ├── lsp/                   # LSP system (modular)
│   │   ├── loader.lua         # Modern LSP loader
│   │   ├── configs/           # Language-specific configs
│   │   ├── notifications.lua  # Notification control
│   │   └── ...
│   └── plugins/               # Plugin specifications
├── selene.toml                # Lua linting configuration
└── startup.log                # Performance profiling
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
- **Notification control system** (quiet by default)
- **Modern API usage** (Neovim 0.11+ compatible)
- **Error handling** with graceful degradation

### 🎨 Modern UI/UX
- **OneDark theme** with vivid variant
- **Blink completion** with Copilot integration
- **Noice UI** for better command/message experience
- **Trouble diagnostics** with floating preview
- **Lualine** with LSP status and file icons

## 🔧 Management Commands

### LSP Management
- `:LspShowConfigs` - Show all loaded language configurations
- `:LspShowTools` - Display available tools by type
- `:LspInstallMissing` - Install missing tools automatically
- `:LspShowCustomLinters` - View custom linter configurations
- `:ConfigHealth` - Run configuration health check
- `:ProfileStartup` - Profile startup performance

### Plugin Management
- `:Lazy` - Open plugin manager
- `:Lazy sync` - Update all plugins
- `:Lazy profile` - Profile plugin loading times

## ⚡ Optimization Tips

### Startup Time Optimization
1. **Monitor startup**: Use `:ProfileStartup` regularly
2. **Lazy load plugins**: Use `event`, `cmd`, or `keys` triggers
3. **Disable unused features**: Check disabled providers in options.lua
4. **Large files**: Auto-optimization kicks in for files >1MB

### Memory Optimization
1. **LSP notifications**: Disabled by default (use `:LspToggleAllNotifications`)
2. **Treesitter**: Disabled for large files automatically
3. **Plugin caching**: Enabled in lazy.nvim configuration

### Development Workflow
1. **Health checks**: Run `:ConfigHealth` periodically
2. **Tool management**: Use `:LspInstallMissing` for new projects
3. **Custom linters**: Add to `lua/lsp/configs/` with `lint_config`

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
Keymaps use table-driven approach in `lua/config/keymaps.lua`:
```lua
{ "n", "<leader>x", ":command", "Description" }
```

## 📋 Health Monitoring

### Built-in Health Checks
- **Configuration loading**: Validates all modules load correctly
- **Plugin status**: Verifies essential plugins are functional
- **External tools**: Checks availability of rg, fd, git
- **LSP configurations**: Counts available language configs
- **Startup performance**: Tracks and reports timing

### Performance Monitoring
- **Startup profiling**: Automatic with vim-startuptime
- **Plugin profiling**: Built into lazy.nvim
- **Large file detection**: Auto-optimization for 1MB+ files
- **Memory usage**: Lazy loading minimizes footprint

## 🚀 Next Steps

1. **Run health check**: `:ConfigHealth`
2. **Profile startup**: `:ProfileStartup`
3. **Check tool availability**: `:LspShowTools`
4. **Install missing tools**: `:LspInstallMissing`
5. **Customize keymaps**: Edit `lua/config/keymaps.lua`
6. **Add languages**: Use `:LspNewConfig <name>`

## 🐛 Troubleshooting

### Common Issues
- **Slow startup**: Run `:ProfileStartup` and check lazy loading
- **LSP not working**: Use `:LspInfo` and `:ConfigHealth`
- **Missing tools**: Run `:LspInstallMissing`
- **Notifications**: Toggle with `:LspToggleAllNotifications`

### Debug Mode
Enable verbose logging for troubleshooting:
```lua
vim.lsp.set_log_level("debug")  -- In any config file
```

---

**Configuration Health**: Run `:ConfigHealth` to verify optimal setup!