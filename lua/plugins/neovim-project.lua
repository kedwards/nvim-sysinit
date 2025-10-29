return {
	{
		"kedwards/neovim-project",
		opts = {
			projects = {
				"~/projects/*",
				"~/.config/*",
				"~/.profile.d/*",
			},
			picker = {
				type = "telescope",
			},
		},
		init = function()
			vim.opt.sessionoptions:append("globals", "localoptions")
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"Shatur/neovim-session-manager",
		},
		lazy = false,
		priority = 100,
		keys = {
			{
				"<leader>pd",
				"<cmd>NeovimProjectDiscover<cr>",
				mode = { "n", "v" },
				desc = "Find a project based on patterns",
			},
			{
				"<leader>pa",
				"<cmd>NeovimProjectDiscover alphabetical_name<cr>",
				mode = { "n", "v" },
				desc = "Find a project based on name",
			},
			{
				"<leader>ph",
				"<cmd>NeovimProjectHistory<cr>",
				mode = { "n", "v" },
				desc = "Select a project from history",
			},
			{
				"<leader>pr",
				"<cmd>NeovimProjectLoadRecent<cr>",
				mode = { "n", "v" },
				desc = "Open the previous project session",
			},
		},
		config = function(_, opts)
			local project = require("neovim-project")
			project.setup(opts)

			require("which-key").add({
				{ "<leader>p", group = "Project" },
			})
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
