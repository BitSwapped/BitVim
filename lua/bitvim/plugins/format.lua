--- plugins/format.lua ---

return {
	"stevearc/conform.nvim",
	dependencies = { "mason.nvim" },
	event = { "BufReadPre", "BufNewFile" },
	cmd = "ConformInfo",

	--- Keymaps for formatting
	keys = {
		{
			"<leader>cf",
			function()
				require("bitvim.utils.format").format({ force = true })
			end,
			mode = { "n", "x" },
			desc = "Format Buffer",
		},
		{
			"<leader>cF",
			function()
				require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
			end,
			mode = { "n", "x" },
			desc = "Format Injected Langs",
		},
	},

	--- Autocmd to register conform formatters with bitvim utils
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				require("bitvim.utils.format").register({
					name = "conform.nvim",
					priority = 100,
					primary = true,
					format = function(buf)
						require("conform").format({ bufnr = buf })
					end,
					sources = function(buf)
						local ret = require("conform").list_formatters(buf)
						return vim.tbl_map(function(v)
							return v.name
						end, ret)
					end,
				})
			end,
		})
	end,

	--- Conform configuration options
	opts = function()
		---  Default formatting options
		local opts = {
			default_format_opts = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_format = "fallback",
			},

			---  Filetype-specific formatters
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				toml = { "taplo" },
				zig = { "zigfmt" },
			},

			---  Formatter-specific configuration
			formatters = {
				injected = { options = { ignore_errors = true } },
				shfmt = { prepend_args = { "-i", "2", "-ci" } },
				clang_format = { prepend_args = { "--style=file" } },
			},
		}
		return opts
	end,

	--- Setup Conform with opts and bitvim formatting utilities
	config = function(_, opts)
		require("conform").setup(opts)
		require("bitvim.utils.format").setup()
	end,
}
