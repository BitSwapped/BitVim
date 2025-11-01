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
			automatic_enable = true,
		},
	},

	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			-- Diagnostics Setup
			require("bitvim.lsp.diagnostics").setup()

			-- Handlers & Capabilities Setup
			local handlers = require("bitvim.lsp.handlers")
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			if pcall(require, "blink.cmp") then
				capabilities = require("blink.cmp").get_lsp_capabilities()
			end

			-- Apply default handlers and capabilities to all servers
			vim.lsp.config("*", {
				capabilities = capabilities,
				handlers = handlers.default_handlers,
			})

			-- Auto Call on_attach on LSP Attach
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("bitvim-lsp-attach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						handlers.on_attach(client, args.buf)
					end
				end,
			})

			-- Load Per-Server Configurations if Available
			local ok, servers = pcall(require, "bitvim.lsp.servers")
			if ok then
				for server_name, server_config in pairs(servers) do
					vim.lsp.config(server_name, server_config)
				end
			end
		end,
	},
}
