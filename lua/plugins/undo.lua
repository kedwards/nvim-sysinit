return {
  {
	  "mbbill/undotree",
	  lazy = false,
	  keys = {
		  { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle Undotree" },
	  },
	  init = function()
		  vim.g.undotree_WindowLayout = 2
	  end,
	  config = function() end
  },
  {
		"y3owk1n/time-machine.nvim",
		cmd = {
			"TimeMachineToggle",
			"TimeMachinePurgeBuffer",
			"TimeMachinePurgeAll",
			"TimeMachineLogShow",
			"TimeMachineLogClear",
		},
		opts = {},
		keys = {
			{
				"<leader>t",
				"",
				desc = "Time Machine",
			},
			{
				"<leader>tt",
				"<cmd>TimeMachineToggle<cr>",
				desc = "Toggle Tree",
			},
			{
				"<leader>tx",
				"<cmd>TimeMachinePurgeCurrent<cr>",
				desc = "Purge current",
			},
			{
				"<leader>tX",
				"<cmd>TimeMachinePurgeAll<cr>",
				desc = "Purge all",
			},
			{
				"<leader>tl",
				"<cmd>TimeMachineLogShow<cr>",
				desc = "Show log",
			},
		},
	}
}