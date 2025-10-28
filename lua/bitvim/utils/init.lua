--- utils/init.lua ---

---@class Utils
---@field ui Utils.Ui
---@field keymap Utils.Keymap
---@field toggle Utils.Toggle
local M = {}

-- Lazy-load submodules on first access
setmetatable(M, {
	__index = function(t, k)
		local ok, module = pcall(require, "bitvim.utils." .. k)
		if not ok then
			error("Utils module not found: " .. k)
		end
		rawset(t, k, module)
		return module
	end,
})

return M
