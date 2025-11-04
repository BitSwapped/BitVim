--- plugins/lsp.lua ---

return {
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		},
	},

	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = { "lua_ls", "clangd" },
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = "User BitFile",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			require("bitvim.lsp.diagnostics").setup()

			local handlers = require("bitvim.lsp.handlers")

			-- Get capabilities from blink.cmp
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			if pcall(require, "blink.cmp") then
				capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
			end

			-- Set global defaults once
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Single LspAttach autocmd for keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("bitvim-lsp-attach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						handlers.on_attach(client, args.buf)
					end
				end,
			})
		end,
	},
}
