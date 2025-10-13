return function()
	local default_opts = { noremap = true, silent = true }

	--- Helper function to create keymaps with consistent options
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

	-- Define keymaps in a table for better organization
	local keymaps = {
		-- Movement and navigation
		{ { "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", "Move up (display line)", { expr = true } },
		{ { "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", "Move down (display line)", { expr = true } },
		{ "n", "<C-h>", "<C-w>h", "Go to left window" },
		{ "n", "<C-j>", "<C-w>j", "Go to bottom window" },
		{ "n", "<C-k>", "<C-w>k", "Go to top window" },
		{ "n", "<C-l>", "<C-w>l", "Go to right window" },

		-- Line and block movement
		{ "n", "<leader>k", "<cmd>move-2<CR>==", "Move line up" },
		{ "n", "<leader>j", "<cmd>move+<CR>==", "Move line down" },
		{ "v", "K", ":m '<-2<CR>gv=gv", "Move selection up" },
		{ "v", "J", ":m '>+1<CR>gv=gv", "Move selection down" },

		-- Register operations
		{ "x", "<leader>p", '"_dp', "Paste without yank" },
		{ { "n", "v" }, "<leader>y", '"+y', "Yank to clipboard" },
		{ { "n", "v" }, "<leader>d", '"_d', "Delete to void register" },

		-- Utility
		{ "n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlights" },
		{ "n", "[o", "O<Esc>j", "Add blank line above" },
		{ "n", "]o", "o<Esc>k", "Add blank line below" },
		{ "n", "Q", "<Nop>", "Disable ex mode" },

		-- File operations
		{ "n", "<leader>w", "<cmd>w<CR>", "Save file" },
		{ "n", "<leader>W", "<cmd>wall<CR>", "Save all files" },
		{ "n", "<leader>q", "<cmd>q<CR>", "Quit" },

		-- Splits
		{ "n", "|", "<cmd>vsplit<CR>", "Vertical split" },
		{ "n", "\\", "<cmd>split<CR>", "Horizontal split" },

		-- Insert mode utilities
		{ "i", "<C-u>", "<Esc>mzgUiw`za", "Uppercase word" },

		-- Visual mode indentation
		{ "v", "<", "<gv", "Indent left" },
		{ "v", ">", ">gv", "Indent right" },
		{ "v", "<S-Tab>", "<gv", "Indent left" },
		{ "v", "<Tab>", ">gv", "Indent right" },

		-- Window resizing
		{ "n", "<C-Left>", ":vertical resize +1<CR>", "Increase width" },
		{ "n", "<C-Right>", ":vertical resize -1<CR>", "Decrease width" },
		{ "n", "<C-Up>", ":resize -1<CR>", "Decrease height" },
		{ "n", "<C-Down>", ":resize +1<CR>", "Increase height" },
	}

	-- Apply all keymaps
	for _, keymap in ipairs(keymaps) do
		local mode, lhs, rhs, desc, opts = keymap[1], keymap[2], keymap[3], keymap[4], keymap[5]
		map(mode, lhs, rhs, desc, opts)
	end

end
