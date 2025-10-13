-- Registry for which-key groups to be registered from individual plugins
-- This module allows plugins to register their groups early (in init functions)
-- before which-key is loaded, solving the timing issue.

local M = {}
local registry = {}

-- Register a group to be added to which-key later
-- @param id string: unique identifier for the plugin/group
-- @param group_config table: which-key group configuration
function M.register(id, group_config)
	if type(id) ~= "string" then
		vim.notify("which_key_groups: id must be a string", vim.log.levels.ERROR)
		return
	end
	
	if type(group_config) ~= "table" then
		vim.notify("which_key_groups: group_config must be a table", vim.log.levels.ERROR)
		return
	end
	
	registry[id] = group_config
end

-- Get all registered groups for which-key to consume
-- @return table: all registered group configurations
function M.all()
	return registry
end

-- Register and immediately apply if which-key is available (for late registrations)
-- @param id string: unique identifier for the plugin/group
-- @param group_config table: which-key group configuration
function M.register_and_apply(id, group_config)
	M.register(id, group_config)
	
	-- Try to apply immediately if which-key is already loaded
	local ok, wk = pcall(require, "which-key")
	if ok and wk.add then
		wk.add(group_config)
	end
end

-- Clear a specific group (useful for debugging/cleanup)
-- @param id string: unique identifier to remove
function M.unregister(id)
	registry[id] = nil
end

-- Clear all groups (useful for debugging/cleanup)
function M.clear_all()
	registry = {}
end

-- Get count of registered groups (useful for debugging)
-- @return number: count of registered groups
function M.count()
	local count = 0
	for _ in pairs(registry) do
		count = count + 1
	end
	return count
end

return M