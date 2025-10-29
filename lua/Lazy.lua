local uv = vim.uv or vim.loop
local fn = vim.fn
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
	if fn.executable("git") == 0 then
		vim.api.nvim_echo({
			{ "❌ lazy.nvim not installed: Git not found in PATH", "ErrorMsg" },
		}, true, {})
		return
	end

	local ok = pcall(fn.system, {
		"git",
		"clone",
		"--filter=blob:none",
		"--depth=1",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})

	if not ok then
		vim.api.nvim_echo({
			{ "❌ Failed to clone lazy.nvim. Check your network connection.", "ErrorMsg" },
		}, true, {})
		return
	end
end

if not vim.opt.rtp:get()[lazypath] then
	vim.opt.rtp:prepend(lazypath)
end

local ok, lazy = pcall(require, "lazy")
if not ok then
	vim.api.nvim_echo({
		{ "❌ lazy.nvim failed to load", "ErrorMsg" },
	}, true, {})
	return
end

lazy.setup({
	spec = {
		{ import = "plugins" },
	},
	defaults = {
		lazy = true,
		version = false,
	},
	rocks = {
		enabled = false,
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		enabled = true,
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"2html_plugin",
				"getscript",
				"getscriptPlugin",
				"gzip",
				"logipat",
				"matchit",
				"matchparen",
				"netrw",
				"netrwPlugin",
				"netrwSettings",
				"netrwFileHandlers",
				"rrhelper",
				"spellfile_plugin",
				"tar",
				"tarPlugin",
				"tohtml",
				"tutor",
				"vimball",
				"vimballPlugin",
				"zip",
				"zipPlugin",
				"rplugin",
			},
		},
	},
})
