--- plugins/treesitter.lua ---

return {
	"nvim-treesitter/nvim-treesitter",
	version = false,
	build = ":TSUpdate",
	event = "VeryLazy",

	init = function(plugin)
		require("lazy.core.loader").add_to_rtp(plugin)
		require("nvim-treesitter.query_predicates")
	end,

	---@type TSConfig
	---@diagnostic disable-next-line: missing-fields
	opts = {
		ensure_installed = {
			"bash",
			"c",
			"diff",
			"html",
			"javascript",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"regex",
			"toml",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		},

		highlight = {
			enable = true,
			disable = function(lang, buf)
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
			additional_vim_regex_highlighting = false,
		},

		indent = {
			enable = true,
		},

		fold = {
			enable = true,
		},

		incremental_selection = {
			enable = false,
		},
	},

	---@param opts TSConfig
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
