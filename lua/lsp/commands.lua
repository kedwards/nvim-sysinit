local M = {}

--- Display content in a floating window
--- @param lines string[] Lines to display
--- @param opts? {title: string, max_width: number, max_height: number}
local function show_in_float(lines, opts)
	opts = opts or {}
	local title = opts.title or "Info"
	local max_width = opts.max_width or math.floor(vim.o.columns * 0.7)
	local max_height = opts.max_height or math.floor(vim.o.lines * 0.8)

	-- Calculate optimal width based on content
	local content_width = 0
	for _, line in ipairs(lines) do
		content_width = math.max(content_width, vim.fn.strdisplaywidth(line))
	end

	-- Add padding for border and some breathing room
	local width = math.min(content_width + 4, max_width)
	width = math.max(width, vim.fn.strdisplaywidth(title) + 6) -- Ensure title fits

	-- Calculate height
	local height = math.min(#lines, max_height)

	-- Center the window
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "lspinfo"

	-- Create window
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	})

	-- Set keymaps for closing
	local close_keys = { "q", "<Esc>" }
	for _, key in ipairs(close_keys) do
		vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, silent = true })
	end

	-- Enable syntax highlighting
	vim.api.nvim_buf_call(buf, function()
		vim.cmd([[
			syntax match LspInfoTitle /^===.*===$/ 
			syntax match LspInfoSection /^\[.*\]$/
			syntax match LspInfoKey /^\s*\w\+:/
			syntax match LspInfoBullet /^\s*-/
		
			hi def link LspInfoTitle Title
			hi def link LspInfoSection Function
			hi def link LspInfoKey Identifier
			hi def link LspInfoBullet Special
		]])
	end)

	return buf, win
end

function M.setup()
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

	-- Reload LSP configurations
	vim.api.nvim_create_user_command("LspReloadConfigs", function()
		local loader = require("lsp.loader")
		loader.reload()
	end, {
		desc = "Reload all LSP configurations",
	})

	-- Show loaded configurations
	vim.api.nvim_create_user_command("LspShowConfigs", function()
		local loader = require("lsp.loader")
		local configs = loader.read_configs()

		-- local lines = { "=== Loaded LSP Configurations ===" }
		local lines = {}
		for name, config in pairs(configs) do
			table.insert(lines, string.format("[%s]", name))

			if config.lsp then
				table.insert(lines, "  LSP servers:")
				for server, _ in pairs(config.lsp) do
					table.insert(lines, string.format("    - %s", server))
				end
			end

			if config.format then
				table.insert(lines, "  Formatters:")
				for ft, formatters in pairs(config.format) do
					table.insert(lines, string.format("    %s: %s", ft, table.concat(formatters, ", ")))
				end
			end

			if config.lint then
				table.insert(lines, "  Linters:")
				for ft, linters in pairs(config.lint) do
					table.insert(lines, string.format("    %s: %s", ft, table.concat(linters, ", ")))
				end
			end

			if config.lint_config then
				table.insert(lines, "  Custom linter configs:")
				for linter_name, _ in pairs(config.lint_config) do
					table.insert(lines, string.format("    - %s (custom config)", linter_name))
				end
			end
			table.insert(lines, "")
		end

		table.insert(lines, string.format("Total configurations loaded: %d", vim.tbl_count(configs)))
		show_in_float(lines, { title = "LSP Configurations" })
	end, {
		desc = "Show all loaded LSP configurations",
	})

	-- Show available tools
	vim.api.nvim_create_user_command("LspShowTools", function()
		local loader = require("lsp.loader")
		local tools = loader.get_tools()

		-- local lines = { "=== Available Tools ===" }
		local lines = {}
		for tool_type, tool_list in pairs(tools) do
			if #tool_list > 0 then
				table.insert(lines, string.format("%s (%d):", tool_type:upper(), #tool_list))
				for _, tool in ipairs(tool_list) do
					table.insert(lines, string.format("  - %s", tool))
				end
				table.insert(lines, "")
			end
		end
		show_in_float(lines, { title = "Available Tools" })
	end, {
		desc = "Show all available tools by type",
	})

	-- Install tools
	vim.api.nvim_create_user_command("LspInstallTools", function(opts)
		local loader = require("lsp.loader")
		local tool_types = opts.fargs

		if #tool_types == 0 then
			tool_types = { "lsp", "format", "lint", "dap" }
		end

		local results = loader.ensure_installed(tool_types)

		local installed = {}
		local failed = {}

		for tool, success in pairs(results) do
			if success then
				table.insert(installed, tool)
			else
				table.insert(failed, tool)
			end
		end

		if #installed > 0 then
			vim.notify(
				string.format("Installed tools: %s", table.concat(installed, ", ")),
				vim.log.levels.INFO,
				{ title = "Mason" }
			)
		end

		if #failed > 0 then
			vim.notify(
				string.format("Failed to install: %s", table.concat(failed, ", ")),
				vim.log.levels.WARN,
				{ title = "Mason" }
			)
		end
	end, {
		desc = "Install LSP tools",
		nargs = "*",
		complete = function()
			return { "lsp", "format", "lint", "dap" }
		end,
	})

	-- Clear cache
	vim.api.nvim_create_user_command("LspClearCache", function()
		local loader = require("lsp.loader")
		loader.clear_cache()
		vim.notify("LSP cache cleared", vim.log.levels.INFO, { title = "LSP Loader" })
	end, {
		desc = "Clear LSP loader cache",
	})

	-- Show config for specific filetype
	vim.api.nvim_create_user_command("LspShowFiletypeConfig", function(opts)
		local filetype = opts.args
		if filetype == "" then
			filetype = vim.bo.filetype
		end

		local loader = require("lsp.loader")

		-- local lines = { string.format("=== Configuration for %s ===", filetype), "" }
		local lines = {}

		-- Show LSP servers
		local lsp_config = loader.get_config_data("lsp", filetype)
		if not vim.tbl_isempty(lsp_config) then
			table.insert(lines, "LSP servers:")
			for _, servers in pairs(lsp_config) do
				if type(servers) == "table" then
					for server, _ in pairs(servers) do
						table.insert(lines, string.format("  - %s", server))
					end
				end
			end
			table.insert(lines, "")
		end

		-- Show formatters
		local format_config = loader.get_config_data("format", filetype)
		if not vim.tbl_isempty(format_config) then
			table.insert(lines, "Formatters:")
			for ft, formatters in pairs(format_config) do
				if type(formatters) == "table" then
					table.insert(lines, string.format("  %s: %s", ft, table.concat(formatters, ", ")))
				end
			end
			table.insert(lines, "")
		end

		-- Show linters
		local lint_config = loader.get_config_data("lint", filetype)
		if not vim.tbl_isempty(lint_config) then
			table.insert(lines, "Linters:")
			for ft, linters in pairs(lint_config) do
				if type(linters) == "table" then
					table.insert(lines, string.format("  %s: %s", ft, table.concat(linters, ", ")))
				end
			end
		end

		if vim.tbl_isempty(lsp_config) and vim.tbl_isempty(format_config) and vim.tbl_isempty(lint_config) then
			table.insert(lines, "No configuration found for filetype: " .. filetype)
		end

		show_in_float(lines, { title = "Filetype Config: " .. filetype })
	end, {
		desc = "Show configuration for specific filetype",
		nargs = "?",
		complete = function()
			-- Return common filetypes
			return {
				"lua",
				"python",
				"go",
				"typescript",
				"javascript",
				"html",
				"css",
				"json",
				"yaml",
				"markdown",
				"sh",
				"bash",
			}
		end,
	})

	-- Create new config template
	vim.api.nvim_create_user_command("LspNewConfig", function(opts)
		local name = opts.args
		if name == "" then
			vim.notify("Please provide a configuration name", vim.log.levels.ERROR, { title = "LSP Loader" })
			return
		end

		local config_path = vim.fn.stdpath("config") .. "/lua/lsp/configs/" .. name .. ".lua"

		if vim.fn.filereadable(config_path) == 1 then
			vim.notify("Configuration already exists: " .. name, vim.log.levels.WARN, { title = "LSP Loader" })
			return
		end

		local template = string.format(
			[[-- %s Language Configuration
    -- LSP, formatting, and linting setup for %s files

    return {
      -- LSP servers for %s
      lsp = {
        -- server_name = {
          --   settings = {
            --     -- server specific settings
            --   },
            -- },
          },

          -- Formatters for %s
          format = {
            -- %s = { "formatter_name" },
          },

          -- Linters for %s
          lint = {
            -- %s = { "linter_name" },
          },

          -- Custom linter configurations (optional)
          -- Use this when linters need special arguments or settings
          lint_config = {
            -- linter_name = {
              --   cmd = "linter_command",
              --   args = { "--arg1", "value1" },
              --   stdin = false,
              --   stream = "stdout",
              --   ignore_exitcode = false,
              --   parser = require("lint.parser").from_errorformat("%%f:%%l:%%c: %%m"),
              -- },
            },

            -- DAP configuration for %s debugging
            dap = {},
          }]],
			name:gsub("^%l", string.upper),
			name,
			name,
			name,
			name,
			name,
			name,
			name
		)

		vim.fn.writefile(vim.split(template, "\n"), config_path)
		vim.notify("Created new configuration: " .. config_path, vim.log.levels.INFO, { title = "LSP Loader" })

		-- Open the file for editing
		vim.cmd("edit " .. config_path)
	end, {
		desc = "Create new LSP configuration template",
		nargs = 1,
	})

	-- Show custom linter configurations
	vim.api.nvim_create_user_command("LspShowCustomLinters", function()
		local loader = require("lsp.loader")
		local custom_configs = loader.get_custom_linter_configs()

		if vim.tbl_isempty(custom_configs) then
			vim.notify("No custom linter configurations found.", vim.log.levels.INFO, { title = "LSP" })
			return
		end

		-- local lines = { "=== Custom Linter Configurations ===" }
		local lines = {}
		for linter_name, config in pairs(custom_configs) do
			-- table.insert(lines, "")
			table.insert(lines, string.format("[%s]", linter_name))

			if config.cmd then
				table.insert(lines, string.format("  Command: %s", config.cmd))
			end

			if config.args then
				table.insert(lines, string.format("  Args: %s", table.concat(config.args, " ")))
			end

			if config.stdin ~= nil then
				table.insert(lines, string.format("  Uses stdin: %s", tostring(config.stdin)))
			end

			if config.stream then
				table.insert(lines, string.format("  Stream: %s", config.stream))
			end

			if config.ignore_exitcode ~= nil then
				table.insert(lines, string.format("  Ignore exit code: %s", tostring(config.ignore_exitcode)))
			end

			if config.parser then
				table.insert(lines, "  Has custom parser: yes")
			end
		end

		table.insert(lines, "")
		table.insert(lines, string.format("Total custom linter configurations: %d", vim.tbl_count(custom_configs)))
		show_in_float(lines, { title = "Custom Linter Configurations" })
	end, {
		desc = "Show detailed custom linter configurations",
	})
end

return M
