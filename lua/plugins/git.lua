return {
	{
		"lewis6991/gitsigns.nvim",
		event = "BufEnter",
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next", { preview = true, navigation_message = false })
						end
					end)

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev", { preview = true, navigation_message = false })
						end
					end)

					-- Actions
					map("n", "<leader>gSs", gitsigns.stage_hunk, { desc = "Stage hunk" })
					map("n", "<leader>gSr", gitsigns.reset_hunk, { desc = "Reset hunk" })

					map("v", "<leader>gSs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Stage visual hunk" })

					map("v", "<leader>gSr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end, { desc = "Reset visual hunk" })

					map("n", "<leader>gSS", gitsigns.stage_buffer, { desc = "Stage buffer" })
					map("n", "<leader>gSR", gitsigns.reset_buffer, { desc = "Reset buffer" })
					map("n", "<leader>gSp", gitsigns.preview_hunk, { desc = "Preview hunk" })
					map("n", "<leader>gSi", gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

					map("n", "<leader>gSb", function()
						gitsigns.blame_line({ full = true })
					end, { desc = "Blame line" })

					map("n", "<leader>gSd", gitsigns.diffthis, { desc = "Diff this" })

					map("n", "<leader>gSD", function()
						gitsigns.diffthis({ split = "~" })
					end, { desc = "Diff all" })

					map("n", "<leader>gSQ", function()
						gitsigns.setqflist()
					end, { desc = "Send all to quickfix" })
					map("n", "<leader>gSq", gitsigns.setqflist, { desc = "Send to quickfix" })

					-- Toggles
					map("n", "<leader>gtb", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame" })
					map("n", "<leader>gtd", gitsigns.preview_hunk_inline, { desc = "Toggle deleted" })
					map("n", "<leader>gtw", gitsigns.toggle_word_diff, { desc = "Toggle word diff" })
				end,
			})
			require("which-key").add({
				{ "<leader>g", group = "Git" },
				{ "<leader>gS", group = "Hunks" },
				{ "<leader>gt", group = "Toggle" },
			})
		end,
	},
	{
		"linrongbin16/gitlinker.nvim",
		cmd = "GitLink",
		opts = {},
	},
	{
		"tpope/vim-fugitive",
		cmd = "Git",
		keys = {
			{ "<leader>gs", "<cmd>Git<cr>", desc = "Status" },
		},
	},
}
