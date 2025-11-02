--- plugins/completion.lua ---

return {
	{
		"L3MON4D3/LuaSnip",
		lazy = true,
		build = "make install_jsregexp",
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
					require("luasnip.loaders.from_vscode").lazy_load({
						paths = { vim.fn.stdpath("config") .. "/snippets" },
					})
				end,
			},
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
		},
	},

	{
		"saghen/blink.compat",
		version = "2.*",
		opts = {},
	},

	{
		"saghen/blink.cmp",
		version = "*",
		event = "LspAttach",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"xzbdmw/colorful-menu.nvim",
			"onsails/lspkind.nvim",
		},
		opts = function()
			return {
				--- Command-line completion disabled
				cmdline = { enabled = false },

				--- Completion behavior configuration
				completion = {
					keyword = { range = "full" },

					--- Accept behavior
					accept = {
						auto_brackets = { enabled = false },
					},

					--- Selection list behavior
					list = {
						selection = { preselect = false, auto_insert = true },
					},

					--- Documentation popup
					documentation = {
						auto_show = true,
						auto_show_delay_ms = 500,
						window = {
							border = "rounded",
							scrollbar = false,
						},
					},

					--- Ghost text
					ghost_text = {
						enabled = true,
						show_with_menu = false,
					},

					--- Completion menu configuration
					menu = {
						enabled = true,
						min_width = 15,
						max_height = 10,
						border = "rounded",
						winblend = 0,
						scrolloff = 2,
						scrollbar = false,
						auto_show = true,
						auto_show_delay_ms = 0,
						draw = {
							padding = 2,
							columns = {
								{ "kind_icon" },
								{ "label", gap = 2 },
							},
							components = {
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
								kind_icon = {
									text = function(ctx)
										-- File/Path icons
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local icon = require("mini.icons").get("file", ctx.label)
											if icon then
												return icon .. ctx.icon_gap
											end
										end
										-- LSP symbols
										local icon = require("lspkind").symbolic(ctx.kind, { mode = "symbol" })
										return (icon ~= "" and icon or ctx.kind_icon) .. ctx.icon_gap
									end,
									highlight = function(ctx)
										if vim.tbl_contains({ "Path" }, ctx.source_name) then
											local _, hl = require("mini.icons").get("file", ctx.label)
											if hl then
												return hl
											end
										end
										return ctx.kind_hl
									end,
								},
							},
						},
					},
				},

				--- Keymaps
				keymap = {
					--- Navigation
					["<Up>"] = { "select_prev", "fallback" },
					["<Down>"] = { "select_next", "fallback" },
					["<C-p>"] = { "select_prev", "fallback_to_mappings" },
					["<C-n>"] = { "select_next", "fallback_to_mappings" },

					--- Documentation scrolling
					["<C-b>"] = { "scroll_documentation_up", "fallback" },
					["<C-f>"] = { "scroll_documentation_down", "fallback" },

					--- Snippets & Tab navigation
					["<Tab>"] = {
						function(cmp)
							if #require("blink.cmp.completion.list").items == 1 then
								return require("blink.cmp").select_and_accept()
							elseif cmp.snippet_active() then
								return cmp.accept()
							else
								return require("blink.cmp").select_next()
							end
						end,
						"snippet_forward",
						"fallback",
					},
					["<S-Tab>"] = {
						function()
							if #require("blink.cmp.completion.list").items > 0 then
								return require("blink.cmp").select_prev()
							end
						end,
						"snippet_backward",
						"fallback",
					},

					--- Signature help
					["<C-k>"] = { "show_signature", "hide_signature", "fallback" },

					--- Accept completion
					["<CR>"] = {
						function()
							if
								#require("blink.cmp.completion.list").items > 0
								and require("blink.cmp.completion.list").get_selected_item()
							then
								return require("blink.cmp").accept()
							else
								return false
							end
						end,
						"fallback",
					},

					--- Menu show/hide
					["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
					["<C-e>"] = { "hide", "fallback" },
					["<C-y>"] = { "select_and_accept", "fallback" },
				},

				--- Completion sources
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
				},
			}
		end,
	},
}
