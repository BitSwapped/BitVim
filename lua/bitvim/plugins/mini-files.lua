--- plugins/mini-files.lua ---
return {
	"echasnovski/mini.files",
	version = false,

	-- Lazy load on keybinds
	keys = {
		{
			"<leader>e",
			function()
				local mf = require("mini.files")
				if not mf.close() then
					mf.open(vim.api.nvim_buf_get_name(0), true)
				end
			end,
		},
		{
			"<leader>E",
			function()
				local mf = require("mini.files")
				if not mf.close() then
					mf.open(vim.uv.cwd(), true)
				end
			end,
			desc = "Explorer (cwd)",
		},
	},

	opts = {
		-- Navigation
		mappings = {
			close = "q",
			go_in_plus = "l",
			go_out = "h",
			go_out_plus = "H",
			reset = "<BS>",
			reveal_cwd = "@",
			show_help = "g?",
			synchronize = "=",
			trim_left = "<",
			trim_right = ">",
		},

		-- UI
		windows = {
			preview = true,
			width_focus = 30,
			width_preview = 30,
		},

		options = {
			use_as_default_explorer = true,
		},
	},

	config = function(_, opts)
		require("mini.files").setup(opts)

		local show_dotfiles = true

		-- Toggle hidden files
		local filter_show = function()
			return true
		end

		local filter_hide = function(fs_entry)
			return not vim.startswith(fs_entry.name, ".")
		end

		local toggle_dotfiles = function()
			show_dotfiles = not show_dotfiles
			local new_filter = show_dotfiles and filter_show or filter_hide
			require("mini.files").refresh({ content = { filter = new_filter } })
		end

		-- Set CWD to current directory
		local files_set_cwd = function()
			local cur_entry_path = require("mini.files").get_fs_entry().path
			local cur_directory = vim.fs.dirname(cur_entry_path)
			if cur_directory then
				vim.fn.chdir(cur_directory)
				vim.notify("CWD: " .. cur_directory)
			end
		end

		-- Open in split
		local map_split = function(buf_id, lhs, direction)
			local rhs = function()
				local new_target_window
				local cur_target_window = require("mini.files").get_target_window()
				if cur_target_window then
					vim.api.nvim_win_call(cur_target_window, function()
						vim.cmd(direction == "horizontal" and "split" or "vsplit")
						new_target_window = vim.api.nvim_get_current_win()
					end)

					require("mini.files").set_target_window(new_target_window)
					require("mini.files").go_in({})
				end
			end

			local desc = "Open in " .. direction .. " split"
			vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
		end

		-- Add keymaps when mini.files buffer is created
		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesBufferCreate",
			callback = function(args)
				local buf_id = args.data.buf_id

				-- Toggle dotfiles
				vim.keymap.set("n", "g.", toggle_dotfiles, {
					buffer = buf_id,
					desc = "Toggle hidden files",
				})

				-- Set CWD
				vim.keymap.set("n", "gc", files_set_cwd, {
					buffer = buf_id,
					desc = "Set CWD",
				})

				-- Open in splits
				map_split(buf_id, "<C-s>", "horizontal")
				map_split(buf_id, "<C-v>", "vertical")
			end,
		})

		-- Auto-close on file open
		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniFilesActionRename",
			callback = function(event)
				vim.notify("Renamed: " .. event.data.to)
			end,
		})
	end,

	init = function()
		-- Auto-open mini.files when starting with a directory
		if vim.fn.argc(-1) == 1 then
			local arg = vim.fn.argv(0)
			if vim.fn.isdirectory(arg) == 1 then
				vim.defer_fn(function()
					require("mini.files").open(arg)
				end, 0)
			end
		end
	end,
}
