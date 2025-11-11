-- TypeScript/JavaScript Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#ts_ls
-- npm install -g typescript-language-server typescript vscode-langservers-extracted

return {
	-- LSP
	lsp = {
		ts_ls = {
			name = "typescript-language-server",
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
		-- Alternative
		-- eslint = {
		-- 	name = "eslint-lsp",
		-- 	settings = {
		-- 		codeAction = {
		-- 			disableRuleComment = {
		-- 				enable = true,
		-- 				location = "separateLine",
		-- 			},
		-- 			showDocumentation = {
		-- 				enable = true,
		-- 			},
		-- 		},
		-- 		codeActionOnSave = {
		-- 			enable = false,
		-- 			mode = "all",
		-- 		},
		-- 		experimental = {
		-- 			useFlatConfig = false,
		-- 		},
		-- 		format = true,
		-- 		nodePath = "",
		-- 		onIgnoredFiles = "off",
		-- 		problems = {
		-- 			shortenToSingleLine = false,
		-- 		},
		-- 		quiet = false,
		-- 		rulesCustomizations = {},
		-- 		run = "onType",
		-- 		useESLintClass = false,
		-- 		validate = "on",
		-- 		workingDirectory = {
		-- 			mode = "location",
		-- 		},
		-- 	},
		-- },
	},

	-- Formatters
	format = {
		typescript = { "biome" },
		javascript = { "biome" },
		typescriptreact = { "biome" },
		javascriptreact = { "biome" },
	},

	-- Linters
	lint = {
		typescript = { "biome" },
		javascript = { "biome" },
		typescriptreact = { "biome" },
		javascriptreact = { "biome" },
	},

	-- DAP
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
