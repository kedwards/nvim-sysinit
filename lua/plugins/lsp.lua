return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"stevearc/conform.nvim",
		"mfussenegger/nvim-lint",
		"mason-org/mason.nvim",
	},
	config = function()
		require("lsp")
	end,
}
