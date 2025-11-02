-- core/autocmds.lua

local autocmd = vim.api.nvim_create_autocmd
local augroup = function(name)
	return vim.api.nvim_create_augroup("bit_" .. name, { clear = true })
end

-- Highlight yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank({ timeout = 200 })
	end,
})

-- Restore cursor
autocmd("BufReadPost", {
	group = augroup("restore_cursor"),
	callback = function(ev)
		local skip = { gitcommit = true, gitrebase = true }
		local ft = vim.bo[ev.buf].filetype
		if skip[ft] then
			return
		end

		local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
		local lines = vim.api.nvim_buf_line_count(ev.buf)
		if mark[1] > 0 and mark[1] <= lines then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Close misc filetypes with q
autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = { "help", "lspinfo", "qf", "query", "checkhealth", "man" },
	callback = function(ev)
		vim.bo[ev.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
	end,
})

-- Resize splits
autocmd("VimResized", {
	group = augroup("resize_splits"),
	callback = function()
		local tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. tab)
	end,
})

-- Check external changes
autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Cursorline only on active window
autocmd({ "InsertEnter", "WinLeave", "InsertLeave", "WinEnter" }, {
	group = augroup("cursorline_toggle"),
	callback = function(ev)
		local show = (ev.event == "InsertLeave" or ev.event == "WinEnter")
		if show and vim.bo[ev.buf].buftype == "" then
			vim.wo.cursorline = true
		else
			vim.wo.cursorline = false
		end
	end,
})

-- BitFilePost
autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("BitFilePost", { clear = true }),
	callback = function(args)
		local file = vim.api.nvim_buf_get_name(args.buf)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
		local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })

		if not vim.g.ui_entered or (file == "" and filetype ~= "minifiles") then
			return
		end
		vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
		vim.api.nvim_del_augroup_by_name("BitFilePost")

		vim.schedule(function()
			vim.api.nvim_exec_autocmds("FileType", {})
		end)
	end,
})

-- BitFile and BitGitFile events for lazy loading
local git_cache = {}

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
	desc = "Trigger BitFile and BitGitFile user events",
	callback = function(args)
		local buf = args.buf

		local filepath = vim.api.nvim_buf_get_name(buf)
		if filepath == "" then
			return
		end

		if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
			return
		end

		local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
		if ft == "alpha" or ft == "lazy" then
			return
		end

		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(buf) then
				return
			end

			vim.api.nvim_exec_autocmds("User", { pattern = "BitFile", modeline = false })

			if vim.fn.executable("git") == 1 then
				local dir = vim.fn.fnamemodify(filepath, ":h")
				if not git_cache[dir] then
					vim.fn.system({ "git", "-C", dir, "rev-parse", "--is-inside-work-tree" })
					git_cache[dir] = (vim.v.shell_error == 0)
				end
				if git_cache[dir] then
					vim.api.nvim_exec_autocmds("User", { pattern = "BitGitFile", modeline = false })
				end
			end
		end)
	end,
})

-- BitDeferred event for post-startup loading
vim.api.nvim_create_autocmd("VimEnter", {
	desc = "Trigger BitDeferred after startup",
	callback = function()
		local function fire_deferred()
			vim.api.nvim_exec_autocmds("User", { pattern = "BitDeferred", modeline = false })
		end

		if vim.fn.argc() > 0 then
			fire_deferred()

			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" then
					vim.api.nvim_exec_autocmds("BufEnter", { buffer = buf, modeline = false })
				end
			end
		else
			vim.defer_fn(fire_deferred, 70)
		end
	end,
})
