--- utils/lsp.lua ---
---@class Utils.Lsp
local M = {}

--- Get all active LSP clients for a buffer
---@param bufnr? number Buffer number (default: current buffer)
---@return vim.lsp.Client[]
function M.get_clients(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return vim.lsp.get_clients({ bufnr = bufnr })
end

--- Check if any attached LSP client supports a specific method
---@param method string LSP method name (e.g., "textDocument/formatting")
---@param bufnr? number Buffer number (default: current buffer)
---@return boolean
function M.supports(method, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	for _, client in ipairs(M.get_clients(bufnr)) do
		if client:supports_method(method) then
			return true
		end
	end
	return false
end

--- Restart LSP client(s)
---@param client_name? string Specific client to restart (restarts all if nil)
---@param bufnr? number Buffer number (default: current buffer)
function M.restart(client_name, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local clients = M.get_clients(bufnr)
	local restarted = {}

	for _, client in ipairs(clients) do
		if not client_name or client.name == client_name then
			client:stop()
			table.insert(restarted, client.name)
		end
	end

	if #restarted > 0 then
		vim.defer_fn(function()
			vim.cmd.edit()
			require("bitvim.utils").ui.notify("Restarted: " .. table.concat(restarted, ", "))
		end, 500)
	else
		require("bitvim.utils").ui.notify("No matching LSP clients to restart", vim.log.levels.WARN)
	end
end

--- Show detailed LSP info for current buffer
---@param bufnr? number Buffer number (default: current buffer)
function M.info(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local clients = M.get_clients(bufnr)

	if #clients == 0 then
		require("bitvim.utils").ui.notify("No LSP clients attached", vim.log.levels.WARN)
		return
	end

	local lines = { "# Attached LSP Clients\n" }

	for _, client in ipairs(clients) do
		table.insert(lines, string.format("## %s (id: %d)", client.name, client.id))
		table.insert(lines, "**Capabilities:**")

		-- Check common capabilities
		local capabilities = {
			{ "Formatting", "textDocument/formatting" },
			{ "Range Formatting", "textDocument/rangeFormatting" },
			{ "Hover", "textDocument/hover" },
			{ "Signature Help", "textDocument/signatureHelp" },
			{ "Rename", "textDocument/rename" },
			{ "Code Action", "textDocument/codeAction" },
			{ "Definition", "textDocument/definition" },
			{ "References", "textDocument/references" },
			{ "Document Highlight", "textDocument/documentHighlight" },
			{ "Inlay Hints", "textDocument/inlayHint" },
			{ "Code Lens", "textDocument/codeLens" },
			{ "Call Hierarchy", "textDocument/prepareCallHierarchy" },
		}

		for _, cap in ipairs(capabilities) do
			local supported = client:supports_method(cap[2])
			table.insert(lines, string.format("- [%s] %s", supported and "x" or " ", cap[1]))
		end

		table.insert(lines, "") -- Empty line between clients
	end

	require("bitvim.utils").ui.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
		title = "LSP Info",
	})
end

return M
