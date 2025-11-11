-- Bash Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#bashls
-- npm install -g bash-language-server

return {
	-- LSP
	lsp = {
		bashls = {
			name = "bash-language-server",
			settings = {},
		},
	},

	-- Formatters
	format = {
		sh = { "beautysh" },
	},

	-- Linters
	lint = {
		sh = { "shellharden", "shfmt" },
	},

	-- DAP
	dap = {},
}
