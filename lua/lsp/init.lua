local M = {}

function M.setup()
	-- Setup global LSP configuration
	local lsp_config = require("lsp.config")
	lsp_config.setup_global_config()

	-- Setup diagnostics
	local diagnostics = require("lsp.diagnostics")
	diagnostics.init()

	-- Setup keymaps
	local keymaps = require("lsp.keymaps")
	keymaps.setup()

	-- Setup management commands
	local commands = require("lsp.commands")
	commands.setup()

	-- Setup quiet notifications (disable noisy messages by default)
	local notifications = require("lsp.notifications")
	notifications.setup()

	-- Use the new loader system for comprehensive setup
	local loader = require("lsp.loader")
	local results = loader.setup({
		-- Mason configuration
		mason = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},

		-- Tool installation (set to false to disable automatic installation)
		ensure_installed = true,
		tool_types = { "lsp", "format", "lint" }, -- Skip DAP for now

		-- Enable formatting and linting
		formatting = true,
		linting = true,

		-- LSP capabilities (will use default if not provided)
		capabilities = nil,
	})

	-- Optional: Show summary of what was loaded (controlled by notifications)
	if results and results.configs_loaded > 0 then
		-- local notifications = require("lsp.notifications")
		if notifications and notifications.should_show_config_messages then
			notifications.should_show_config_messages(
				string.format("Loaded %d language configurations", results.configs_loaded)
			)
		end
	end
end

-- Auto-setup when this module is required
M.setup()

return M
