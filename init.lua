-- Improve startup time by skipping some checks
vim.loader.enable()

-- Load core configuration and plugin loader
local modules = { "config", "Lazy" }
local load_errors = {}

for _, module in ipairs(modules) do
	local ok, err = pcall(require, module)
	if not ok then
		table.insert(load_errors, { module = module, error = err })
		-- Show error but don't block startup
		vim.notify(string.format("Failed to load %s: %s", module, err), vim.log.levels.ERROR, { title = "Init Error" })
	end
end

-- Show summary of load errors if any
if #load_errors > 0 then
	vim.defer_fn(function()
		vim.notify(
			string.format("Configuration loaded with %d errors. Check :messages for details.", #load_errors),
			vim.log.levels.WARN,
			{ title = "Startup Warning" }
		)
	end, 500)
end
