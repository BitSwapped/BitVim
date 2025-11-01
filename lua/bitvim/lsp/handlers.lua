--- lsp/handlers.lua ---

local M = {}

---  Default LSP handlers
M.default_handlers = {}

---  Attach function called when an LSP client attaches to a buffer
function M.on_attach(client, bufnr)
	local map = require("bitvim.utils.keymap").map
	local lsp = require("bitvim.utils.lsp")
	local border = "rounded"

	---  Standard LSP keymaps
	map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = bufnr })
	map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", buffer = bufnr })
	map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation", buffer = bufnr })
	map("n", "go", vim.lsp.buf.type_definition, { desc = "Go to type definition", buffer = bufnr })
	map("n", "gr", vim.lsp.buf.references, { desc = "Show references", buffer = bufnr })

	---  Hover & signature help
	map("n", "K", function()
		vim.lsp.buf.hover({ border = border, max_width = 80, max_height = 20 })
	end, { desc = "Hover documentation", buffer = bufnr })

	map("n", "gs", function()
		vim.lsp.buf.signature_help({ border = border, focusable = false, relative = "cursor" })
	end, { desc = "Signature help", buffer = bufnr })

	map("i", "<C-k>", function()
		vim.lsp.buf.signature_help({ border = border, focusable = false, relative = "cursor" })
	end, { desc = "Signature help", buffer = bufnr })

	---  Code actions & renaming
	map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", buffer = bufnr })
	map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = bufnr })

	---  Diagnostics navigation
	map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics", buffer = bufnr })
	map("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Previous diagnostic", buffer = bufnr })
	map("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Next diagnostic", buffer = bufnr })

	---  Inlay hints support
	if lsp.supports("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		map("n", "<leader>uh", function()
			require("bitvim.utils.toggle").inlay_hints()
		end, { desc = "Toggle inlay hints", buffer = bufnr })
	end

	---  CodeLens support
	if lsp.supports("textDocument/codeLens") then
		local group = vim.api.nvim_create_augroup("lsp_codelens_" .. bufnr, { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
			group = group,
			buffer = bufnr,
			callback = vim.lsp.codelens.refresh,
		})
		map("n", "<leader>cc", vim.lsp.codelens.run, { desc = "Run code lens", buffer = bufnr })
		map("n", "<leader>cC", vim.lsp.codelens.refresh, { desc = "Refresh code lens", buffer = bufnr })
	end

	---  Document highlight
	if lsp.supports("textDocument/documentHighlight") then
		local group = vim.api.nvim_create_augroup("lsp_doc_highlight_" .. bufnr, { clear = true })
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = group,
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
			group = group,
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
		})
	end

	---  Call hierarchy support
	if lsp.supports("textDocument/prepareCallHierarchy") then
		map("n", "<leader>ci", vim.lsp.buf.incoming_calls, { desc = "Incoming calls", buffer = bufnr })
		map("n", "<leader>co", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls", buffer = bufnr })
	end

	---  Notify user that LSP is attached
	require("bitvim.utils").ui.notify(
		string.format("LSP attached: %s (id: %d)", client.name, client.id),
		vim.log.levels.INFO,
		{ title = "LSP" }
	)
end

return M
