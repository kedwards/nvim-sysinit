return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			"zbirenbaum/copilot.lua",
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		lazy = false,
		build = "make tiktoken",
		opts = {
			debug = false,
			auto_follow_cursor = false,
		},
		keys = {
			{
				"<leader>aca",
				function()
					require("CopilotChat").toggle()
				end,
				desc = "Toggle chat window",
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			local wk = require("which-key")

			chat.setup(opts)

			wk.add({
				{ "<leader>ac", group = "CopilotChat" },
				{ "<leader>acd", "<cmd>CopilotChatDocs<cr>", desc = "Create documentation" },
				{ "<leader>ace", "<cmd>CopilotChatExplain<cr>", desc = "Explain code" },
				{ "<leader>acf", "<cmd>CopilotChatFix<cr>", desc = "Fix code" },
				{ "<leader>acm", "<cmd>CopilotChatCommit<cr>", desc = "Generate commit message" },
				{ "<leader>acp", "<cmd>CopilotChatPrompts<cr>", desc = "Prompt actions" },
				{ "<leader>aco", "<cmd>CopilotChatOptimize<cr>", desc = "Optimize code" },
				{ "<leader>acr", "<cmd>CopilotChatReview<cr>", desc = "Review code" },
				{ "<leader>acs", "<cmd>CopilotChatStop<cr>", desc = "Stop current output" },
				{ "<leader>act", "<cmd>CopilotChatTests<cr>", desc = "Generate tests" },
				{ "<leader>acx", "<cmd>CopilotChatReset<cr>", desc = "Reset chat window" },
				{ "<leader>ac?", "<cmd>CopilotChatModels<cr>", desc = "Select Models" },
				{
					"<leader>aci",
					function()
						local input = vim.fn.input("Ask Copilot: ")
						if input ~= "" then
							vim.cmd("CopilotChat " .. input)
						end
					end,
					desc = "Ask input",
				},
			})
		end,
	},
	{
		"folke/sidekick.nvim",
		lazy = false,
		opts = {
			cli = {
				mux = {
					backend = "zellij",
					enabled = true,
				},
			},
		},
		keys = {
			{
				"<tab>",
				function()
					if not require("sidekick").nes_jump_or_apply() then
						return "<Tab>"
					end
				end,
				expr = true,
				desc = "Goto/Apply Next Edit Suggestion",
			},
			{
				"<leader>asd",
				function()
					require("sidekick.cli").close()
				end,
				desc = "Detach a CLI Session",
			},
			{
				"<leader>asp",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
			{
				"<leader>asc",
				function()
					require("sidekick.cli").toggle({ name = "copilot", focus = true })
				end,
				desc = "Sidekick Toggle Copilot",
			},
		},
		config = function(_, opts)
			require("sidekick").setup(opts)

			require("which-key").add({
				{ "<leader>as", group = "Sidekick" },
			})
		end,
	},
}
