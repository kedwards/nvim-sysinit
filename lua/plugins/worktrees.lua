return {
	"Juksuu/worktrees.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("worktrees").setup()
	end,
}
