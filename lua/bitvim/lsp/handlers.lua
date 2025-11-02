local M = {}

M.default_handlers = {}

local _features = {
	codelens = {},
	highlight = {},
}

---@param fn function
---@param ... any
---@return boolean success, any result
local function safe_call(fn, ...)
	local ok, result = pcall(fn, ...)
	if not ok then
		require("bitvim.utils").ui.notify(
			string.format("LSP error: %s", result),
			vim.log.levels.WARN,
			{ title = "LSP" }
		)
	end
	return ok, result
end

local function setup_global_autocmds()
	local group = vim.api.nvim_create_augroup("bitvim_lsp_features", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
		group = group,
		callback = function(args)
			if _features.codelens[args.buf] then
				safe_call(vim.lsp.codelens.refresh, { bufnr = args.buf })
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
		group = group,
		callback = function(args)
			if _features.highlight[args.buf] then
				safe_call(vim.lsp.buf.document_highlight)
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
		group = group,
		callback = function(args)
			if _features.highlight[args.buf] then
				safe_call(vim.lsp.buf.clear_references)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufDelete", {
		group = group,
		callback = function(args)
			_features.codelens[args.buf] = nil
			_features.highlight[args.buf] = nil
		end,
	})
end

-- Setup global autocmds once
setup_global_autocmds()

--- Attach function called when an LSP client attaches to a buffer
function M.on_attach(client, bufnr)
	local map = require("bitvim.utils.keymap").map
	local border = "rounded"

	--- Standard LSP keymaps
	map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = bufnr })
	map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", buffer = bufnr })
	map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation", buffer = bufnr })
	map("n", "go", vim.lsp.buf.type_definition, { desc = "Go to type definition", buffer = bufnr })
	map("n", "gr", vim.lsp.buf.references, { desc = "Show references", buffer = bufnr })

	--- Hover & signature help
	map("n", "K", function()
		vim.lsp.buf.hover({ border = border, max_width = 80, max_height = 20 })
	end, { desc = "Hover documentation", buffer = bufnr })

	map("n", "gs", function()
		vim.lsp.buf.signature_help({ border = border, focusable = false, relative = "cursor" })
	end, { desc = "Signature help", buffer = bufnr })

	map("i", "<C-k>", function()
		vim.lsp.buf.signature_help({ border = border, focusable = false, relative = "cursor" })
	end, { desc = "Signature help", buffer = bufnr })

	--- Code actions & renaming
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", buffer = bufnr })
	map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = bufnr })

	--- Diagnostics navigation
	map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics", buffer = bufnr })
	map("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Previous diagnostic", buffer = bufnr })
	map("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Next diagnostic", buffer = bufnr })

	--- Formatting
	if client:supports_method("textDocument/formatting") then
		map("n", "<leader>cf", function()
			vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
		end, { desc = "Format buffer", buffer = bufnr })
	end

	if client:supports_method("textDocument/rangeFormatting") then
		map("v", "<leader>cf", function()
			vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 3000 })
		end, { desc = "Format range", buffer = bufnr })
	end

	--- Inlay hints
	if client:supports_method("textDocument/inlayHint") then
		local ok = safe_call(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
		if ok then
			map("n", "<leader>uh", function()
				require("bitvim.utils.toggle").inlay_hints()
			end, { desc = "Toggle inlay hints", buffer = bufnr })
		end
	end

	--- CodeLens support (using global autocmd + lookup table)
	if client:supports_method("textDocument/codeLens") then
		_features.codelens[bufnr] = client.id
		map("n", "<leader>cc", vim.lsp.codelens.run, { desc = "Run code lens", buffer = bufnr })
		map("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh code lens", buffer = bufnr })
	end

	--- Document highlight (using global autocmd + lookup table)
	if client:supports_method("textDocument/documentHighlight") then
		_features.highlight[bufnr] = client.id
	end

	--- Call hierarchy support
	if client:supports_method("textDocument/prepareCallHierarchy") then
		map("n", "<leader>ci", vim.lsp.buf.incoming_calls, { desc = "Incoming calls", buffer = bufnr })
		map("n", "<leader>co", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls", buffer = bufnr })
	end

	--- Workspace folder management
	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder", buffer = bufnr })
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder", buffer = bufnr })
	map("n", "<leader>wl", function()
		require("bitvim.utils").ui.notify(
			vim.inspect(vim.lsp.buf.list_workspace_folders()),
			vim.log.levels.INFO,
			{ title = "Workspace Folders" }
		)
	end, { desc = "List workspace folders", buffer = bufnr })

	--- Notify that LSP is attached
	-- require("bitvim.utils").ui.notify(
	-- 	string.format("LSP attached: %s (id: %d)", client.name, client.id),
	-- 	vim.log.levels.INFO,
	-- 	{ title = "LSP" }
	-- )
end

--- Cleanup function called when LSP detaches
function M.on_detach(client, bufnr)
	-- Clear feature tracking
	_features.codelens[bufnr] = nil
	_features.highlight[bufnr] = nil

	-- Notify
	require("bitvim.utils").ui.notify(
		string.format("LSP detached: %s (id: %d)", client.name, client.id),
		vim.log.levels.INFO,
		{ title = "LSP" }
	)
end

return M
