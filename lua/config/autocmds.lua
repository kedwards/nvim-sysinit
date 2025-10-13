return function()
	local augroup = vim.api.nvim_create_augroup
	local autocmd = vim.api.nvim_create_autocmd

	-- GENERAL SETTINGS
	local general = augroup("GeneralSettings", { clear = true })

	-- Highlight text on yank
	autocmd("TextYankPost", {
		group = general,
		desc = "Highlight yanked text",
		callback = function()
			vim.highlight.on_yank({ timeout = 150, higroup = "Visual" })
		end,
	})

	-- Restore cursor position when reopening files
	autocmd("BufReadPost", {
		group = general,
		desc = "Restore last cursor position",
		callback = function(event)
			local exclude = { "gitcommit", "gitrebase", "svn", "hgcommit" }
			local buf = event.buf
			if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].is_big_file then
				return
			end

			local mark = vim.api.nvim_buf_get_mark(buf, '"')
			local lcount = vim.api.nvim_buf_line_count(buf)
			if mark[1] > 0 and mark[1] <= lcount then
				pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
		end,
	})

	-- Automatically reload file if changed outside Neovim
	autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
		group = general,
		desc = "Check if file changed on focus",
		command = "checktime",
	})

	-- Close certain windows with 'q'
	autocmd("FileType", {
		group = general,
		desc = "Close certain filetypes with 'q'",
		pattern = {
			"help",
			"lspinfo",
			"man",
			"notify",
			"qf",
			"query",
			"startuptime",
			"tsplayground",
			"checkhealth",
		},
		callback = function(event)
			vim.bo[event.buf].buflisted = false
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
		end,
	})

	-- Disable line numbers in terminal
	autocmd("TermOpen", {
		group = general,
		desc = "Disable line numbers in terminal",
		callback = function()
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.cmd("startinsert")
		end,
	})

	-- Auto-create parent directories when saving
	autocmd("BufWritePre", {
		group = general,
		desc = "Auto-create parent directories",
		callback = function(event)
			-- Skip special/unnamed buffers and URLs
			if not event.match or event.match == "" or event.match:match("^%w%w*://") then
				return
			end

			local file = vim.uv.fs_realpath(event.match) or event.match
			local dir = vim.fn.fnamemodify(file, ":p:h")

			if vim.fn.isdirectory(dir) == 0 then
				vim.fn.mkdir(dir, "p")
			end
		end,
	})

	-- FORMATTING SETTINGS
	local format = augroup("FormatOptions", { clear = true })

	-- Prevent auto-comment continuation
	autocmd("FileType", {
		group = format,
		desc = "Disable auto-comment continuation",
		callback = function()
			vim.opt_local.formatoptions:remove({ "c", "r", "o" })
		end,
	})

	-- WINDOW & BUFFER MANAGEMENT
	local windows = augroup("WindowManagement", { clear = true })

	-- Auto-resize splits when window is resized
	autocmd("VimResized", {
		group = windows,
		desc = "Auto-resize splits when window is resized",
		callback = function()
			local current_tab = vim.fn.tabpagenr()
			vim.cmd("tabdo wincmd =")
			vim.cmd("tabnext " .. current_tab)
		end,
	})

	-- Don't auto-comment new lines
	autocmd("BufEnter", {
		group = windows,
		desc = "Don't auto-comment new lines",
		callback = function()
			vim.opt.formatoptions:remove({ "c", "r", "o" })
		end,
	})

	-- FILE TYPE SPECIFIC
	local filetypes = augroup("FileTypeSettings", { clear = true })

	-- Set specific options for different file types
	autocmd("FileType", {
		group = filetypes,
		pattern = { "gitcommit", "markdown" },
		desc = "Enable spell check and wrap for text files",
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.spell = true
			vim.opt_local.textwidth = 80
		end,
	})

	-- JSON files
	autocmd("FileType", {
		group = filetypes,
		pattern = "json",
		desc = "JSON file settings",
		callback = function()
			vim.opt_local.conceallevel = 0
		end,
	})

	-- PERFORMANCE OPTIMIZATIONS
	local performance = augroup("Performance", { clear = true })

	-- Handle large files
	autocmd("BufReadPre", {
		group = performance,
		desc = "Optimize for large files",
		callback = function(event)
			local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))
			if ok and stats and stats.size > (1024 * 1024) then -- 1MB
				vim.b[event.buf].is_big_file = true
				vim.opt_local.foldmethod = "manual"
				vim.opt_local.spell = false
				vim.opt_local.swapfile = false
				vim.opt_local.undofile = false
			end
		end,
	})
end
