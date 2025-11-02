--- plguins/indent.lua ---

return {
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "User FilePost",
		main = "ibl",
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = { show_start = false, show_end = false },
			exclude = {
				filetypes = {
					"Trouble",
					"alpha",
					"dashboard",
					"help",
					"lazy",
					"mason",
					"neo-tree",
					"notify",
					"snacks_dashboard",
					"snacks_notif",
					"snacks_terminal",
					"snacks_win",
					"toggleterm",
					"trouble",
				},
			},
			whitespace = {
				remove_blankline_trail = true,
			},
		},
	},
	{
		"nvim-mini/mini.indentscope",
		version = false,
		event = "User FilePost",
		opts = {
			symbol = "│",
			options = { try_as_border = true },
		},
		config = function(_, opts)
			require("mini.indentscope").setup(opts)
			vim.api.nvim_create_autocmd({ "FileType" }, {
				desc = "Disable indentscope for certain filetypes",
				callback = function()
					local ignored_filetypes = {
						"alpha",
						"dashboard",
						"help",
						"lazy",
						"mason",
						"fzf",
						"minifiles",
						"notify",
						"startify",
						"toggleterm",
					}
					if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
						vim.b.miniindentscope_disable = true
					end
				end,
			})
		end,
	},
}
