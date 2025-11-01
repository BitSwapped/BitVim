--- utils/format.lua ---
---@class Utils.Format
local M = {}

---@class LazyFormatter
---@field name string
---@field primary? boolean
---@field format fun(bufnr:number)
---@field sources fun(bufnr:number):string[]
---@field priority number

M.formatters = {} ---@type LazyFormatter[]

--- Register a formatter in the system
---@param formatter LazyFormatter
function M.register(formatter)
	M.formatters[#M.formatters + 1] = formatter
	table.sort(M.formatters, function(a, b)
		return a.priority > b.priority
	end)
end

--- Resolve active formatters for buffer
---@param buf? number
---@return table[]
function M.resolve(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	local have_primary = false
	local resolved = {}

	for _, formatter in ipairs(M.formatters) do
		local sources = formatter.sources(buf)
		local active = #sources > 0 and (not formatter.primary or not have_primary)
		have_primary = have_primary or (active and formatter.primary) or false

		table.insert(resolved, {
			name = formatter.name,
			primary = formatter.primary,
			format = formatter.format,
			sources = formatter.sources,
			priority = formatter.priority,
			active = active,
			resolved = sources,
		})
	end

	return resolved
end

--- Check if formatting is enabled for buffer
---@param buf? number
---@return boolean
function M.enabled(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	local gaf = vim.g.autoformat
	local baf = vim.b[buf].autoformat

	if baf ~= nil then
		return baf
	end

	return gaf == nil or gaf
end

--- Toggle autoformat
---@param buf? boolean
function M.toggle(buf)
	local current = M.enabled()
	M.enable(not current, buf)
end

--- Enable/disable autoformat
---@param enable? boolean
---@param buf? boolean
function M.enable(enable, buf)
	if enable == nil then
		enable = true
	end

	if buf then
		vim.b.autoformat = enable
	else
		vim.g.autoformat = enable
		vim.b.autoformat = nil
	end

	local msg = string.format("Autoformat (%s): %s", buf and "Buffer" or "Global", enable and "enabled" or "disabled")
	require("bitvim.utils").ui.notify(msg)
end

--- Format buffer
---@param opts? {force?:boolean, buf?:number}
function M.format(opts)
	opts = opts or {}
	local buf = opts.buf or vim.api.nvim_get_current_buf()

	if not ((opts and opts.force) or M.enabled(buf)) then
		return
	end

	local done = false
	for _, formatter in ipairs(M.resolve(buf)) do
		if formatter.active then
			done = true
			local ok, err = pcall(function()
				return formatter.format(buf)
			end)
			if not ok then
				local msg = string.format("Formatter `%s` failed: %s", formatter.name, tostring(err))
				require("bitvim.utils").ui.notify(msg, vim.log.levels.ERROR)
			end
		end
	end

	if not done and opts and opts.force then
		require("bitvim.utils").ui.notify("No formatter available", vim.log.levels.WARN)
	end
end

--- Setup formatting system
function M.setup()
	-- Autoformat on save
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("BitVimFormat", { clear = true }),
		callback = function(event)
			M.format({ buf = event.buf })
		end,
	})

	-- Manual format command
	vim.api.nvim_create_user_command("Format", function()
		M.format({ force = true })
	end, { desc = "Format buffer" })
end

return M
