local M = {}

function M.setup()
	-- Setup global LSP configuration
	require("lsp.config").setup_global_config()

	-- Setup diagnostics
	require("lsp.diagnostics").init()

	-- Setup notifications
	-- require("lsp.notifications").setup()

	-- Setup keymaps
	-- require("lsp.keymaps").setup()

	-- Setup management commands
	require("lsp.commands").setup()

	-- lsp loader
	local results = require("lsp.loader").setup()

	if results and results.configs_loaded > 0 then
		return
		-- local notifications = require("lsp.notifications")
		--   if notifications and notifications.should_show_config_messages then
		--     notifications.should_show_config_messages(
		--       string.format("Loaded %d language configurations", results.configs_loaded)
		--     )
		--   end
	end
end

-- Auto-setup when this module is required
M.setup()

return M
