-- Go Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#gopls
-- mise use -g go

return {
	-- LSP
	lsp = {
		gopls = {
			settings = {
				gopls = {
					gofumpt = true,
					codelenses = {
						gc_details = false,
						generate = true,
						regenerate_cgo = true,
						run_govulncheck = true,
						test = true,
						tidy = true,
						upgrade_dependency = true,
						vendor = true,
					},
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
					analyses = {
						fieldalignment = true,
						nilness = true,
						unusedparams = true,
						unusedwrite = true,
						useany = true,
					},
					usePlaceholders = true,
					completeUnimported = true,
					staticcheck = true,
					directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
					semanticTokens = true,
				},
			},
		},
	},

	-- Formatters
	format = {
		go = { "gofumpt", "goimports-reviser" },
	},

	-- Linters
	lint = {
		go = { "golangci-lint" },
	},

	-- DAP
	dap = {
		go = {
			type = "go",
			name = "Debug",
			request = "launch",
			program = "${file}",
		},
	},
}
