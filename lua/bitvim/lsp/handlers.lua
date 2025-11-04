--- lsp/handlers.lua ---
local M = {}

vim.lsp.config("*", {
	float = {
		border = "rounded",
		max_width = 80,
		max_height = 20,
	},
})

-- CodeLens auto-refresh (still useful for proactive updates)
local function setup_codelens_autocmds()
	local group = vim.api.nvim_create_augroup("bitvim_lsp_codelens", { clear = true })

	vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
		group = group,
		callback = function(args)
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
				if client:supports_method("textDocument/codeLens") then
					vim.lsp.codelens.refresh({ bufnr = args.buf })
					break
				end
			end
		end,
	})
end

setup_codelens_autocmds()

function M.on_attach(client, bufnr)
	local map = require("bitvim.utils.keymap").map

	-- Navigation
	if client:supports_method("textDocument/definition") then
		map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buffer = bufnr })
	end

	if client:supports_method("textDocument/declaration") then
		map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", buffer = bufnr })
	end

	if client:supports_method("textDocument/implementation") then
		map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation", buffer = bufnr })
	end

	if client:supports_method("textDocument/typeDefinition") then
		map("n", "go", vim.lsp.buf.type_definition, { desc = "Go to type definition", buffer = bufnr })
	end

	if client:supports_method("textDocument/references") then
		map("n", "gr", vim.lsp.buf.references, { desc = "Show references", buffer = bufnr })
	end

	-- Hover & Signature
	if client:supports_method("textDocument/hover") then
		map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation", buffer = bufnr })
	end

	if client:supports_method("textDocument/signatureHelp") then
		map("n", "gs", vim.lsp.buf.signature_help, { desc = "Signature help", buffer = bufnr })
		map("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help", buffer = bufnr })
	end

	-- Code actions & Rename
	if client:supports_method("textDocument/codeAction") then
		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action", buffer = bufnr })
	end

	if client:supports_method("textDocument/rename") then
		map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", buffer = bufnr })
	end

	-- Diagnostics - using vim.diagnostic.jump() (goto_next/prev are deprecated)
	map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics", buffer = bufnr })
	map("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { desc = "Previous diagnostic", buffer = bufnr })
	map("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { desc = "Next diagnostic", buffer = bufnr })

	-- Inlay hints
	if client:supports_method("textDocument/inlayHint") then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
		map("n", "<leader>uh", function()
			local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
			vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
		end, { desc = "Toggle inlay hints", buffer = bufnr })
	end

	-- CodeLens
	if client:supports_method("textDocument/codeLens") then
		map("n", "<leader>cc", vim.lsp.codelens.run, { desc = "Run code lens", buffer = bufnr })
		map("n", "<leader>cC", function()
			vim.lsp.codelens.refresh({ bufnr = bufnr })
		end, { desc = "Refresh code lens", buffer = bufnr })
	end

	-- Call hierarchy
	if client:supports_method("textDocument/prepareCallHierarchy") then
		map("n", "<leader>ci", vim.lsp.buf.incoming_calls, { desc = "Incoming calls", buffer = bufnr })
		map("n", "<leader>co", vim.lsp.buf.outgoing_calls, { desc = "Outgoing calls", buffer = bufnr })
	end

	-- Workspace
	map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { desc = "Add workspace folder", buffer = bufnr })
	map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { desc = "Remove workspace folder", buffer = bufnr })
	map("n", "<leader>wl", function()
		require("bitvim.utils").ui.notify(
			vim.inspect(vim.lsp.buf.list_workspace_folders()),
			vim.log.levels.INFO,
			{ title = "Workspace Folders" }
		)
	end, { desc = "List workspace folders", buffer = bufnr })
end

return M
