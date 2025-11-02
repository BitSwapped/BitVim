return {
	{ "MunifTanjim/nui.nvim" },

	{ "https://github.com/stevearc/dressing.nvim" },
	{
		"nvim-mini/mini.icons",
		opts = {},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},

	{
		"akinsho/bufferline.nvim",
		event = "User BitDeferred",
		version = "*",
		opts = {
			options = {
				buffer_close_icon = "",
				diagnostics = "nvim_lsp",
				diagnostics_update_on_event = true,
				always_show_bufferline = false,
				color_icons = true,
				get_element_icon = function(element)
					local icon, hl = require("mini.icons").get("filetype", element.filetype)
					return icon, hl
				end,
				separator_style = "thick",
			},
		},
		config = function(_, opts)
			require("bufferline").setup(opts)
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "User BitDeferred",
		init = function()
			vim.g.lualine_laststatus = vim.o.laststatus
			if vim.fn.argc(-1) > 0 then
				vim.o.statusline = " "
			else
				vim.o.laststatus = 0
			end
		end,
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					globasection_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
					globalstatus = true,
					refresh = { statusline = 1000 },
				},
				sections = {
					lualine_a = {
						{
							"mode",
							padding = { left = 1, right = 1 },
						},
					},
					lualine_b = {
						"branch",
						{
							"diff",
							symbols = { added = " ", modified = " ", removed = " " },
							padding = { left = 1, right = 1 },
						},
					},

					lualine_c = {
						{
							"filename",
							file_status = true,
							symbols = {
								modified = "●",
								readonly = "",
								unnamed = "",
							},
							padding = { left = 2, right = 1 },
						},
						{
							function()
								local clients = vim.lsp.get_clients({ bufnr = 0 })
								if #clients == 0 then
									return ""
								end
								local client_names = {}
								for _, client in ipairs(clients) do
									table.insert(client_names, client.name)
								end
								if #client_names == 0 then
									return ""
								end
								return " " .. table.concat(client_names, ", ")
							end,
							color = { fg = "#a9a1e1", gui = "bold" },
							padding = { left = 1, right = 1 },
						},
					},

					lualine_x = {
						{
							"diagnostics",
							sources = { "nvim_diagnostic" },
							symbols = { error = " ", warn = " ", info = " ", hint = " " },
							padding = { left = 1, right = 1 },
						},
						{
							"filetype",
							colored = true,
							icon_only = true,
							padding = { left = 1, right = 1 },
						},
					},
					lualine_y = {
						{
							"progress",
							padding = { left = 1, right = 1 },
						},
					},

					lualine_z = {
						{
							"location",
							padding = { left = 1, right = 1 },
						},
					},
				},

				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {
						{
							"filename",
							file_status = true,
							path = 1,
						},
					},
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},

				extensions = { "lazy", "mason", "quickfix" },
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				format = {
					cmdline = { pattern = "^:", icon = "", lang = "vim" },
					search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
					search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
					filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
					lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
					help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
				},
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
			routes = {
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
					},
				},
				view = "mini",
			},
		},
		keys = {
			{ "<leader>sn", "", desc = "+noice" },
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>sna",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<leader>snd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
			},
			{
				"<leader>snt",
				function()
					require("noice").cmd("pick")
				end,
				desc = "Noice Picker (Telescope/FzfLua)",
			},
			{
				"<c-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Forward",
				mode = { "i", "n", "s" },
			},
			{
				"<c-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Backward",
				mode = { "i", "n", "s" },
			},
		},
		dependencies = { "rcarriga/nvim-notify" },
		config = function(_, opts)
			require("noice").setup(opts)
		end,
	},
}
