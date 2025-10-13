return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {},
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

		-- Load dynamically registered groups from plugins
		local groups_registry = require("config.which_key_groups")
		for _, group_config in pairs(groups_registry.all()) do
			wk.add(group_config)
		end
	end,
}
