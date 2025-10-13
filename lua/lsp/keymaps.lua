local M = {
	-- Configuration options
	config = {
		show_attach_notifications = false, -- Default: disabled
		show_server_notifications = false, -- Default: disabled (start/stop/restart)
	},
}

--- Helper function to send notifications based on configuration
local function lsp_notify(message, level, notification_type, opts)
	opts = opts or { title = "LSP" }

	-- Always show errors
	if level == vim.log.levels.ERROR then
		vim.notify(message, level, opts)
		return
	end

	-- Check notification type
	if notification_type == "attach" and not M.config.show_attach_notifications then
		return
	end

	if notification_type == "server" and not M.config.show_server_notifications then
		return
	end

	vim.notify(message, level, opts)
end

--- Configure LSP keymaps options
--- @param opts table Configuration options
function M.configure(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

--- Helper function to create keymap with consistent options
--- @param mode string|table Key modes
--- @param lhs string Key combination
--- @param rhs string|function Key action
--- @param desc string Description for the keymap
--- @param bufnr number Buffer number
--- @param additional_opts? table Additional options
local function map(mode, lhs, rhs, desc, bufnr, additional_opts)
	local opts = vim.tbl_extend("force", {
		buffer = bufnr,
		silent = true,
		desc = desc,
	}, additional_opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

--- Default keymap configuration (can be overridden)
M.keymaps = {
	-- Navigation
	{ "n", "gd", vim.lsp.buf.definition, "Go to definition" },
	{ "n", "gD", vim.lsp.buf.declaration, "Go to declaration" },
	{ "n", "gi", vim.lsp.buf.implementation, "Go to implementation" },
	{ "n", "gr", vim.lsp.buf.references, "Show references" },
	{ "n", "gt", vim.lsp.buf.type_definition, "Go to type definition" },

	-- Documentation
	{ "n", "K", vim.lsp.buf.hover, "Show hover documentation" },
	{ "n", "<C-k>", vim.lsp.buf.signature_help, "Show signature help" },

	-- Code actions and refactoring
	{ { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code actions" },
	{ "n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol" },

	-- Diagnostics
	{ "n", "[d", vim.diagnostic.goto_prev, "Go to previous diagnostic" },
	{ "n", "]d", vim.diagnostic.goto_next, "Go to next diagnostic" },
	{ "n", "<leader>e", vim.diagnostic.open_float, "Show line diagnostics" },

	-- Workspace management
	{ "n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder" },
	{ "n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder" },
	{
		"n",
		"<leader>wl",
		function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end,
		"List workspace folders",
	},

	-- Document symbols
	{ "n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols" },
	{ "n", "<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace symbols" },
}

--- Configure keymap overrides
--- @param overrides table Table of keymap overrides
function M.configure_keymaps(overrides)
	-- Allow users to disable keymaps by setting them to false
	-- Or override individual keymaps completely
	for key, override in pairs(overrides or {}) do
		if override == false then
			-- Remove keymap by setting it to false
			for i, keymap in ipairs(M.keymaps) do
				if keymap[2] == key then -- match by key combination
					table.remove(M.keymaps, i)
					break
				end
			end
		elseif type(override) == "table" and #override >= 4 then
			-- Replace existing keymap or add new one
			local found = false
			for i, keymap in ipairs(M.keymaps) do
				if keymap[2] == key then -- match by key combination
					M.keymaps[i] = override
					found = true
					break
				end
			end
			if not found then
				table.insert(M.keymaps, override)
			end
		end
	end
end

--- Setup LSP keymaps for a buffer
--- @param client vim.lsp.Client The LSP client
--- @param bufnr number The buffer number
function M.setup_buffer_keymaps(client, bufnr)
	-- Setup basic keymaps from configuration
	for _, keymap in ipairs(M.keymaps) do
		local mode, lhs, rhs, desc = keymap[1], keymap[2], keymap[3], keymap[4]
		map(mode, lhs, rhs, desc, bufnr)
	end

	-- Setup formatting keymaps (conditional on server capabilities)
	local function setup_formatting_keymap(mode, method, desc)
		if not client or not client.supports_method(method) then
			return
		end

		map(mode, "<leader>f", function()
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			local formatting_clients = vim.tbl_filter(function(c)
				return c.supports_method(method)
			end, clients)

			if #formatting_clients == 0 then
				lsp_notify(
					string.format("No LSP client supports %s", method),
					vim.log.levels.WARN,
					"server",
					{ title = "LSP" }
				)
				return
			end

			vim.lsp.buf.format({
				async = true,
				bufnr = bufnr,
				filter = function(c)
					return c.supports_method(method)
				end,
			})
		end, desc, bufnr)
	end

	-- Setup formatting keymaps
	setup_formatting_keymap("n", "textDocument/formatting", "Format document")
	setup_formatting_keymap("v", "textDocument/rangeFormatting", "Format range")

	-- Setup inlay hints (conditional on server capabilities)
	if client and client.supports_method("textDocument/inlayHint") then
		map("n", "<leader>ih", function()
			local current_state = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
			vim.lsp.inlay_hint.enable(not current_state, { bufnr = bufnr })
		end, "Toggle inlay hints", bufnr)
	end
end

function M.setup_user_commands()
	-- LSP server management commands
	vim.api.nvim_create_user_command("LspInfo", function()
		vim.cmd("checkhealth lsp")
	end, {
		desc = "Show LSP information",
	})

	vim.api.nvim_create_user_command("LspStart", function(opts)
		local server_name = opts.args
		if server_name == "" then
			lsp_notify("Please specify a server name", vim.log.levels.ERROR, "server", { title = "LSP" })
			return
		end

		local config = require("lsp.config")
		if config.enable_server(server_name) then
			lsp_notify(
				string.format("Started LSP server: %s", server_name),
				vim.log.levels.INFO,
				"server",
				{ title = "LSP" }
			)
		else
			lsp_notify(
				string.format("Failed to start LSP server: %s", server_name),
				vim.log.levels.ERROR,
				"server",
				{ title = "LSP" }
			)
		end
	end, {
		desc = "Start an LSP server",
		nargs = 1,
		complete = function()
			-- Return list of available servers (common ones)
			return {
				"lua_ls",
				"pyright",
				"ts_ls",
				"gopls",
				"rust_analyzer",
				"html",
				"cssls",
				"bashls",
				"dockerls",
				"jsonls",
			}
		end,
	})

	vim.api.nvim_create_user_command("LspStop", function(opts)
		local server_name = opts.args
		if server_name == "" then
			lsp_notify("Please specify a server name", vim.log.levels.ERROR, "server", { title = "LSP" })
			return
		end

		local clients = vim.lsp.get_clients({ name = server_name })
		if #clients == 0 then
			lsp_notify(
				string.format("No running LSP server found: %s", server_name),
				vim.log.levels.WARN,
				"server",
				{ title = "LSP" }
			)
			return
		end

		for _, client in ipairs(clients) do
			client.stop()
		end
		lsp_notify(
			string.format("Stopped LSP server: %s", server_name),
			vim.log.levels.INFO,
			"server",
			{ title = "LSP" }
		)
	end, {
		desc = "Stop an LSP server",
		nargs = 1,
		complete = function()
			-- Return list of running servers
			local servers = {}
			for _, client in ipairs(vim.lsp.get_clients()) do
				table.insert(servers, client.name)
			end
			return servers
		end,
	})

	vim.api.nvim_create_user_command("LspRestart", function(opts)
		local server_name = opts.args
		if server_name == "" then
			-- Restart all servers for current buffer
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			if #clients == 0 then
				lsp_notify(
					"No LSP clients attached to current buffer",
					vim.log.levels.WARN,
					"server",
					{ title = "LSP" }
				)
				return
			end

			for _, client in ipairs(clients) do
				local name = client.name
				client.stop()
				vim.defer_fn(function()
					vim.cmd(string.format("LspStart %s", name))
				end, 1000)
			end
			lsp_notify(
				"Restarting all LSP servers for current buffer",
				vim.log.levels.INFO,
				"server",
				{ title = "LSP" }
			)
		else
			-- Restart specific server
			vim.cmd(string.format("LspStop %s", server_name))
			vim.defer_fn(function()
				vim.cmd(string.format("LspStart %s", server_name))
			end, 1000)
			lsp_notify(
				string.format("Restarting LSP server: %s", server_name),
				vim.log.levels.INFO,
				"server",
				{ title = "LSP" }
			)
		end
	end, {
		desc = "Restart LSP server(s)",
		nargs = "?",
		complete = function()
			-- Return list of running servers
			local servers = {}
			for _, client in ipairs(vim.lsp.get_clients()) do
				table.insert(servers, client.name)
			end
			return servers
		end,
	})

	-- Diagnostic commands
	vim.api.nvim_create_user_command("LspDiagnostics", function()
		vim.diagnostic.setqflist()
	end, {
		desc = "Show all diagnostics in quickfix",
	})

	vim.api.nvim_create_user_command("LspDiagnosticsBuffer", function()
		vim.diagnostic.setloclist()
	end, {
		desc = "Show buffer diagnostics in location list",
	})

	-- Toggle LSP attach notifications
	vim.api.nvim_create_user_command("LspToggleAttachNotifications", function()
		M.config.show_attach_notifications = not M.config.show_attach_notifications
		local status = M.config.show_attach_notifications and "enabled" or "disabled"
		vim.notify(string.format("LSP attach/detach notifications %s", status), vim.log.levels.INFO, { title = "LSP" })
	end, {
		desc = "Toggle LSP attach/detach notifications",
	})

	-- Toggle LSP server notifications
	vim.api.nvim_create_user_command("LspToggleServerNotifications", function()
		M.config.show_server_notifications = not M.config.show_server_notifications
		local status = M.config.show_server_notifications and "enabled" or "disabled"
		vim.notify(
			string.format("LSP server management notifications %s", status),
			vim.log.levels.INFO,
			{ title = "LSP" }
		)
	end, {
		desc = "Toggle LSP server management notifications",
	})

	-- Toggle config loaded messages
	vim.api.nvim_create_user_command("LspToggleConfigMessages", function()
		local notifications = require("lsp.notifications")
		local current_state = notifications.config.show_config_loaded_messages
		notifications.configure({
			show_config_loaded_messages = not current_state,
		})
		local status = (not current_state) and "enabled" or "disabled"
		vim.notify(string.format("LSP config loaded messages %s", status), vim.log.levels.INFO, { title = "LSP" })
	end, {
		desc = "Toggle LSP config loaded messages",
	})

	-- Toggle all non-error LSP notifications
	vim.api.nvim_create_user_command("LspToggleAllNotifications", function()
		local new_state = not (M.config.show_attach_notifications or M.config.show_server_notifications)
		M.config.show_attach_notifications = new_state
		M.config.show_server_notifications = new_state

		-- Also toggle config notifications
		local lsp_config = require("lsp.config")
		lsp_config.configure_notifications({
			errors_only = not new_state,
		})

		-- Also toggle config loaded messages
		local notifications = require("lsp.notifications")
		notifications.configure({
			show_config_loaded_messages = new_state,
		})

		local status = new_state and "enabled" or "disabled"
		vim.notify(
			string.format("All LSP notifications %s (errors always shown)", status),
			vim.log.levels.INFO,
			{ title = "LSP" }
		)
	end, {
		desc = "Toggle all LSP notifications (except errors)",
	})

	-- Format command
	vim.api.nvim_create_user_command("LspFormat", function(opts)
		local bufnr = vim.api.nvim_get_current_buf()
		local clients = vim.lsp.get_clients({ bufnr = bufnr })
		local formatting_clients = vim.tbl_filter(function(c)
			return c.supports_method("textDocument/formatting") or c.supports_method("textDocument/rangeFormatting")
		end, clients)

		if #formatting_clients == 0 then
			vim.notify("No LSP client supports formatting", vim.log.levels.WARN, { title = "LSP" })
			return
		end

		vim.lsp.buf.format({
			async = false,
			bufnr = bufnr,
			range = opts.range > 0 and {
				start = { opts.line1, 0 },
				["end"] = { opts.line2, 0 },
			} or nil,
			filter = function(c)
				return c.supports_method("textDocument/formatting") or c.supports_method("textDocument/rangeFormatting")
			end,
		})
	end, {
		desc = "Format current buffer with LSP",
		range = true,
	})
end

--- Setup LSP event handlers
function M.setup_event_handlers()
	-- Auto-setup keymaps when LSP attaches
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)
			local bufnr = event.buf

			M.setup_buffer_keymaps(client, bufnr)

			-- Optional: Show notification when LSP attaches
			lsp_notify(
				string.format("LSP attached: %s", client and client.name or "unknown"),
				vim.log.levels.INFO,
				"attach",
				{ title = "LSP" }
			)
		end,
	})

	-- Show notification when LSP detaches
	vim.api.nvim_create_autocmd("LspDetach", {
		group = vim.api.nvim_create_augroup("LspDetach", { clear = true }),
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)

			lsp_notify(
				string.format("LSP detached: %s", client and client.name or "unknown"),
				vim.log.levels.INFO,
				"attach",
				{ title = "LSP" }
			)
		end,
	})
end

--- Initialize all keymaps and commands
function M.setup()
	M.setup_user_commands()
	M.setup_event_handlers()
end

return M
