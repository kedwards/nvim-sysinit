-- TypeScript/JavaScript Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ts_ls

return {
	-- LSP servers for TypeScript/JavaScript
	lsp = {
		ts_ls = {
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayParameterNameHintsWhenArgumentMatchesName = false,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = false,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		},
		-- Alternative: eslint as LSP (Note: eslint-lsp in Mason)
		eslint = {
			settings = {
				codeAction = {
					disableRuleComment = {
						enable = true,
						location = "separateLine",
					},
					showDocumentation = {
						enable = true,
					},
				},
				codeActionOnSave = {
					enable = false,
					mode = "all",
				},
				experimental = {
					useFlatConfig = false,
				},
				format = true,
				nodePath = "",
				onIgnoredFiles = "off",
				problems = {
					shortenToSingleLine = false,
				},
				quiet = false,
				rulesCustomizations = {},
				run = "onType",
				useESLintClass = false,
				validate = "on",
				workingDirectory = {
					mode = "location",
				},
			},
		},
	},

	-- Formatters for TypeScript/JavaScript
	format = {
		typescript = { "prettier" },
		javascript = { "prettier" },
		typescriptreact = { "prettier" },
		javascriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		html = { "prettier" },
		markdown = { "prettier" },
	},

	-- Linters for TypeScript/JavaScript
	lint = {
		typescript = { "eslint" },
		javascript = { "eslint" },
		typescriptreact = { "eslint" },
		javascriptreact = { "eslint" },
	},

	-- DAP configuration for Node.js/TypeScript debugging
	dap = {
		typescript = {
			type = "node2",
			name = "Launch TypeScript",
			request = "launch",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			protocol = "inspector",
			console = "integratedTerminal",
		},
		javascript = {
			type = "node2",
			name = "Launch JavaScript",
			request = "launch",
			program = "${file}",
			cwd = "${workspaceFolder}",
			sourceMaps = true,
			protocol = "inspector",
			console = "integratedTerminal",
		},
	},
}

