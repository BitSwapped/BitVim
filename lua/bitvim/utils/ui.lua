--- utils/ui ---

---@class Utils.Ui
local M = {}

--- Notification with consistent formatting
---@param msg string
---@param level? number
---@param opts? table
function M.notify(msg, level, opts)
	opts = opts or {}
	level = level or vim.log.levels.INFO

	vim.notify(
		msg,
		level,
		vim.tbl_extend("force", {
			title = "BitVim",
		}, opts)
	)
end

--- Confirm with yes/no dialog
---@param msg string
---@param callback fun(confirmed: boolean)
function M.confirm(msg, callback)
	vim.ui.select({ "Yes", "No" }, {
		prompt = msg,
	}, function(choice)
		callback(choice == "Yes")
	end)
end

--- Open float window
---@param bufnr number
---@param opts? table
---@return number winid
function M.float(bufnr, opts)
	opts = vim.tbl_extend("force", {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.8),
		height = math.floor(vim.o.lines * 0.8),
		row = math.floor(vim.o.lines * 0.1),
		col = math.floor(vim.o.columns * 0.1),
		style = "minimal",
		border = "rounded",
	}, opts or {})

	return vim.api.nvim_open_win(bufnr, true, opts)
end

return M
