return function()
	local augroup = vim.api.nvim_create_augroup
	local autocmd = vim.api.nvim_create_autocmd

	-- AUTO RELOAD
	local reload_grp = augroup("SysInitAutoReload", { clear = true })

	autocmd({ "FocusGained", "CursorHold", "CursorHoldI" }, {
		group = reload_grp,
		pattern = "*",
		desc = "Check all visible buffers for external file changes when Neovim regains focus or is idle",
		callback = function()
			if vim.fn.getcmdwintype() == "" then
				vim.cmd.checktime()
			end
		end,
	})

	autocmd("BufEnter", {
		group = reload_grp,
		pattern = "*",
		desc = "When entering an unmodified buffer, reload it if the file changed on disk",
		callback = function(event)
			if vim.bo[event.buf].buftype ~= "" or vim.bo[event.buf].modified then
				return
			end
			local name = vim.api.nvim_buf_get_name(event.buf)
			if name ~= "" then
				vim.cmd.checktime(event.buf)
			end
		end,
	})

	-- UI/EDITOR
	local ui_grp = augroup("SysInitUIBehaviour", { clear = true })

	autocmd("FileType", {
		group = ui_grp,
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
		desc = "Allow quick window closing with 'q' for utility buffers",
		callback = function(event)
			vim.bo[event.buf].buflisted = false
			vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
		end,
	})

	autocmd("TermOpen", {
		group = ui_grp,
		desc = "Disable line numbers and start in insert mode for terminal buffers",
		callback = function()
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.cmd.startinsert()
		end,
	})

	-- FILE HANDLING
	local file_grp = augroup("SysInitFileHandling", { clear = true })

	autocmd("BufWritePre", {
		group = file_grp,
		desc = "Create missing parent directories before saving the file",
		callback = function(event)
			local name = event.match
			if not name or name == "" then
				return
			end
			if name:match("^%w%w+://") or name:match("^%[") then
				return
			end
			local file = vim.uv.fs_realpath(name) or name
			local dir = vim.fn.fnamemodify(file, ":p:h")
			if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
				pcall(vim.fn.mkdir, dir, "p")
			end
		end,
	})

	autocmd("TextYankPost", {
		group = file_grp,
		desc = "Briefly highlight yanked text for visual feedback",
		callback = function()
			vim.highlight.on_yank({ timeout = 150, higroup = "Visual" })
		end,
		-- callback = vim.schedule_wrap(function()
		-- 	vim.highlight.on_yank({ timeout = 150, higroup = "Visual" })
		-- end),
	})

	autocmd("BufReadPost", {
		group = file_grp,
		desc = "Restore the last cursor position when reopening a file",
		callback = function(event)
			local buf = event.buf
			if vim.b[buf].is_big_file then
				return
			end
			if vim.tbl_contains({ "gitcommit", "gitrebase", "svn", "hgcommit" }, vim.bo[buf].filetype) then
				return
			end
			local mark = vim.api.nvim_buf_get_mark(buf, '"')
			local lcount = vim.api.nvim_buf_line_count(buf)
			if mark[1] > 0 and mark[1] <= lcount then
				pcall(vim.api.nvim_win_set_cursor, 0, mark)
			end
		end,
	})

	-- CURSORLINE VISIBILITY
	local cursor_grp = augroup("SysInitCursorLine", { clear = true })

	autocmd({ "InsertLeave", "WinEnter" }, {
		group = cursor_grp,
		desc = "Enable cursorline in the active window when leaving insert mode or entering a window",
		callback = function()
			vim.opt_local.cursorline = true
		end,
	})

	autocmd({ "InsertEnter", "WinLeave" }, {
		group = cursor_grp,
		desc = "Disable cursorline in inactive windows or during insert mode",
		callback = function()
			vim.opt_local.cursorline = false
		end,
	})

	-- FORMATTING OPTIONS
	local format_grp = augroup("SysInitFormatOptions", { clear = true })

	autocmd("FileType", {
		group = format_grp,
		desc = "Disable automatic comment continuation for all filetypes",
		callback = function()
			vim.opt_local.formatoptions:remove({ "c", "r", "o" })
		end,
	})

	-- WINDOW MANAGEMENT
	local win_grp = augroup("SysInitWindowManagement", { clear = true })

	autocmd("VimResized", {
		group = win_grp,
		desc = "Automatically balance split windows when the editor is resized",
		command = "wincmd =",
	})

	-- FILETYPE-SPECIFIC SETTINGS
	local ft_grp = augroup("SysInitFileTypeSettings", { clear = true })

	autocmd("FileType", {
		group = ft_grp,
		pattern = { "gitcommit", "markdown" },
		desc = "Enable wrapping and spell-check for text-based filetypes",
		callback = function()
			vim.opt_local.wrap = true
			vim.opt_local.spell = true
			vim.opt_local.textwidth = 80
		end,
	})

	autocmd("FileType", {
		group = ft_grp,
		pattern = "json",
		desc = "Disable concealment in JSON files for better readability",
		callback = function()
			vim.opt_local.conceallevel = 0
		end,
	})

	-- PERFORMANCE OPTIMIZATIONS
	local perf_grp = augroup("SysInitPerformance", { clear = true })

	autocmd("BufReadPre", {
		group = perf_grp,
		desc = "Apply lightweight settings automatically for large files (>2 MB)",
		callback = function(event)
			local path = vim.api.nvim_buf_get_name(event.buf)
			if path == "" then
				return
			end
			vim.schedule(function()
				local ok, stats = pcall(vim.uv.fs_stat, path)
				if ok and stats and stats.size > 2 * 1024 * 1024 then
					vim.b[event.buf].is_big_file = true
					vim.opt_local.foldmethod = "manual"
					vim.opt_local.statuscolumn = ""
					vim.opt_local.conceallevel = 0
					vim.opt_local.spell = false
					vim.opt_local.swapfile = false
					vim.opt_local.undofile = false
					vim.opt_local.syntax = "off"
				end
			end)
		end,
	})
end
