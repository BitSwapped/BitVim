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
		event = "User BitFile",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"saghen/blink.cmp",
		},
		config = function()
			require("bitvim.lsp.diagnostics").setup()

			local handlers = require("bitvim.lsp.handlers")
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			if pcall(require, "blink.cmp") then
				capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
			end

			vim.lsp.config("*", {
				capabilities = capabilities,
				handlers = handlers.default_handlers,
				root_markers = { ".git" },
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("bitvim-lsp-attach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						handlers.on_attach(client, args.buf)
					end
				end,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("bitvim-lsp-detach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client then
						handlers.on_detach(client, args.buf)
					end
				end,
			})

			local ok, servers = pcall(require, "bitvim.lsp.servers")
			if ok and servers then
				for server_name, server_config in pairs(servers) do
					local config = vim.tbl_deep_extend("force", {
						capabilities = capabilities,
						handlers = handlers.default_handlers,
					}, server_config)

					vim.lsp.config(server_name, config)
				end
			end
		end,
	},
}
