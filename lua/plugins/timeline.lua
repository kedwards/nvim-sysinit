return {
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
