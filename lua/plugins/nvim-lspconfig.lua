return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{
			"williamboman/mason.nvim",
			build = ":MasonUpdate",
			lazy = false,
		},
		{
			"stevearc/conform.nvim",
			lazy = true,
		},
		{
			"mfussenegger/nvim-lint",
			lazy = true,
		},
	},
	config = function()
		-- The LSP module handles everything including dependency configuration
		require("lsp")
	end,
}
