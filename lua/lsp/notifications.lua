local M = {}

-- Notification configuration with all available message types
M.config = {
	-- Loader messages
	config_loaded = false, -- "Loaded X language configurations"
	server_configured = false, -- "LSP: X/X servers configured"

	-- Server lifecycle messages
	server_start = false, -- "Started LSP server: X"
	server_stop = false, -- "Stopped LSP server: X"
	server_restart = false, -- "Restarting LSP server: X"
	server_enable = false, -- "Enabled LSP server: X"
	server_disable = false, -- "Disabled LSP server: X"

	-- LSP attach/detach messages
	lsp_attach = false, -- "LSP attached: X"
	lsp_detach = false, -- "LSP detached: X"

	-- Tool management messages
	tool_install = false, -- "Installing: X" from Mason
	tool_missing = true, -- "Tool not found in registry" (keep enabled by default)

	-- Formatting/linting messages
	format_warning = false, -- "No LSP client supports formatting"
	lint_warning = false, -- Linter-related warnings

	-- Global settings
	errors_only = false, -- When true, only show ERROR level messages
	show_titles = true, -- Show notification titles ("LSP", "Mason", etc.)
}

-- Notification type metadata
local notification_types = {
	config_loaded = {
		title = "LSP Loader",
		level = vim.log.levels.INFO,
		description = "Configuration loading messages",
	},
	server_configured = {
		title = "LSP Loader",
		level = vim.log.levels.INFO,
		description = "Server configuration summary",
	},
	server_start = { title = "LSP", level = vim.log.levels.INFO, description = "Server start messages" },
	server_stop = { title = "LSP", level = vim.log.levels.INFO, description = "Server stop messages" },
	server_restart = { title = "LSP", level = vim.log.levels.INFO, description = "Server restart messages" },
	server_enable = { title = "LSP Config", level = vim.log.levels.INFO, description = "Server enable messages" },
	server_disable = { title = "LSP Config", level = vim.log.levels.INFO, description = "Server disable messages" },
	lsp_attach = { title = "LSP", level = vim.log.levels.INFO, description = "LSP attach notifications" },
	lsp_detach = { title = "LSP", level = vim.log.levels.INFO, description = "LSP detach notifications" },
	tool_install = { title = "Mason", level = vim.log.levels.INFO, description = "Tool installation messages" },
	tool_missing = { title = "Mason", level = vim.log.levels.WARN, description = "Missing tool warnings" },
	format_warning = { title = "LSP", level = vim.log.levels.WARN, description = "Formatting warnings" },
	lint_warning = { title = "LSP", level = vim.log.levels.WARN, description = "Linting warnings" },
}

--- Core notification function with filtering
--- @param notification_type string The type of notification
--- @param message string The message to show
--- @param level? number Optional log level override
--- @param opts? table Optional notification options
function M.notify(notification_type, message, level, opts)
	-- Check if notification type exists
	if not notification_types[notification_type] then
		error("Unknown notification type: " .. notification_type)
	end

	local type_info = notification_types[notification_type]
	level = level or type_info.level
	opts = opts or {}

	-- Always show errors regardless of settings
	if level == vim.log.levels.ERROR then
		vim.notify(
			message,
			level,
			vim.tbl_extend("force", {
				title = M.config.show_titles and type_info.title or nil,
			}, opts)
		)
		return
	end

	-- If errors_only mode is enabled, skip non-errors
	if M.config.errors_only then
		return
	end

	-- Check if this notification type is enabled
	if not M.config[notification_type] then
		return
	end

	-- Show the notification
	vim.notify(
		message,
		level,
		vim.tbl_extend("force", {
			title = M.config.show_titles and type_info.title or nil,
		}, opts)
	)
end

--- Configure notification settings
--- @param opts table Configuration options
function M.configure(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

--- Get current configuration
--- @return table Current configuration
function M.get_config()
	return vim.deepcopy(M.config)
end

--- Get available notification types with descriptions
--- @return table Map of notification types to their metadata
function M.get_notification_types()
	return vim.deepcopy(notification_types)
end

--- Toggle a specific notification type
--- @param notification_type string The notification type to toggle
--- @return boolean The new state
function M.toggle(notification_type)
	if M.config[notification_type] == nil then
		error("Unknown notification type: " .. notification_type)
	end

	M.config[notification_type] = not M.config[notification_type]
	return M.config[notification_type]
end

--- Enable multiple notification types
--- @param types string[] List of notification types to enable
function M.enable(types)
	for _, notification_type in ipairs(types) do
		if M.config[notification_type] ~= nil then
			M.config[notification_type] = true
		end
	end
end

--- Disable multiple notification types
--- @param types string[] List of notification types to disable
function M.disable(types)
	for _, notification_type in ipairs(types) do
		if M.config[notification_type] ~= nil then
			M.config[notification_type] = false
		end
	end
end

--- Enable all notifications (for debugging)
function M.enable_all()
	for notification_type, _ in pairs(notification_types) do
		M.config[notification_type] = true
	end
	M.config.errors_only = false
end

--- Disable all non-error notifications (default quiet mode)
function M.disable_all()
	for notification_type, _ in pairs(notification_types) do
		M.config[notification_type] = false
	end
	M.config.errors_only = true
end

--- Set up default quiet configuration
function M.setup()
	-- Default to quiet mode - only show essential messages
	M.disable_all()

	-- Show tool missing warnings by default (important for setup)
	M.config.tool_missing = true
	M.config.errors_only = false -- We want to show warnings too
end

return M

