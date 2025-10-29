-- Python Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#pyright

return {
	-- LSP servers for Python
	lsp = {
		pyright = {
			settings = {
				python = {
					analysis = {
						typeCheckingMode = "basic",
						autoSearchPaths = true,
						diagnosticMode = "workspace",
						useLibraryCodeForTypes = true,
						autoImportCompletions = true,
					},
				},
			},
		},
	},

	-- Formatters for Python
	format = {
		python = { "ruff", "isort" },
	},

	-- Linters for Python
	lint = {
		python = { "ruff", "mypy" },
	},

	-- DAP configuration for Python debugging
	dap = {
		python = {
			type = "python",
			request = "launch",
			program = "${file}",
			console = "integratedTerminal",
		},
	},
}

