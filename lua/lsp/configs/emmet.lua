-- Emmet Language Configuration
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#emmet_language_server
-- npm install -g @olrtg/emmet-language-server

return {
	-- LSP
	lsp = {
		emmetls = {
			name = "emmet-language-server",
			init_options = {
				-- change completion kind to `Snippet`
				showSuggestionsAsSnippets = true,
				html = {
					options = {
						["bem.enabled"] = true,
						["bem.modifier"] = "--",
					},
				},
				jsx = {
					options = {
						["bem.enabled"] = true,
						["jsx.enabled"] = true,
						["output.selfClosingStyle"] = "xhtml",
					},
				},
			},
		},
	},

	-- Formatters
	format = {},

	-- Linters
	lint = {},

	-- DAP
	dap = {},
}
