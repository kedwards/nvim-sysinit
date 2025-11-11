-- Markdown Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#marksman
-- curl -L --fail --silent --show-error -o ~/.local/bin/marksman https://github.com/artempyanykh/marksman/releases/download/2024-12-18/marksman-linux-x64 && chmod +x ~/.local/bin/marksman

return {
	-- LSP
	lsp = {
		marksman = {
			name = "marksman",
			settings = {},
		},
	},

	-- Formatters
	format = {},

	-- Linters
	lint = {},

	-- DAP
	dap = {},
}
