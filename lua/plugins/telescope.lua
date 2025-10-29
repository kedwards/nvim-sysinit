return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		event = "VeryLazy",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"tsakirist/telescope-lazy.nvim",
			"fdschmidt93/telescope-egrepify.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		keys = {
			{ "<leader>f<space>", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Files" },
			{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Git" },
			{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
			{ "<leader>fb", "<cmd>Telescope file_browser<cr>", desc = "Browsers" },
			{ "<leader>fa", "<cmd>Telescope resume<cr>", desc = "Repeat search" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Old files" },
			{ "<leader>f?", "<cmd>Telescope live_grep<cr>", desc = "Find using GREP" },
			{
				"<leader>f/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find()
				end,
				desc = "Fuzzily search buffer",
			},
		},
		config = function()
			local telescope = require("telescope")
			local themes = require("telescope.themes")
			local actions = require("telescope.actions")
			local action_layout = require("telescope.actions.layout")
			local action_state = require("telescope.actions.state")

			local select_one_or_multi = function(prompt_bufnr)
				local picker = action_state.get_current_picker(prompt_bufnr)
				local multi = picker:get_multi_selection()
				if not vim.tbl_isempty(multi) then
					actions.close(prompt_bufnr)
					for _, j in pairs(multi) do
						if j.path ~= nil then
							local path = vim.fn.fnameescape(j.path)
							if j.lnum ~= nil then
								vim.cmd(string.format("%s +%s %s", "edit", j.lnum, path))
							else
								vim.cmd(string.format("%s %s", "edit", path))
							end
						end
					end
				else
					actions.select_default(prompt_bufnr)
				end
			end

			local multi_select = {
				i = {
					["<CR>"] = select_one_or_multi,
				},
				n = {
					["<CR>"] = select_one_or_multi,
				},
			}

			telescope.setup({
				defaults = themes.get_ivy({
					layout_config = {
						height = 0.40,
					},
					mappings = {
						i = {
							["<M-p>"] = action_layout.toggle_preview,
						},
						n = {
							["<M-p>"] = action_layout.toggle_preview,
						},
					},
				}),
				pickers = {
					colorscheme = {
						enable_preview = true,
					},
					git_files = {
						mappings = multi_select,
					},
					oldfiles = {
						mappings = multi_select,
					},
					find_files = {
						mappings = multi_select,
					},
					buffers = {
						mappings = {
							i = {
								["<C-d>"] = actions.delete_buffer + actions.move_to_top,
							},
							n = {
								["dd"] = actions.delete_buffer + actions.move_to_top,
							},
						},
					},
				},
				extensions = {
					["ui-select"] = themes.get_dropdown({}),
					file_browser = {
						hijack_netrw = true,
					},
				},
			})
			require("telescope").load_extension("ui-select")
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("lazy")
			require("telescope").load_extension("egrepify")
			require("telescope").load_extension("file_browser")

			require("which-key").add({
				{ "<leader>f", group = "Telescope" },
			})
		end,
	},
}
