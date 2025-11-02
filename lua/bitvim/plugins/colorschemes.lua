--- plugins/colorschemes.lua ---
return {
	{
		"zaldih/themery.nvim",
		lazy = false,
		keys = { { "<leader>th", "<cmd>Themery<cr>" } },
		opts = {
			themes = {
				"catppuccin-mocha",
				"catppuccin-macchiato",
				"everblush",
				"kanagawa-dragon",
				"kanagawa-wave",
				"rose-pine",
				"rose-pine-moon",
				"tokyonight-moon",
				"tokyonight-night",
				"tokyonight-storm",
			},
			livePreview = true,
		},
	},

	{ "catppuccin/nvim", name = "catppuccin" },
	{ "Everblush/nvim", name = "everblush" },
	{ "folke/tokyonight.nvim" },
	{ "rebelot/kanagawa.nvim" },
	{ "rose-pine/neovim", name = "rose-pine" },
}
