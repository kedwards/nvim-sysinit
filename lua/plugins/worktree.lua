return {
	{
		"afonsofrancof/worktrees.nvim",
		enabled = false,
		event = "VeryLazy",
		opts = {},
	},
	{
		"Juksuu/worktrees.nvim",
		enabled = false,
		config = function()
			require("worktrees").setup()
		end,
	},
	{
		"ThePrimeagen/git-worktree.nvim",
		enabled = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		opts = {},
		keys = {
			{
				"<leader>gw",
				function()
					require("telescope").extensions.git_worktree.git_worktrees()
				end,
				desc = "Git worktrees",
			},
			{
				"<leader>gW",
				function()
					require("telescope").extensions.git_worktree.create_git_worktree()
				end,
				desc = "Create git worktree",
			},
		},
	},
}
