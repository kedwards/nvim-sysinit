local M = {}

-- Cache for better performance
local _cached_configs = nil
local _cached_tools = nil
local _modules = {}

-- Configuration directory
M.config_dir = vim.fn.stdpath("config") .. "/lua/lsp/configs"

--- Lazy module loading with caching
--- @param name string Module name to require
--- @return any The required module
function M.lazy_require(name)
	if not _modules[name] then
		local ok, module = pcall(require, name)
		if ok then
			_modules[name] = module
		else
			vim.notify("Failed to load module: " .. name, vim.log.levels.ERROR, { title = "LSP Loader" })
			return nil
		end
	end
	return _modules[name]
end

--- Read all configuration files from the configs directory
--- @return table<string, table> Map of config name to config data
function M.read_configs()
	if _cached_configs then
		return _cached_configs
	end

	local configs = {}
	local config_path = M.config_dir

	-- Check if config directory exists
	if vim.fn.isdirectory(config_path) == 0 then
		vim.notify("Config directory not found: " .. config_path, vim.log.levels.WARN, { title = "LSP Loader" })
		return {}
	end

	-- Read all .lua files from config directory
	local all_files = vim.fn.readdir(config_path) or {}
	local files = {}
	for _, file in ipairs(all_files) do
		if file:match("%.lua$") then
			table.insert(files, file)
		end
	end

	for _, file in ipairs(files or {}) do
		local name = file:gsub("%.lua$", "")
		local module_path = "lsp.configs." .. name

		local ok, config = pcall(require, module_path)
		if ok and type(config) == "table" then
			configs[name] = config
		else
			vim.notify("Failed to load config: " .. module_path, vim.log.levels.WARN, { title = "LSP Loader" })
		end
	end

	_cached_configs = configs
	return configs
end

--- Extract all tools from configs by type
--- @param config_type? string Type of tools to extract ("lsp", "format", "lint", "dap")
--- @return table<string, string[]> Tools by type or specific type
function M.get_tools(config_type)
	if _cached_tools then
		return config_type and _cached_tools[config_type] or _cached_tools
	end

	local configs = M.read_configs()

	-- vim.notify(vim.inspect(configs), vim.log.levels.DEBUG, { title = "LSP Loader" })

	local tools = {
		lsp = {},
		format = {},
		lint = {},
		debug = {},
	}

	local seen = {
		lsp = {},
		format = {},
		lint = {},
		debug = {},
	}

	for _, config in pairs(configs) do
		-- Extract LSP servers
		if config.lsp then
			for key, conf in pairs(config.lsp) do
				local server_name = conf.name or key
				if not seen.lsp[server_name] then
					table.insert(tools.lsp, server_name)
					seen.lsp[server_name] = true
				end
			end
		end

		-- Extract formatters
		if config.format then
			for _, formatters in pairs(config.format) do
				if type(formatters) == "table" then
					for _, formatter in ipairs(formatters) do
						if not seen.format[formatter] then
							table.insert(tools.format, formatter)
							seen.format[formatter] = true
						end
					end
				end
			end
		end

		-- Extract linters
		if config.lint then
			for _, linters in pairs(config.lint) do
				if type(linters) == "table" then
					for _, linter in ipairs(linters) do
						if not seen.lint[linter] then
							table.insert(tools.lint, linter)
							seen.lint[linter] = true
						end
					end
				end
			end
		end

		-- Extract linters from custom lint_config
		if config.lint_config then
			for linter_name, _ in pairs(config.lint_config) do
				if not seen.lint[linter_name] then
					table.insert(tools.lint, linter_name)
					seen.lint[linter_name] = true
				end
			end
		end

		-- Extract DAP adapters
		if config.debug and config.debug.adapters then
			for adapter_name, _ in pairs(config.debug.adapters) do
				if not seen.debug[adapter_name] then
					table.insert(tools.debug, adapter_name)
					seen.debug[adapter_name] = true
				end
			end
		end
	end

	_cached_tools = tools
	return config_type and tools[config_type] or tools
end

--- Get configuration data for a specific type
--- @param key string Configuration key ("lsp", "format", "lint", "dap")
--- @param filetype? string Optional filetype filter
--- @return table Configuration data
function M.get_config_data(key, filetype)
	local configs = M.read_configs()
	local result = {}

	for _, config in pairs(configs) do
		if config[key] then
			if filetype then
				-- Return specific filetype config
				if config[key][filetype] then
					result[filetype] = config[key][filetype]
				end
			else
				-- Return all configs for this key
				for ft, data in pairs(config[key]) do
					result[ft] = data
				end
			end
		end
	end

	return result
end

--- Get custom linter configurations
--- @param linter_name? string Optional linter name filter
--- @return table Custom linter configurations
function M.get_custom_linter_configs(linter_name)
	local configs = M.read_configs()
	local result = {}

	for _, config in pairs(configs) do
		if config.lint_config then
			if linter_name then
				-- Return specific linter config
				if config.lint_config[linter_name] then
					result[linter_name] = config.lint_config[linter_name]
				end
			else
				-- Return all custom linter configs
				for name, linter_config in pairs(config.lint_config) do
					result[name] = linter_config
				end
			end
		end
	end

	return result
end

--- Setup LSP servers using modern vim.lsp.config API
--- @param capabilities? table LSP capabilities
--- @return table<string, boolean> Setup results
function M.setup_lsp_servers(capabilities)
	local configs = M.read_configs()
	local results = {}

	-- Get default capabilities if not provided
	if not capabilities then
		local caps_module = M.lazy_require("lsp.capabilities")
		capabilities = caps_module and caps_module.get_capabilities() or vim.lsp.protocol.make_client_capabilities()
	end

	-- Setup each LSP server found in configs
	for _, config in pairs(configs) do
		if config.lsp then
			for server_name, server_config in pairs(config.lsp) do
				local setup_config = vim.tbl_deep_extend("force", {
					capabilities = capabilities,
				}, server_config or {})

				-- Add default on_attach if not provided
				if not setup_config.on_attach then
					setup_config.on_attach = function(client, bufnr)
						local keymaps = M.lazy_require("lsp.keymaps")
						if keymaps then
							keymaps.setup_buffer_keymaps(client, bufnr)
						end
					end
				end

				-- Setup using modern vim.lsp.config API
				local ok, err = pcall(function()
					vim.lsp.config(server_name, setup_config)
				end)

				if ok then
					results[server_name] = true

					-- Enable the server
					local enable_ok = pcall(vim.lsp.enable, server_name)
					if not enable_ok then
						vim.notify(
							"Failed to enable LSP server: " .. server_name,
							vim.log.levels.WARN,
							{ title = "LSP Loader" }
						)
					end
				else
					results[server_name] = false
					vim.notify(
						"Failed to setup LSP server: " .. server_name .. " - " .. tostring(err),
						vim.log.levels.ERROR,
						{ title = "LSP Loader" }
					)
				end
			end
		end
	end

	return results
end

--- Setup DAP
--- @return boolean Success status
function M.setup_debugging()
	local configs = M.read_configs()
	local dap = M.lazy_require("dap")

	if not dap then
		vim.notify("nvim-dap not available", vim.log.levels.WARN, { title = "LSP Loader" })
		return false
	end

	for _, config in pairs(configs) do
		if config.debug then
			-- Register adapters
			for name, adapter in pairs(config.debug.adapters or {}) do
				if type(adapter) == "function" or type(adapter) == "table" then
					dap.adapters[name] = adapter
				else
					vim.notify(
						("Invalid DAP adapter for %s: %s"):format(name, vim.inspect(adapter)),
						vim.log.levels.WARN
					)
				end
			end

			-- Register configurations
			for ft, setups in pairs(config.debug.configurations or {}) do
				dap.configurations[ft] = dap.configurations[ft] or {}
				-- append rather than overwrite
				for _, setup in ipairs(setups) do
					table.insert(dap.configurations[ft], setup)
				end
			end
		end
	end

	return true
end

--- Setup formatting with conform.nvim
--- @return boolean Success status
function M.setup_formatting()
	local conform = M.lazy_require("conform")
	if not conform then
		vim.notify("conform.nvim not available", vim.log.levels.WARN, { title = "LSP Loader" })
		return false
	end

	local formatters_by_ft = M.get_config_data("format")

	conform.setup({
		formatters_by_ft = formatters_by_ft,
		format_on_save = function(bufnr)
			-- Check if formatting is enabled for this buffer
			local disable_filetypes = { "sql" } -- Add filetypes to disable
			local filetype = vim.bo[bufnr].filetype

			if vim.tbl_contains(disable_filetypes, filetype) then
				return nil
			end

			return {
				timeout_ms = 500,
				lsp_fallback = true,
			}
		end,
	})

	return true
end

--- Apply custom linter configurations from config files
--- @param lint table The nvim-lint module
function M.apply_custom_linter_configs(lint)
	local configs = M.read_configs()

	for _, config in pairs(configs) do
		if config.lint_config then
			for linter_name, linter_config in pairs(config.lint_config) do
				-- Apply the custom configuration to the linter
				if lint.linters[linter_name] then
					-- Merge with existing linter config
					lint.linters[linter_name] = vim.tbl_deep_extend("force", lint.linters[linter_name], linter_config)
				else
					-- Create new linter config
					lint.linters[linter_name] = linter_config
				end
			end
		end
	end
end

--- Setup linting with nvim-lint
--- @return boolean Success status
function M.setup_linting()
	local lint = M.lazy_require("lint")
	if not lint then
		vim.notify("nvim-lint not available", vim.log.levels.WARN, { title = "LSP Loader" })
		return false
	end

	local linters_by_ft = M.get_config_data("lint")
	lint.linters_by_ft = linters_by_ft

	-- Apply custom linter configurations
	M.apply_custom_linter_configs(lint)

	-- Setup linting autocmd
	vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
		group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
		callback = function()
			lint.try_lint()
		end,
	})

	return true
end

local mason_name_map = {
	-- Special cases where tool name != mason name
	ruff_format = "ruff", -- ruff handles both linting and formatting
}

--- Get Mason package name for a tool
--- @param tool_name string The tool name from config
--- @return string The Mason package name
local function get_mason_name(tool_name)
	return mason_name_map[tool_name] or tool_name
end

--- Install tools using Mason with proper registry initialization
--- @param tool_types? string[] Types of tools to install ("lsp", "format", "lint", "dap")
--- @return table<string, boolean> Installation results
function M.ensure_installed(tool_types)
	tool_types = tool_types or { "lsp", "format", "lint", "dap" }

	local mason_ok, _ = pcall(require, "mason")
	if not mason_ok then
		vim.notify("Mason not available", vim.log.levels.ERROR, { title = "LSP Loader" })
		return {}
	end

	local mason_registry = M.lazy_require("mason-registry")
	if not mason_registry then
		vim.notify("Mason registry not available", vim.log.levels.ERROR, { title = "LSP Loader" })
		return {}
	end

	-- Wait for registry to be loaded if needed
	if not mason_registry.is_installed or vim.tbl_count(mason_registry.get_all_package_names()) == 0 then
		-- Use vim.wait to wait for registry to be ready (reduced timeout)
		local ok = vim.wait(5000, function()
			return vim.tbl_count(mason_registry.get_all_package_names()) > 0
		end, 100)

		if not ok then
			vim.notify(
				"Mason registry failed to initialize within 5 seconds. Tools will not be auto-installed. Use LspInstallTools to install them manually.",
				vim.log.levels.WARN,
				{ title = "Mason" }
			)
			return {}
		end
	end

	local results = {}
	local tools = M.get_tools()

	-- Collect all tools to install
	local to_install = {}
	for _, tool_type in ipairs(tool_types) do
		if tools[tool_type] then
			for _, tool in ipairs(tools[tool_type]) do
				table.insert(to_install, tool)
			end
		end
	end

	-- Install each tool
	for _, tool in ipairs(to_install) do
		local mason_name = get_mason_name(tool)
		if mason_registry.has_package(mason_name) then
			if not mason_registry.is_installed(mason_name) then
				local package = mason_registry.get_package(mason_name)
				vim.notify(
					"Installing: " .. mason_name .. " (" .. tool .. ")",
					vim.log.levels.INFO,
					{ title = "Mason" }
				)

				local install_ok, install_err = pcall(function()
					package:install()
				end)

				results[tool] = install_ok
				if not install_ok then
					vim.notify(
						"Failed to install: " .. mason_name .. " (" .. tool .. ") - " .. tostring(install_err),
						vim.log.levels.ERROR,
						{ title = "Mason" }
					)
				end
			else
				results[tool] = true
			end
		else
			vim.notify(
				"Tool not found in Mason registry: " .. tool .. " (tried: " .. mason_name .. ")",
				vim.log.levels.WARN,
				{ title = "Mason" }
			)
			results[tool] = false
		end
	end

	return results
end

--- Clear all caches (useful for config reloading)
function M.clear_cache()
	_cached_configs = nil
	_cached_tools = nil
	_modules = {}
end

--- Reload all configurations
function M.reload()
	M.clear_cache()
	local configs = M.read_configs()
	vim.notify(
		"Reloaded " .. vim.tbl_count(configs) .. " configurations",
		vim.log.levels.INFO,
		{ title = "LSP Loader" }
	)
	return configs
end

--- Setup everything (main entry point)
--- @param opts? table Configuration options
function M.setup(opts)
	opts = opts or {}

	-- Setup Mason
	local mason_ok, mason = pcall(require, "mason")
	if mason_ok then
		mason.setup(vim.tbl_deep_extend("force", {
			-- default Mason configuration
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		}, opts.mason or {}))

		-- Install tools asynchronously
		if opts.ensure_installed ~= false then
			vim.defer_fn(function()
				M.ensure_installed(opts.tool_types)
			end, 1000)
		end
	end

	-- Setup LSP servers
	M.setup_lsp_servers(opts.capabilities)

	-- Setup formatting
	if opts.formatting ~= false then
		M.setup_formatting()
	end

	-- Setup linting
	if opts.linting ~= false then
		M.setup_linting()
	end

	-- Setup dap
	if opts.debugging ~= false then
		M.setup_debugging()
	end
end

return M
