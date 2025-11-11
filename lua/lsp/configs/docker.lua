-- Docker Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#docker_language_server
-- go install github.com/docker/docker-language-server/cmd/docker-language-server@latest

return {
	-- LSP
	lsp = {
		["docker-language-server"] = {
			settings = {},
		},
	},

	-- Formatters
	format = {},

	-- Linters
	lint = {
		docker = { "hadolint" },
	},

	-- DAP
	dap = {},
}
