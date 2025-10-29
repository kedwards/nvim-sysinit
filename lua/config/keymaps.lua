return function()
	local default_opts = { noremap = true, silent = true }

	--- Helper function to create keymaps
	--- @param mode string|table Key modes
	--- @param lhs string Key combination
	--- @param rhs string|function Key action
	--- @param desc? string Description for the keymap
	--- @param additional_opts? table Additional options to merge
	local function map(mode, lhs, rhs, desc, additional_opts)
		local opts = vim.tbl_extend("force", default_opts, additional_opts or {})
		if desc then
			opts.desc = desc
		end
		vim.keymap.set(mode, lhs, rhs, opts)
	end

	-- LINE NAVIGATION (smart up/down)
	map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", "Move up (display line)", { expr = true })
	map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", "Move down (display line)", { expr = true })

	-- WINDOW NAVIGATION
	for key, dir in pairs({ h = "h", j = "j", k = "k", l = "l" }) do
		map("n", "<C-" .. key .. ">", "<C-w>" .. dir, "Go to " .. dir .. " window")
	end

	-- LINE & BLOCK MOVEMENT
	map("n", "<leader>k", "<cmd>move-2<CR>==", "Move line up")
	map("n", "<leader>j", "<cmd>move+<CR>==", "Move line down")
	map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")
	map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")

	-- REGISTER OPERATIONS
	map("x", "<leader>P", '"_dp', "Paste without yank")
	map({ "n", "v" }, "<leader>y", '"+y', "Yank to clipboard")
	map({ "n", "v" }, "<leader>D", '"_d', "Delete to void register")

	-- SEARCH & UTILITY
	map("n", "<esc>", "<cmd>nohlsearch<CR>", "Clear search highlights")
	map("n", "Q", "<Nop>", "Disable ex mode")

	-- FILE OPERATIONS
	map("n", "<leader>w", "<cmd>w<CR>", "Save file")
	map("n", "<leader>W", "<cmd>wall<CR>", "Save all files")
	map("n", "<leader>q", "<cmd>q<CR>", "Quit")

	-- SPLITS
	map("n", "|", "<cmd>vsplit<CR>", "Vertical split")
	map("n", "\\", "<cmd>split<CR>", "Horizontal split")

	-- INSERT MODE UTILITIES
	map("i", "<C-u>", "<Esc>mzgUiw`za", "Uppercase word")

	-- VISUAL MODE INDENTATION
	local function indent_visual(direction)
		return function()
			vim.cmd("normal! " .. direction .. "gv")
		end
	end
	map("v", "<", indent_visual("<"), "Indent left")
	map("v", ">", indent_visual(">"), "Indent right")
	map("v", "<S-Tab>", indent_visual("<"), "Indent left")
	map("v", "<Tab>", indent_visual(">"), "Indent right")

	-- WINDOW RESIZING
	local resizes = {
		Left = { cmd = ":vertical resize +1<CR>", desc = "Increase width" },
		Right = { cmd = ":vertical resize -1<CR>", desc = "Decrease width" },
		Up = { cmd = ":resize -1<CR>", desc = "Decrease height" },
		Down = { cmd = ":resize +1<CR>", desc = "Increase height" },
	}
	for key, data in pairs(resizes) do
		map("n", "<C-" .. key .. ">", data.cmd, data.desc)
	end
end
