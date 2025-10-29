local M = {}

-- Detect system PATH separator (":" on Unix, ";" on Windows)
local PATH_SEP = package.config:sub(1, 1) == "\\" and ";" or ":"

--- Normalize, expand, and validate a path string
--- @param path string Path to normalize
--- @return string|nil Normalized absolute path, or nil if invalid
local function normalize_path(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end

	local ok, expanded = pcall(vim.fn.expand, path)
	if not ok or expanded == "" then
		return nil
	end

	-- Resolve to absolute path
	-- Remove trailing slashes for consistency
	local absolute = vim.fn.fnamemodify(expanded, ":p")
	return (absolute:gsub("/+$", ""))
end

--- Safely create directory if it doesn't exist
--- @param path string Directory path to create
--- @return boolean Success status
local function ensure_directory(path)
	if vim.fn.isdirectory(path) == 1 then
		return true
	end

	local ok, _ = pcall(vim.fn.mkdir, path, "p")
	return ok and vim.fn.isdirectory(path) == 1
end

--- Add paths to a list-style vim option with deduplication
--- @param option string Vim option name (e.g., "path", "runtimepath")
--- @param paths string[] Normalized paths to add
--- @param prepend boolean Whether to prepend (true) or append (false)
local function add_to_option(option, paths, prepend)
	if not paths or #paths == 0 then
		return
	end

	local opt = vim.opt[option]
	local current = opt:get()
	local existing = {}
	for _, p in ipairs(current) do
		existing[p] = true
	end

	-- Filter out duplicates
	local to_add = {}
	for _, path in ipairs(paths) do
		if not existing[path] then
			table.insert(to_add, path)
			existing[path] = true
		end
	end

	-- Add paths
	if prepend then
		opt:prepend(to_add)
	else
		opt:append(to_add)
	end
end

--- Register paths to vim.opt.path
--- Automatically creates directories if they don't exist and deduplicates paths
--- @param paths string|string[] Single path or list of paths to register
--- @param opts? {prepend: boolean, create: boolean} Options
function M.register(paths, opts)
	opts = opts or {}
	local prepend = opts.prepend or false

	if type(paths) == "string" then
		paths = { paths }
	end

	local normalized = {}
	for _, path in ipairs(paths) do
		local norm = normalize_path(path)
		if norm and ensure_directory(norm) then
			table.insert(normalized, norm)
		end
	end

	if #normalized > 0 then
		add_to_option("path", normalized, prepend)
	end
end

--- Remove paths from vim.opt.path
--- @param paths string|string[] Single path or list of paths to remove
function M.unregister(paths)
	if type(paths) == "string" then
		paths = { paths }
	end

	for _, path in ipairs(paths) do
		local norm = normalize_path(path)
		if norm then
			vim.opt.path:remove(norm)
		end
	end
end

--- Get current registered paths
--- @return string[] List of paths in vim.opt.path
function M.list()
	return vim.opt.path:get()
end

--- Setup Mason paths with proper normalization and deduplication
--- Ensures Mason bin directory is in PATH and runtimepath
--- @param opts? {mason_bin: string, prepend: boolean} Options
--- @return boolean Success status
function M.setup_mason(opts)
	opts = opts or {}
	local prepend = opts.prepend ~= false -- default true

	local mason_bin = opts.mason_bin or (vim.fn.stdpath("data") .. "/mason/bin")

	-- Normalize and validate bin path
	local norm_bin = normalize_path(mason_bin)
	if not norm_bin then
		return false
	end

	-- Extract root from bin path (parent directory)
	local norm_root = vim.fn.fnamemodify(norm_bin, ":h")

	-- Ensure directories exist (creates parent automatically with "p")
	if not ensure_directory(norm_bin) then
		return false
	end

	-- Add to runtimepath (for Mason UI and plugins)
	add_to_option("runtimepath", { norm_root, norm_bin }, prepend)

	-- Add to PATH environment variable
	local path_env = vim.env.PATH or ""
	local parts = vim.split(path_env, PATH_SEP, { plain = true })

	local exists = false
	for _, p in ipairs(parts) do
		if p == norm_bin then
			exists = true
			break
		end
	end

	-- Add to PATH if not present
	if not exists then
		if prepend then
			vim.env.PATH = norm_bin .. PATH_SEP .. path_env
		else
			vim.env.PATH = path_env .. PATH_SEP .. norm_bin
		end
	end

	return true
end

return M
