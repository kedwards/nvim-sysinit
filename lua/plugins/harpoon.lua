return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	lazy = false,
	opts = {
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4,
		},
		settings = {
			save_on_toggle = true,
		},
	},
	keys = function()
		local keys = {
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Add location",
			},
			{
				"<Leader>hr",
				function()
					require("harpoon"):list():remove()
				end,
				desc = "Remove location",
			},
			{
				"<Leader>ht",
				function()
					require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
				end,
				desc = "Toggle menu",
			},
			{
				"]h",
				function()
					require("harpoon"):list():next()
				end,
				desc = "Next location",
			},
			{
				"[h",
				function()
					require("harpoon"):list():prev()
				end,
				desc = "Previous location",
			},
		}

		for i = 1, 5 do
			table.insert(keys, {
				"<leader>h" .. i,
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "Harpoon to File " .. i,
			})
		end

		return keys
	end,
	config = function(_, opts)
		require("which-key").add({
			{ "<leader>h", desc = "+Harpoon" },
		})
		require("harpoon"):setup(opts)
	end,
}
