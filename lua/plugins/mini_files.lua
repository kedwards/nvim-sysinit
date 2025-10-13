return {
	"echasnovski/mini.files",
	opts = {
		windows = {
			preview = false,
			width_preview = 40,
		},
	},
	keys = {
		{
			"<leader>fm",
			function()
				require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
			end,
			desc = "Open mini.files (Directory of Current File)",
		},
		{
			"<leader>fM",
			function()
				require("mini.files").open(vim.uv.cwd(), true)
			end,
			desc = "Open mini.files (cwd)",
		},
	},
	config = function(_, opts)
		local mf = require("mini.files")
		mf.setup(opts)

		-- create mapping to show/hide dot-files
		local show_dotfiles = true

		local filter_show = function()
			return true
		end

		local filter_hide = function(fs_entry)
			return not vim.startswith(fs_entry.name, ".")
		end

		local toggle_dotfiles = function()
			show_dotfiles = not show_dotfiles
			local new_filter = show_dotfiles and filter_show or filter_hide
			mf.refresh({ content = { filter = new_filter } })
		end

		-- create mappings to modify target window via split
		local map_split = function(buf_id, lhs, direction, close_on_file)
			local rhs = function()
				local new_target_window
				local cur_target_window = mf.get_explorer_state().target_window
				if cur_target_window ~= nil then
					vim.api.nvim_win_call(cur_target_window, function()
						vim.cmd("belowright " .. direction .. " split")
						new_target_window = vim.api.nvim_get_current_win()
					end)

					mf.set_target_window(new_target_window)
					mf.go_in({ close_on_file = close_on_file })
				end
			end

			local desc = "Open in " .. direction .. " split"
			if close_on_file then
				desc = desc .. " and close"
			end
			vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
		end

		-- set focused directory as current working directory
		local files_set_cwd = function()
			local cur_entry_path = mf.get_fs_entry().path
			local cur_directory = vim.fs.dirname(cur_entry_path)
			if cur_directory ~= nil then
				vim.fn.chdir(cur_directory)
			end
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id

				vim.keymap.set(
					"n",
					opts.mappings and opts.mappings.toggle_hidden or "g.",
					toggle_dotfiles,
					{ buffer = buf_id, desc = "Toggle hidden files" }
				)

				vim.keymap.set(
					"n",
					opts.mappings and opts.mappings.change_cwd or "gc",
					files_set_cwd,
					{ buffer = args.data.buf_id, desc = "Set cwd" }
				)

				map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal or "s", "horizontal", false)
				map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical or "v", "vertical", false)
				map_split(buf_id, opts.mappings and opts.mappings.go_in_horizontal_plus or "S", "horizontal", true)
				map_split(buf_id, opts.mappings and opts.mappings.go_in_vertical_plus or "V", "vertical", true)
			end,
		})

		-- set custom bookmarks
		local set_mark = function(id, path, desc)
			mf.set_bookmark(id, path, { desc = desc })
		end

		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesExplorerOpen",
			callback = function()
				set_mark("c", vim.fn.stdpath("config"), "Config")
				set_mark("w", vim.fn.getcwd, "Working directory")
				set_mark("~", "~", "Home directory")
			end,
		})
	end,
}
