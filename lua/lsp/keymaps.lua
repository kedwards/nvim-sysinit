local M = {}

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

--- Helper function to create keymap
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
M.keymaps = {}

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
		if not client or not client:supports_method(method) then
			return
		end

		map(mode, "<leader>f", function()
			local clients = vim.lsp.get_clients({ bufnr = bufnr })
			local formatting_clients = vim.tbl_filter(function(c)
				return c.supports_method(method)
			end, clients)

			if #formatting_clients == 0 then
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

	-- vim.lsp.document_color.enable(true, bufnr)
	if client:supports_method("textDocument/documentColor") then
		map({ "n", "x" }, "grc", function()
			vim.lsp.document_color.color_presentation()
		end, "Colour document via LSP", bufnr)
	end

	if client:supports_method("textDocument/definition") then
		map("n", "gd", function()
			vim.lsp.buf.definition()
		end, "Go to definition", bufnr)
		map("n", "gD", function()
			vim.lsp.buf.declaration()
		end, "Peek definition", bufnr)
	end

	if client:supports_method("textDocument/documentHighlight") then
		local under_cursor_highlights_group = vim.api.nvim_create_augroup("cursor_highlights", { clear = false })
		vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
			group = under_cursor_highlights_group,
			desc = "Highlight references under the cursor",
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
			group = under_cursor_highlights_group,
			desc = "Clear highlight references",
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
		})
	end

	if client:supports_method("textDocument/inlayHint") then
		local inlay_hints_group = vim.api.nvim_create_augroup("toggle_inlay_hints", { clear = false })

		if vim.g.inlay_hints then
			-- Initial inlay hint display.
			-- Idk why but without the delay inlay hints aren't displayed at the very start.
			vim.defer_fn(function()
				local mode = vim.api.nvim_get_mode().mode
				vim.lsp.inlay_hint.enable(mode == "n" or mode == "v", { bufnr = bufnr })
			end, 500)
		end

		vim.api.nvim_create_autocmd("InsertEnter", {
			group = inlay_hints_group,
			desc = "Enable inlay hints",
			buffer = bufnr,
			callback = function()
				if vim.g.inlay_hints then
					vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
				end
			end,
		})

		vim.api.nvim_create_autocmd("InsertLeave", {
			group = inlay_hints_group,
			desc = "Disable inlay hints",
			buffer = bufnr,
			callback = function()
				if vim.g.inlay_hints then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end,
		})
	end
end

function M.setup_user_commands()
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

	-- Set up LSP servers.
	vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
		once = true,
		callback = function()
			local server_configs = vim.iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
				:map(function(file)
					return vim.fn.fnamemodify(file, ":t:r")
				end)
				:totable()

			-- Read all .lua files from config directory
			local all_files = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/lsp/configs") or {}
			local files = {}
			for _, file in ipairs(all_files) do
				if file:match("%.lua$") then
					if not vim.tbl_contains(files, file) then
						table.insert(files, file)
					end
				end
			end

			for _, file in ipairs(files or {}) do
				local name = file:gsub("%.lua$", "")
				if not vim.tbl_contains(server_configs, name) then
					table.insert(server_configs, name)
				end
			end

			vim.notify("Setting up LSP servers... " .. vim.inspect(server_configs), vim.log.levels.INFO)
			vim.lsp.enable(server_configs)
		end,
	})
end

--- Initialize all keymaps and commands
function M.setup()
	M.setup_user_commands()
	M.setup_event_handlers()
end

return M
