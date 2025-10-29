return function()
	local opt, g, fn = vim.opt, vim.g, vim.fn

	-- LEADER KEYS
	g.mapleader = " "
	g.maplocalleader = ";"

	-- DISABLE PROVIDERS
	for _, provider in ipairs({ "perl", "ruby", "node", "python3" }) do
		local var = "loaded_" .. provider .. "_provider"
		if g[var] == nil then
			g[var] = 0
		end
	end

	-- Disable netrw plugin
	g.loaded_netrw = 1
	g.loaded_netrwPlugin = 1

	-- FILE & BACKUP SETTINGS
	opt.backup = false
	opt.writebackup = false
	opt.swapfile = false
	opt.directory = ""
	opt.undofile = true
	opt.autoread = true
	opt.autowrite = true

	-- Setup undo directory
	local undo_dir = vim.fn.stdpath("state") .. "/undo"
	if fn.isdirectory(undo_dir) == 0 then
		pcall(fn.mkdir, undo_dir, "p")
	end
	opt.undodir = undo_dir

	-- GENERAL SETTINGS
	opt.updatetime = 250
	opt.timeoutlen = 400
	opt.mouse = "a"
	opt.confirm = true
	opt.history = 1000
	opt.hidden = true

	opt.wildmode = { "list", "longest" }
	opt.wildignorecase = true
	opt.wildmenu = true

	-- UI & DISPLAY SETTINGS
	-- Command line
	opt.cmdheight = 1
	opt.showcmd = true
	opt.showmode = false
	opt.laststatus = 3

	-- Cursor and lines
	opt.showtabline = 1
	opt.cursorline = true
	opt.guicursor = "n-v-i-c:block-Cursor"
	opt.number = true
	opt.relativenumber = true

	-- Scrolling and viewport
	opt.scrolloff = 8
	opt.sidescrolloff = 8
	opt.wrap = false

	-- Columns and signs
	opt.signcolumn = "yes:2"
	opt.fillchars = { eob = " " }

	-- Popup menu
	opt.pumheight = 15
	opt.pumblend = 10

	-- INDENTATION SETTINGS
	opt.expandtab = true
	opt.shiftwidth = 2
	opt.tabstop = 2
	opt.softtabstop = 2
	opt.smartindent = true
	opt.breakindent = true
	opt.shiftround = true

	opt.foldenable = true
	opt.foldlevel = 99
	opt.foldlevelstart = 99
	opt.foldnestmax = 10
	opt.foldcolumn = "1"
	-- Use Treesitter folds if available
	if pcall(require, "nvim-treesitter") then
		opt.foldmethod = "expr"
		opt.foldexpr = "nvim_treesitter#foldexpr()"
	else
		opt.foldmethod = "manual"
	end

	-- SEARCH SETTINGS
	opt.ignorecase = true
	opt.smartcase = true
	opt.inccommand = "split"
	opt.hlsearch = true
	opt.incsearch = true

	-- COMPLETION SETTINGS
	opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
	opt.complete = { ".", "w", "b", "kspell" }
	opt.shortmess:append("filnxtToOFWIcC")

	-- EDITING SETTINGS
	opt.formatoptions = "jcroqlnt"
	opt.joinspaces = false
	opt.iskeyword:append("-")

	-- BUFFER SETTINGS
	opt.switchbuf = "usetab,uselast"

	-- EXTERNAL TOOLS
	-- Setup ripgrep if available
	if fn.executable("rg") == 1 then
		opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden --follow --glob '!.git/*'"
		opt.grepformat = "%f:%l:%c:%m"
	end

	-- CLIPBOARD SETTINGS
	-- Configure clipboard based on environment
	local function setup_clipboard()
		local has_wsl = os.getenv("WSL_DISTRO_NAME") or fn.has("wsl") == 1

		if has_wsl then
			-- WSL clipboard integration
			g.clipboard = {
				name = "WslClipboard",
				copy = {
					["+"] = "/mnt/c/WINDOWS/system32/clip.exe",
					["*"] = "/mnt/c/WINDOWS/system32/clip.exe",
				},
				paste = {
					["+"] = [[/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command [Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace("`r", ""))]],
					["*"] = [[/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command [Console]::Out.Write($(Get-Clipboard -Raw).ToString().Replace("`r", ""))]],
				},
				-- Improve performance
				cache_enabled = 1,
			}
		elseif vim.fn.has("macunix") == 1 then
			-- macOS clipboard
			opt.clipboard = "unnamedplus"
		elseif vim.fn.executable("xclip") == 1 or vim.fn.executable("xsel") == 1 then
			-- Linux with X11
			opt.clipboard = "unnamedplus"
		else
			-- Fallback - no system clipboard
			opt.clipboard = ""
		end
	end

	setup_clipboard()
end
