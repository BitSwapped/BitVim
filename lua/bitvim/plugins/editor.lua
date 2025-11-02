--- plugins/editor.lua ---

return {
	{
		"nvim-mini/mini.cursorword",
		version = false,
		event = "VeryLazy",
		opts = {},
	},
	{
		"nvim-mini/mini.comment",
		version = false,
		event = "VeryLazy",
		opts = {},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{
		"nacro90/numb.nvim",
		event = "VeryLazy",
		config = function()
			require("numb").setup()
		end,
	},
	{
		"kylechui/nvim-surround",
		version = "^3.0.0",
		event = "VeryLazy",
		opts = {},
	},
}
