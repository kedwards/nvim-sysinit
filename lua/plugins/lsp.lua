return {
	"neovim/nvim-lspconfig",
	lazy = false,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"stevearc/conform.nvim",
		"mfussenegger/nvim-lint",
		"b0o/schemastore.nvim",
	},
	config = function()
		require("lsp")
	end,
}
