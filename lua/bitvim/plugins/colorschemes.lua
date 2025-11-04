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
				"maris",
				"maris-ink",
				"maris-mist",
				"maris-foam",
				"mapledark",
				"rose-pine",
				"rose-pine-moon",
				"tokyonight-moon",
				"tokyonight-night",
				"tokyonight-storm",
			},
			livePreview = true,
		},
	},

	{ "Bitswapped/maris.nvim", opts = { variant = "foam" } },
	{ "catppuccin/nvim", name = "catppuccin" },
	{ "Everblush/nvim", name = "everblush" },
	{ "folke/tokyonight.nvim" },
	{ "rebelot/kanagawa.nvim" },
	{ "rose-pine/neovim", name = "rose-pine" },
	{ "abhilash26/mapledark.nvim" },
}
