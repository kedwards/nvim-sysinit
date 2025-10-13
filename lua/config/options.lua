return function()
	local opt = vim.opt
	local g = vim.g

	-- LEADER KEYS
	g.mapleader = " " -- Space as main leader
	g.maplocalleader = ";" -- Semicolon as local leader

	-- DISABLE PROVIDERS
	-- Disable unused providers for faster startup
	g.loaded_perl_provider = 0
	g.loaded_ruby_provider = 0
	g.loaded_node_provider = 0
	g.loaded_python3_provider = 0

	-- FILE & BACKUP SETTINGS
	opt.backup = false -- Don't create backup files
	opt.writebackup = false -- Don't create backup before overwriting
	opt.swapfile = false -- Don't create swap files
	opt.undofile = true -- Enable persistent undo
	opt.autoread = true -- Auto-read file when changed outside Neovim
	opt.autowrite = true -- Auto-save before commands like :next

	-- Setup undo directory
	local undodir = vim.fn.stdpath("state") .. "/undo"
	vim.fn.mkdir(undodir, "p")
	opt.undodir = undodir

	-- GENERAL SETTINGS
	opt.updatetime = 250 -- Faster completion (default 4000ms)
	opt.timeoutlen = 300 -- Time to wait for mapped sequence
	opt.mouse = "a" -- Enable mouse in all modes
	opt.confirm = true -- Confirm to save changes before closing
	opt.history = 1000 -- Command history size
	opt.hidden = true -- Allow hidden buffers

	-- Wild menu settings
	opt.wildmode = { "list", "longest" } -- Command completion mode
	opt.wildignorecase = true -- Ignore case in command completion
	opt.wildmenu = true -- Enhanced command completion

	-- UI & DISPLAY SETTINGS
	-- Command line
	opt.cmdheight = 0 -- Hide command line when not used
	opt.showcmd = true -- Show command in status line
	opt.showmode = false -- Don't show mode (using statusline)
	opt.laststatus = 3 -- Global statusline

	-- Cursor and lines
	opt.cursorline = true -- Highlight current line
	opt.guicursor = "n-v-i-c:block-Cursor" -- Block cursor in all modes
	opt.number = true -- Show line numbers
	opt.relativenumber = true -- Show relative line numbers

	-- Scrolling and viewport
	opt.scrolloff = 8 -- Min lines above/below cursor
	opt.sidescrolloff = 8 -- Min columns left/right of cursor
	opt.wrap = false -- Don't wrap lines
	opt.linebreak = true -- Wrap at word boundaries (when wrap is on)

	-- Columns and signs
	opt.signcolumn = "yes:2" -- Always show 2-width sign column
	-- opt.colorcolumn = "80" -- Show column guide at 80 chars
	opt.fillchars = { eob = " " } -- Hide ~ on empty lines

	-- Popup menu
	opt.pumheight = 15 -- Max items in popup menu
	opt.pumblend = 10 -- Popup transparency

	-- INDENTATION SETTINGS
	opt.expandtab = true -- Use spaces instead of tabs
	opt.shiftwidth = 2 -- Size of indent
	opt.tabstop = 2 -- Size of tab character
	opt.softtabstop = 2 -- Size of tab in insert mode
	opt.smartindent = true -- Smart auto-indenting
	opt.smarttab = true -- Smart tab behavior
	opt.breakindent = true -- Indent wrapped lines
	opt.shiftround = true -- Round indent to multiple of shiftwidth

	-- FOLDING SETTINGS
	opt.foldenable = true -- Enable folding
	opt.foldlevel = 99 -- Start with all folds open
	opt.foldlevelstart = 99 -- Start with all folds open
	opt.foldmethod = "expr" -- Use expression for folding
	opt.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding
	opt.foldnestmax = 10 -- Max nested folds
	opt.foldcolumn = "1" -- Show fold column

	-- SEARCH SETTINGS
	opt.ignorecase = true -- Ignore case in search
	opt.smartcase = true -- Case-sensitive if uppercase present
	opt.infercase = true -- Infer case in keyword completion
	opt.inccommand = "split" -- Show live preview of substitution
	opt.hlsearch = true -- Highlight search results
	opt.incsearch = true -- Show search matches as you type

	-- COMPLETION SETTINGS
	opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
	opt.complete = { ".", "w", "b", "kspell" }
	opt.shortmess:append("c") -- Don't show completion messages
	opt.shortmess = "filnxtToOFWIcC" -- Abbreviate messages

	-- EDITING SETTINGS
	opt.formatoptions = "jcroqlnt" -- Format options
	opt.virtualedit = "block" -- Allow cursor past end of line in visual block
	opt.spelloptions = "camel" -- Spell check camelCase words
	opt.joinspaces = false -- Don't insert two spaces after punctuation
	opt.iskeyword:append("-") -- Treat dash as part of word

	-- BUFFER SETTINGS
	opt.switchbuf = "usetab,uselast" -- Switch buffer behavior

	-- EXTERNAL TOOLS
	-- Setup ripgrep if available
	if vim.fn.executable("rg") == 1 then
		opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden --follow"
		opt.grepformat = "%f:%l:%c:%m"
	end

	-- CLIPBOARD SETTINGS
	-- Configure clipboard based on environment
	local function setup_clipboard()
		if vim.fn.has("wsl") == 1 then
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
				cache_enabled = 0,
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
