local M = {}

local _modules = {}

--- Lazy module loading with caching
--- @param name string Module name to require
--- @return any The required module
function M.lazy_require(name)
	if not _modules[name] then
		local ok, module = pcall(require, name)
		if ok then
			_modules[name] = module
		else
			vim.notify("Failed to load module: " .. name, vim.log.levels.ERROR, { title = "LSP Loader" })
			return nil
		end
	end
	return _modules[name]
end

return M
