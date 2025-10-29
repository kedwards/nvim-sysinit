return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "helix",
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
	config = function(_, opts)
		local wk = require("which-key")

		wk.setup(opts)

		wk.add({
			{ "<leader>a", group = "AI" },
			{ "<leader>x", group = "Trouble" },
		})
	end,
}
