-- Lua Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#lua_ls

return {
	-- LSP servers for Lua
	lsp = {
		lua_ls = {
			name = "lua-language-server",
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
						path = vim.list_extend(vim.split(package.path, ";"), {
							"lua/?.lua",
							"lua/?/init.lua",
						}),
					},
					diagnostics = {
						globals = {
							"vim", -- Neovim global
							"describe",
							"it", -- Busted testing globals
							"before_each",
							"after_each",
							"setup",
							"teardown",
							"pending",
							"finally",
						},
						disable = {
							"missing-fields", -- Too noisy for Neovim config
						},
						groupSeverity = {
							strong = "Warning",
							strict = "Warning",
						},
						groupFileStatus = {
							strong = "Opened",
							strict = "Opened",
							fallback = "Opened",
						},
					},
					workspace = {
						library = {
							vim.env.VIMRUNTIME,
							"${3rd}/luv/library",
							"${3rd}/busted/library",
							"${3rd}/luassert/library",
						},
						maxPreload = 100000,
						preloadFileSize = 10000,
						checkThirdParty = false,
					},
					completion = {
						callSnippet = "Replace",
						keywordSnippet = "Replace",
						displayContext = 5,
						workspaceWord = true,
						showWord = "Fallback",
					},
					semantic = {
						enable = true,
						variable = true,
						annotation = true,
						keyword = false, -- Let treesitter handle keywords
					},
					codelens = {
						enable = true,
					},
					hover = {
						enable = true,
						viewNumber = true,
						viewString = true,
						viewStringMax = 1000,
					},
					signatureHelp = {
						enable = true,
					},
					format = {
						enable = false, -- Use stylua instead
					},
					telemetry = {
						enable = false,
					},
					window = {
						progressBar = true,
						statusBar = true,
					},
					misc = {
						parameters = {
							"---@param ${1:param} ${2:type} ${3:description}",
						},
					},
					type = {
						castNumberToInteger = true,
						weakUnionCheck = true,
						weakNilCheck = true,
					},
					IntelliSense = {
						traceBeSetted = false,
						traceFieldInject = false,
						traceLocalSet = false,
						traceReturn = false,
					},
				},
			},
		},
	},

	-- Formatters for Lua
	format = {
		lua = { "stylua" },
	},

	-- Linters for Lua
	lint = {
		lua = { "selene" },
	},

	-- Custom linter configurations
	lint_config = {
		selene = {
			cmd = "selene",
			stdin = false,
			args = { "--config", vim.fn.stdpath("config") .. "/selene.toml" },
			stream = "stdout",
			ignore_exitcode = true,
			-- Add condition to check if selene is available
			condition = function()
				return vim.fn.executable("selene") == 1
			end,
			parser = require("lint.parser").from_errorformat("%f:%l:%c: %t%*[^:]: %m", {
				source = "selene",
				severity = vim.diagnostic.severity.WARN,
			}),
		},
	},

	-- DAP (Debug Adapter Protocol)
	debug = {
		adapters = {
			nlua = function(callback, config)
				callback({
					type = "server",
					host = config.host or "127.0.0.1",
					port = config.port or 8086,
				})
			end,
		},

		configurations = {
			lua = {
				{
					type = "nlua",
					request = "attach",
					name = "Attach to running Neovim instance",
				},
			},
		},
	},
}
