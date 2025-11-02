--- plugins/dashboard.lua ---

return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	opts = function()
		local dashboard = require("alpha.themes.dashboard")

		local logo = [[
     ██████╗ ██╗████████╗███████╗██╗    ██╗ █████╗ ██████╗ ██████╗ ███████╗██████╗ 
     ██╔══██╗██║╚══██╔══╝██╔════╝██║    ██║██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
     ██████╔╝██║   ██║   ███████╗██║ █╗ ██║███████║██████╔╝██████╔╝█████╗  ██║  ██║
     ██╔══██╗██║   ██║   ╚════██║██║███╗██║██╔══██║██╔═══╝ ██╔═══╝ ██╔══╝  ██║  ██║
     ██████╔╝██║   ██║   ███████║╚███╔███╔╝██║  ██║██║     ██║     ███████╗██████╔╝
     ╚═════╝ ╚═╝   ╚═╝   ╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚═════╝ 
    ]]

		dashboard.section.header.val = vim.split(logo, "\n")

		-- Footer function to show lazy.nvim stats
		dashboard.section.footer.val = function()
			local stats = require("lazy").stats()
			local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)

			return {
				string.format("⚡ Loaded %d/%d plugins in %.2fms", stats.loaded, stats.count, ms),
			}
		end

		dashboard.section.buttons.val = {
			dashboard.button("n", "  New file", ":enew<CR>"),
			dashboard.button("f", "  Find file", ":FzfLua files<CR>"),
			dashboard.button("r", "  Recent files", ":FzfLua oldfiles<CR>"),
			dashboard.button("g", "  Find text", ":FzfLua live_grep<CR>"),
			dashboard.button("b", "﬙  Buffers", ":FzfLua buffers<CR>"),
			dashboard.button("c", "  Config", ":e $MYVIMRC <CR>"),
			dashboard.button("l", "󰒲  Lazy", ":Lazy<CR>"),
			dashboard.button("q", "  Quit", ":qa<CR>"),
		}

		dashboard.config.layout = {
			{ type = "padding", val = vim.fn.max({ 2, vim.fn.floor(vim.fn.winheight(0) * 0.2) }) },
			dashboard.section.header,
			{ type = "padding", val = 1 },
			dashboard.section.buttons,
			{ type = "padding", val = 3 },
			dashboard.section.footer,
		}

		dashboard.config.opts.noautocmd = true

		return dashboard
	end,

	config = function(_, dashboard)
		if vim.o.filetype == "lazy" then
			vim.cmd.close()
			vim.api.nvim_create_autocmd("User", {
				pattern = "AlphaReady",
				callback = function()
					require("lazy").show()
				end,
			})
		end

		require("alpha").setup(dashboard.config)

		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyVimStarted",
			callback = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				dashboard.section.footer.val = {
					string.format("⚡ Loaded %d/%d plugins in %.2fms", stats.loaded, stats.count, ms),
				}
				pcall(vim.cmd.AlphaRedraw)
			end,
		})
	end,
}
