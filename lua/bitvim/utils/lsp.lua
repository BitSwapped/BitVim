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
		if client:supports_method(method, bufnr) then
			return true
		end
	end
	return false
end

--- Get installed Mason servers
---@return string[] List of installed server names
function M.get_mason_servers()
	local has_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
	if not has_mason_lspconfig then
		return {}
	end

	local ok, servers = pcall(mason_lspconfig.get_installed_servers)
	return ok and servers or {}
end

--- Check if a server is installed via Mason
---@param server_name string Name of the LSP server
---@return boolean
function M.is_mason_server(server_name)
	local installed = M.get_mason_servers()
	return vim.tbl_contains(installed, server_name)
end

return M
