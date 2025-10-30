--- plugins/treesitter.lua ---

return {
	{
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
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		event = "VeryLazy",
		opts = {
			move = {
				enable = true,
				set_jumps = true,
				keys = {
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
						["]a"] = "@parameter.inner",
					},
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
						["[a"] = "@parameter.inner",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
						["[A"] = "@parameter.inner",
					},
				},
			},
		},
		config = function(_, opts)
			local TS = require("nvim-treesitter-textobjects")
			if not TS.setup then
				vim.notify("Please update nvim-treesitter to use nvim-treesitter-textobjects", vim.log.levels.ERROR)
				return
			end
			TS.setup(opts)

			local function attach(buf)
				local ft = vim.bo[buf].filetype
				if not (opts.move and opts.move.enable) then
					return
				end

				-- Check if the filetype supports textobjects queries
				local has_textobjects = false
				local parsers = require("nvim-treesitter.parsers")
				local parser = parsers.get_parser(buf, ft)
				if parser then
					local query = require("vim.treesitter.query")
					local ok = pcall(query.get, ft, "textobjects")
					has_textobjects = ok
				end
				if not has_textobjects then
					return
				end

				local moves = opts.move.keys or {}

				for method, keymaps in pairs(moves) do
					for key, query in pairs(keymaps) do
						local desc = query:gsub("@", ""):gsub("%..*", "")
						desc = desc:sub(1, 1):upper() .. desc:sub(2)
						desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
						desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")

						-- Avoid mapping in diff mode for class motions (c/C)
						if not (vim.wo.diff and key:find("[cC]")) then
							vim.keymap.set({ "n", "x", "o" }, key, function()
								require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
							end, {
								buffer = buf,
								desc = desc,
								silent = true,
							})
						end
					end
				end
			end

			-- Attach keymaps on FileType and existing buffers
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter_textobjects", { clear = true }),
				callback = function(ev)
					attach(ev.buf)
				end,
			})

			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) then
					attach(buf)
				end
			end
		end,
	},
}
