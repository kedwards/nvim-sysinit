return {
	"kndndrj/nvim-dbee",
	dependencies = { "MunifTanjim/nui.nvim" },
	lazy = false,
	build = function()
		require("dbee").install()
	end,
	config = function()
		require("dbee").setup()

		require("which-key").add({
			{ "<leader>l", group = "Dbee" },
			{ "<leader>lt", "<cmd>lua require('dbee').toggle()<cr>", desc = "Toggle dbee", mode = { "n", "v" } },
		})
	end,
}
