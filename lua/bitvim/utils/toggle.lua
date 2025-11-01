--- utils/toggle.lua ---

---@class Utils.Toggle
local M = {}

-- safe invert helper for values that may be nil
local function invert(val, default)
	if val == nil then
		return not default
	end
	return not val
end

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

--- Toggle line numbers
function M.number()
	vim.wo.number = invert(vim.wo.number, true)
	local msg = string.format("Line numbers: %s", vim.wo.number and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Toggle relative line numbers
function M.relative_number()
	vim.wo.relativenumber = invert(vim.wo.relativenumber, false)
	local msg = string.format("Relative numbers: %s", vim.wo.relativenumber and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Toggle wrap
function M.wrap()
	vim.wo.wrap = invert(vim.wo.wrap, false)
	local msg = string.format("Line wrap: %s", vim.wo.wrap and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Toggle highlight search
function M.hlsearch()
	local enable = invert(vim.o.hlsearch, false)
	vim.o.hlsearch = enable

	require("bitvim.utils").ui.notify(enable and "Search highlight enabled" or "Search highlight disabled")
end

--- Toggle diagnostics globally
---@param state? boolean Explicit state (true = enable, false = disable)
function M.diagnostics(state)
	if state == nil then
		state = not vim.diagnostic.is_enabled()
	end
	vim.diagnostic.enable(state)
	require("bitvim.utils").ui.notify(state and "Diagnostics enabled" or "Diagnostics disabled")
end

--- Toggle LSP inlay hints
--- Toggle LSP inlay hints
function M.inlay_hints()
	local bufnr = vim.api.nvim_get_current_buf()
	local current = vim.b.inlay_hints_enabled

	-- default true when nil
	local enable = current == nil and true or not current

	vim.lsp.inlay_hint.enable(enable, { bufnr = bufnr })
	vim.b.inlay_hints_enabled = enable

	require("bitvim.utils").ui.notify(enable and "Inlay hints enabled" or "Inlay hints disabled")
end

--- Toggle virtual text display
function M.virtual_text()
	local cfg = vim.diagnostic.config()
	local enable = invert(cfg.virtual_text, true)

	vim.diagnostic.config({ virtual_text = enable })
	require("bitvim.utils").ui.notify(enable and "Virtual text enabled" or "Virtual text disabled")
end

--- Toggle underline display
function M.underline()
	local cfg = vim.diagnostic.config()
	local enable = invert(cfg.underline, true)

	vim.diagnostic.config({ underline = enable })
	require("bitvim.utils").ui.notify(enable and "Diagnostic underline enabled" or "Diagnostic underline disabled")
end

--- Toggle signs in sign column
function M.signs()
	local cfg = vim.diagnostic.config()
	local current = cfg.signs
	local enable = invert(current, true)

	if enable then
		local icons = require("bitvim.lsp.diagnostics").signs
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = icons.Error,
					[vim.diagnostic.severity.WARN] = icons.Warn,
					[vim.diagnostic.severity.HINT] = icons.Hint,
					[vim.diagnostic.severity.INFO] = icons.Info,
				},
			},
		})
	else
		vim.diagnostic.config({ signs = false })
	end

	require("bitvim.utils").ui.notify(enable and "Diagnostic signs enabled" or "Diagnostic signs disabled")
end

--- Toggle autoformat (global)
function M.autoformat()
	require("bitvim.utils.format").toggle(false)
end

--- Toggle autoformat (buffer)
function M.autoformat_buffer()
	require("bitvim.utils.format").toggle(true)
end

return M
