local capabilities = require("lsp.capabilities")

local M = {}

--- Configure global LSP defaults
function M.setup_global_config()
	vim.lsp.config("*", {
		capabilities = capabilities.get_capabilities(),
		root_markers = { ".git", ".hg", ".svn" },

		-- Global settings that apply to all servers
		settings = {},

		-- Default handlers
		handlers = {
			["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
				focusable = false,
			}),
			["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
				focusable = false,
			}),
		},
	})
end

return M

-- --- Configure a specific LSP server
-- --- @param server_name string The name of the LSP server
-- --- @param config table Server-specific configuration
-- function M.configure_server(server_name, config)
-- 	config = config or {}
--
-- 	-- Ensure we have the base capabilities
-- 	config.capabilities = capabilities.get_server_capabilities(config.capabilities)
--
-- 	-- Set up default on_attach function
-- 	local default_on_attach = function(client, bufnr)
-- 		-- Setup keymaps
-- 		local keymaps_ok, keymaps = pcall(require, "lsp.keymaps")
-- 		if keymaps_ok then
-- 			keymaps.setup_buffer_keymaps(client, bufnr)
-- 		end
--
-- 		-- Call custom on_attach if provided
-- 		if config.on_attach then
-- 			config.on_attach(client, bufnr)
-- 		end
-- 	end
--
-- 	-- Set up the server configuration
-- 	local server_config = vim.tbl_deep_extend("force", {
-- 		capabilities = config.capabilities,
-- 		on_attach = default_on_attach,
-- 	}, config)
--
-- 	-- Handle root_dir function
-- 	if config.root_markers then
-- 		server_config.root_dir = function(fname)
-- 			local root = vim.fs.find(config.root_markers, { upward = true, path = fname })[1]
-- 			return root and vim.fs.dirname(root) or vim.fn.getcwd()
-- 		end
-- 	end
--
-- 	-- Configure the server
-- 	local ok, err = pcall(function()
-- 		vim.lsp.config(server_name, server_config)
-- 	end)
--
-- 	if not ok then
-- 		lsp_notify(
-- 			string.format("Failed to configure LSP server '%s': %s", server_name, err),
-- 			vim.log.levels.ERROR,
-- 			"server_config",
-- 			{ title = "LSP Config" }
-- 		)
-- 		return false
-- 	end
--
-- 	return true
-- end
--
-- --- Disable a running LSP server
-- --- @param server_name string The name of the LSP server to disable
-- function M.disable_server(server_name)
-- 	local ok, err = pcall(function()
-- 		vim.lsp.disable(server_name)
-- 	end)
--
-- 	if not ok then
-- 		lsp_notify(
-- 			string.format("Failed to disable LSP server '%s': %s", server_name, err),
-- 			vim.log.levels.ERROR,
-- 			"server_disable",
-- 			{ title = "LSP Config" }
-- 		)
-- 		return false
-- 	end
--
-- 	lsp_notify(
-- 		string.format("Disabled LSP server: %s", server_name),
-- 		vim.log.levels.INFO,
-- 		"server_disable",
-- 		{ title = "LSP Config" }
-- 	)
--
-- 	return true
-- end
--
-- --- Enable a configured LSP server
-- --- @param server_name string The name of the LSP server to enable
-- --- @param filetypes? string[] Optional list of filetypes to enable for
-- function M.enable_server(server_name, filetypes)
-- 	local ok, err = pcall(function()
-- 		if filetypes then
-- 			-- Enable for specific filetypes
-- 			for _, ft in ipairs(filetypes) do
-- 				vim.lsp.enable(server_name, { bufnr = 0, filetype = ft })
-- 			end
-- 		else
-- 			-- Enable globally
-- 			vim.lsp.enable(server_name)
-- 		end
-- 	end)
--
-- 	if not ok then
-- 		lsp_notify(
-- 			string.format("Failed to enable LSP server '%s': %s", server_name, err),
-- 			vim.log.levels.ERROR,
-- 			"server_enable",
-- 			{ title = "LSP Config" }
-- 		)
-- 		return false
-- 	end
--
-- 	lsp_notify(
-- 		string.format("Enabled LSP server: %s", server_name),
-- 		vim.log.levels.INFO,
-- 		"server_enable",
-- 		{ title = "LSP Config" }
-- 	)
--
-- 	return true
-- end
--
-- --- Get the configuration for a specific server
-- --- @param server_name string The name of the LSP server
-- --- @return table|nil The server configuration or nil if not found
-- function M.get_server_config(server_name)
-- 	-- Use pcall to safely access the configuration
-- 	local ok, config = pcall(function()
-- 		return vim.lsp.config[server_name]
-- 	end)
--
-- 	if ok then
-- 		return config
-- 	end
--
-- 	return nil
-- end
--
-- --- Check if a server is configured
-- --- @param server_name string The name of the LSP server
-- --- @return boolean True if the server is configured
-- function M.is_server_configured(server_name)
-- 	return M.get_server_config(server_name) ~= nil
-- end
--
-- --- Setup multiple servers from a configuration table
-- --- @param servers table<string, table> Map of server names to configurations
-- function M.setup_servers(servers)
-- 	local configured = {}
-- 	local failed = {}
--
-- 	for server_name, config in pairs(servers) do
-- 		if M.configure_server(server_name, config) then
-- 			table.insert(configured, server_name)
--
-- 			-- Auto-enable the server if not explicitly disabled
-- 			if config.auto_enable ~= false then
-- 				M.enable_server(server_name, config.filetypes)
-- 			end
-- 		else
-- 			table.insert(failed, server_name)
-- 		end
-- 	end
--
-- 	if #configured > 0 then
-- 		lsp_notify(
-- 			string.format("Configured LSP servers: %s", table.concat(configured, ", ")),
-- 			vim.log.levels.INFO,
-- 			"server_config",
-- 			{ title = "LSP Config" }
-- 		)
-- 	end
--
-- 	if #failed > 0 then
-- 		lsp_notify(
-- 			string.format("Failed to configure LSP servers: %s", table.concat(failed, ", ")),
-- 			vim.log.levels.WARN,
-- 			"server_config",
-- 			{ title = "LSP Config" }
-- 		)
-- 	end
-- end
