-- Python Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#pyright
-- pip install pyright || npm install -g pyright

return {
	-- LSP
	lsp = {
		ruff = {
			settings = {},
		},
		-- pyright = {
		-- 	settings = {
		-- 		python = {
		-- 			analysis = {
		-- 				typeCheckingMode = "basic",
		-- 				autoSearchPaths = true,
		-- 				diagnosticMode = "workspace",
		-- 				useLibraryCodeForTypes = true,
		-- 				autoImportCompletions = true,
		-- 			},
		-- 		},
		-- 	},
		-- },
	},

	-- Formatters
	format = {
		python = { "ruff", "isort" },
	},

	-- Linters
	lint = {
		python = { "ruff", "mypy" },
	},

	-- DAP
	dap = {
		python = {
			type = "python",
			request = "launch",
			program = "${file}",
			console = "integratedTerminal",
		},
	},
}
