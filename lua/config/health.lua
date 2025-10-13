local M = {}

-- Health check for configuration
function M.check()
  local health_start = vim.health.start or vim.health.report_start
  local health_ok = vim.health.ok or vim.health.report_ok
  local health_warn = vim.health.warn or vim.health.report_warn
  local health_error = vim.health.error or vim.health.report_error
  local health_info = vim.health.info or vim.health.report_info
  
  health_start("Sysinit Configuration")
  
  -- Check LSP configuration
  local lsp_configs = vim.fn.glob(vim.fn.stdpath("config") .. "/lua/lsp/configs/*.lua", false, true)
  if #lsp_configs > 0 then
    health_ok(string.format("Found %d LSP configurations", #lsp_configs))
  else
    health_warn("No LSP configurations found")
  end
  
  -- Check essential plugins
  local essential_plugins = {
    "lazy", "blink.cmp", "nvim-treesitter", "lualine"
  }
  
  for _, plugin in ipairs(essential_plugins) do
    local ok = pcall(require, plugin)
    if ok then
      health_ok(string.format("Plugin '%s' is loaded", plugin))
    else
      health_error(string.format("Plugin '%s' failed to load", plugin))
    end
  end
  
  -- Check external tools
  local tools = {
    { "rg", "ripgrep for better search" },
    { "fd", "fd for file finding" },
    { "git", "version control" },
  }
  
  for _, tool in ipairs(tools) do
    if vim.fn.executable(tool[1]) == 1 then
      health_ok(string.format("Tool '%s' is available", tool[1]))
    else
      health_warn(string.format("Tool '%s' not found (%s)", tool[1], tool[2]))
    end
  end
  
  -- Check startup time
  local startup_file = vim.fn.stdpath("config") .. "/startup.log"
  if vim.fn.filereadable(startup_file) == 1 then
    local lines = vim.fn.readfile(startup_file)
    local startup_time = nil
    for _, line in ipairs(lines) do
      if line:match("NVIM STARTED") then
        startup_time = line:match("^(%d+%.%d+)")
        break
      end
    end
    
    if startup_time then
      local time = tonumber(startup_time)
      if time < 50 then
        health_ok(string.format("Startup time: %.1fms (excellent)", time))
      elseif time < 100 then
        health_ok(string.format("Startup time: %.1fms (good)", time))
      else
        health_warn(string.format("Startup time: %.1fms (consider optimization)", time))
      end
    end
  else
    health_info("Run ':StartupTime' to check startup performance")
  end
end

-- Performance monitoring
function M.profile_startup()
  vim.fn.system({ "nvim", "--headless", "--startuptime", "startup.log", "-c", "qa" })
  vim.cmd("edit startup.log")
end

-- Auto-update plugins check
function M.check_updates()
  local lazy = require("lazy")
  local updates = lazy.check()
  if #updates > 0 then
    vim.notify(string.format("Found %d plugin updates available", #updates), 
               vim.log.levels.INFO, { title = "Plugin Updates" })
  else
    vim.notify("All plugins are up to date", vim.log.levels.INFO, { title = "Plugin Status" })
  end
end

return M