--- utils/toggle ---

---@class Utils.Toggle
local M = {}

---@class ToggleOpts
---@field name string
---@field get fun(): boolean
---@field set fun(state: boolean)

--- Create a toggle function
---@param opts ToggleOpts
---@return fun()
function M.toggle(opts)
	return function()
		local state = not opts.get()
		opts.set(state)

		local msg = string.format("%s: %s", opts.name, state and "enabled" or "disabled")
		require("bitvim.utils").ui.notify(msg)
	end
end

--- Toggle diagnostics
function M.diagnostics()
	local enabled = vim.diagnostic.is_enabled()
	vim.diagnostic.enable(not enabled)

	local msg = string.format("Diagnostics: %s", not enabled and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Toggle inlay hints
function M.inlay_hints()
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })

	local msg = string.format("Inlay hints: %s", not enabled and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Toggle line numbers
function M.number()
	vim.wo.number = not vim.wo.number
	local msg = string.format("Line numbers: %s", vim.wo.number and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Toggle relative line numbers
function M.relative_number()
	vim.wo.relativenumber = not vim.wo.relativenumber
	local msg = string.format("Relative numbers: %s", vim.wo.relativenumber and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Toggle wrap
function M.wrap()
	vim.wo.wrap = not vim.wo.wrap
	local msg = string.format("Line wrap: %s", vim.wo.wrap and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

return M
