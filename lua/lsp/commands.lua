local M = {}

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

		print("=== Loaded LSP Configurations ===")
		for name, config in pairs(configs) do
			print(string.format("\n[%s]", name))

			if config.lsp then
				print("  LSP servers:")
				for server, _ in pairs(config.lsp) do
					print(string.format("    - %s", server))
				end
			end

			if config.format then
				print("  Formatters:")
				for ft, formatters in pairs(config.format) do
					print(string.format("    %s: %s", ft, table.concat(formatters, ", ")))
				end
			end

			if config.lint then
				print("  Linters:")
				for ft, linters in pairs(config.lint) do
					print(string.format("    %s: %s", ft, table.concat(linters, ", ")))
				end
			end

			if config.lint_config then
				print("  Custom linter configs:")
				for linter_name, _ in pairs(config.lint_config) do
					print(string.format("    - %s (custom config)", linter_name))
				end
			end
		end

		print(string.format("\nTotal configurations loaded: %d", vim.tbl_count(configs)))
	end, {
		desc = "Show all loaded LSP configurations",
	})

	-- Show available tools
	vim.api.nvim_create_user_command("LspShowTools", function()
		local loader = require("lsp.loader")
		local tools = loader.get_tools()

		print("=== Available Tools ===")
		for tool_type, tool_list in pairs(tools) do
			if #tool_list > 0 then
				print(string.format("\n%s (%d):", tool_type:upper(), #tool_list))
				for _, tool in ipairs(tool_list) do
					print(string.format("  - %s", tool))
				end
			end
		end
	end, {
		desc = "Show all available tools by type",
	})

	-- Install missing tools
	vim.api.nvim_create_user_command("LspInstallMissing", function(opts)
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
		desc = "Install missing tools",
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

		print(string.format("=== Configuration for %s ===", filetype))

		-- Show LSP servers
		local lsp_config = loader.get_config_data("lsp", filetype)
		if not vim.tbl_isempty(lsp_config) then
			print("LSP servers:")
			for ft, servers in pairs(lsp_config) do
				if type(servers) == "table" then
					for server, _ in pairs(servers) do
						print(string.format("  - %s", server))
					end
				end
			end
		end

		-- Show formatters
		local format_config = loader.get_config_data("format", filetype)
		if not vim.tbl_isempty(format_config) then
			print("Formatters:")
			for ft, formatters in pairs(format_config) do
				if type(formatters) == "table" then
					print(string.format("  %s: %s", ft, table.concat(formatters, ", ")))
				end
			end
		end

		-- Show linters
		local lint_config = loader.get_config_data("lint", filetype)
		if not vim.tbl_isempty(lint_config) then
			print("Linters:")
			for ft, linters in pairs(lint_config) do
				if type(linters) == "table" then
					print(string.format("  %s: %s", ft, table.concat(linters, ", ")))
				end
			end
		end

		if vim.tbl_isempty(lsp_config) and vim.tbl_isempty(format_config) and vim.tbl_isempty(lint_config) then
			print("No configuration found for filetype: " .. filetype)
		end
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
	vim.api.nvim_create_user_command("LspShowCustomLinters", function(opts)
		local loader = require("lsp.loader")
		local custom_configs = loader.get_custom_linter_configs()

		if vim.tbl_isempty(custom_configs) then
			print("No custom linter configurations found.")
			return
		end

		print("=== Custom Linter Configurations ===")
		for linter_name, config in pairs(custom_configs) do
			print(string.format("\n[%s]", linter_name))

			if config.cmd then
				print(string.format("  Command: %s", config.cmd))
			end

			if config.args then
				print(string.format("  Args: %s", table.concat(config.args, " ")))
			end

			if config.stdin ~= nil then
				print(string.format("  Uses stdin: %s", tostring(config.stdin)))
			end

			if config.stream then
				print(string.format("  Stream: %s", config.stream))
			end

			if config.ignore_exitcode ~= nil then
				print(string.format("  Ignore exit code: %s", tostring(config.ignore_exitcode)))
			end

			if config.parser then
				print("  Has custom parser: yes")
			end
		end

		print(string.format("\nTotal custom linter configurations: %d", vim.tbl_count(custom_configs)))
	end, {
		desc = "Show detailed custom linter configurations",
	})
end

return M
